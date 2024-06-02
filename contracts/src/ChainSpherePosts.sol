// Layout of Contract:
// version
// imports
// interfaces, libraries, contracts
// errors
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// internal & private view & pure functions
// external & public view & pure functions

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;


import {PriceConverter} from "./PriceConverter.sol";
import { ChainSphereUserProfile as CSUserProfile} from "./ChainSphereUserProfile.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract ChainSpherePosts is  CSUserProfile {
    using PriceConverter for uint256;

    //////////////
    /// Errors ///
    //////////////
    
    error ChainSphere__NotPostOwner();
    error ChainSphere__OwnerCannotVote();
    error ChainSphere__AlreadyVoted();
    error ChainSphere__PaymentNotEnough();
    error ChainSphere__PostDoesNotExist();
    error ChainSphere__UpkeepNotNeeded(
        uint256 balance,
        uint256 numOfEligibleAuthors
    );
    error ChainSphere__TransferFailed();
    error ChainSphere__BatchTransferFailed(address winner);
    

    ///////////////////////
    /// State Variables ///
    ///////////////////////

    /* For gas efficiency, we declare variables as private and define getter functions for them where necessary */

    // Imported Variables
    AggregatorV3Interface private s_priceFeed;

    // Constants
    uint256 private immutable i_minimumUsd;
    uint256 private constant MIN_POST_SCORE = 1; // set to 1 for development purpose

    /** Variables Relating to Post */
    Post[] s_posts; // array of all posts
    uint256[] s_idsOfRecentPosts; // array of posts that are not more than VALIDITY_PERIOD old. This array is reset anytime authors have been picked for reward.
    mapping(uint256 => Post) private s_idToPost; // get full details of a post using the postId

    mapping(address => uint256) private s_authorToPostId; // Get postId using address of the author
    mapping(uint256 => address) private s_postIdToAuthor; // Get the address of the author of a post using the postId

    mapping(string => address) private s_usernameToAddress; // get user address using their name
    mapping(address userAddress => mapping(uint256 postId => bool)) private s_hasVoted; //Checks if a user has voted for a post or not
    mapping(address userAddress => Post[]) private s_userPosts; // gets all posts by a user using the user address
    mapping(uint256 postId => uint256 idInUserPosts) private s_postIdToIdInUserPosts; // mapping postId to the serial number of the post in s_userPosts
    Post[] s_recentWinningPosts;
    Post[] s_recentTrendingPosts;

    
    /** Other Variables */

    address[] private s_authorsEligibleForReward; // An array of users eligible for rewards. Addresses are marked payable so that winner can be paid

    uint256[] private s_idsOfEligiblePosts; // array that holds postId of eligible posts for reward
    uint256[] private s_idsOfRecentWinningPosts; // array that holds postId of the monst recent winning posts
    
    //////////////
    /// Events ///
    //////////////

    event PostCreated(uint256 postId, string authorName);
    event PostEdited(uint256 postId, string authorName);
    event PostLiked(
        uint256 indexed postId,
        address indexed postAuthor,
        address indexed liker
    );
    event Upvoted(uint256 postId, string posthAuthorName, string upvoterName);
    event Downvoted(
        uint256 postId,
        string posthAuthorName,
        string downvoterName
    );

    // Event for rewarding users
    event RewardSent(address indexed user, uint256 amount);
    event RequestWinningAuthor(uint256 requestId);
    event PickedWinner(address winner);
    
    /////////////////
    /// Modifiers ///
    /////////////////

    modifier _onlyPostOwner(uint256 _postId) {
        if (msg.sender != _getPostById(_postId).author) {
            revert ChainSphere__NotPostOwner();
        }
        _;
    }

    modifier _checkUserExists(address _userAddress) {
        if (_getUser(_userAddress).userAddress == address(0)) {
            revert ChainSphere__UserDoesNotExist();
        }
        _;
    }

    modifier _notOwner(uint256 _postId) {
        if (msg.sender == _getPostById(_postId).author) {
            revert ChainSphere__OwnerCannotVote();
        }
        _;
    }

    modifier _hasNotVoted(uint256 _postId) {
        if (_getUserVoteStatus(_postId)) {
            revert ChainSphere__AlreadyVoted();
        }
        _;
    }

    modifier _hasPaid() {
        if (msg.value.getConversionRate(s_priceFeed) < i_minimumUsd) {
            revert ChainSphere__PaymentNotEnough();
        }
        _;
    }


    ///////////////////
    /// Constructor ///
    ///////////////////

    constructor(address _priceFeed, uint256 _minimumUsd){
        s_priceFeed = AggregatorV3Interface(_priceFeed);
        i_minimumUsd = _minimumUsd;
    }
    
    //////////////////////////
    /// Internal Functions ///
    //////////////////////////
    
    /**
     * @dev This function allows only a registered user to create posts on the platform
     * @param _content is the content of the post by user
     * @param _imgHash is the hash of the image uploaded by the user
     */
    function _createPost(string memory _content, string memory _imgHash)
        internal
        _checkUserExists(msg.sender)
    {
        // generate id's for posts in a serial manner
        uint256 postId = s_posts.length;

        // Initialize an instance of a post for the user
        Post memory newPost = Post({
            postId: postId,
            content: _content,
            imgHash: _imgHash,
            timestamp: block.timestamp,
            upvotes: 0,
            downvotes: 0,
            author: msg.sender,
            authorNickName: _getUser(msg.sender).nickName,
            authorFullName: _getUser(msg.sender).fullNameOfUser,
            authorProfileImgHash: _getUser(msg.sender).profileImageHash
        });

        string memory nameOfUser = _getUserNameFromAddress(msg.sender);

        // task: create a mapping that links postId to idInUserPosts
        uint256 idInUserPosts = s_userPosts[msg.sender].length;
        s_userPosts[msg.sender].push(newPost); // Add the post to s_userPosts
        s_postIdToIdInUserPosts[newPost.postId] = idInUserPosts; // map the postId to idInUserPosts
        s_posts.push(newPost); // Add the post to the array of posts
        s_idsOfRecentPosts.push(newPost.postId); // Add the postId to the array of ids of recent posts for possible nomination for reward
        s_authorToPostId[msg.sender] = postId; // map post to the author
        s_postIdToAuthor[postId] = msg.sender;
        emit PostCreated(postId, nameOfUser);
    }

    /**
     * @dev This function allows only the owner of a post to edit their post
     * @param _postId is the id of the post to be edited
     * @param _content is the content of the post by user
     * @param _imgHash is the hash of the image uploaded by the user. This is optional
     * 
     */
    function _editPost(
        uint256 _postId,
        string memory _content,
        string memory _imgHash
    ) internal _onlyPostOwner(_postId) {
        s_posts[_postId].content = _content;
        if(keccak256(abi.encode(_imgHash)) != keccak256(abi.encode(""))){
            s_posts[_postId].imgHash = _imgHash; // this is only triggered if the picture of the post is changed
        }
        string memory nameOfUser = _getUserNameFromAddress(msg.sender);
        emit PostEdited(_postId, nameOfUser);
    }

    /**
     * @dev A user should pay to delete post. The rationale is, to ensure users go through their content before posting since deleting of content is not free
     * @param _postId is the id of the post to be deleted
     * @notice The function checks if the user has paid the required fee for deleting post before proceeding with the action. To effect the payment functionality, we include a receive function to enable the smart contract receive ether. Also, we use Chainlink pricefeed to ensure ether is amount has the required usd equivalent
     */
    function _deletePost(uint256 _postId) internal
    {
        address currentUser  = s_posts[_postId].author;
        // reset the post
        s_posts[_postId] = Post({
            postId: _postId,
            content: "",
            imgHash: "",
            timestamp: 0,
            upvotes: 0,
            downvotes: 0,
            author: address(0),
            authorNickName: "",
            authorFullName: "",
            authorProfileImgHash: ""
        });
        // reset previous mappings
        s_postIdToAuthor[_postId] = address(0); // undo the initial mapping
        s_authorToPostId[address(0)] = _postId; // undo the initial mapping
        uint256 idOfPostInArray = s_postIdToIdInUserPosts[_postId];
        s_userPosts[currentUser][idOfPostInArray].author = address(0); // reset author address to address 0
        s_userPosts[currentUser][idOfPostInArray].content = ""; // reset content to empty string
        
    }

    /**
    * @dev This function allows a registered user to give an upvote to a post
    * @param _postId is the id of the post for which user wishes to give an upvote
    * @notice no user should be able to vote for their post. No user should vote for the same post more than once
    * @notice the function increments the number of upvotes for the post by 1, sets the callers voting status for the post as true and emits event that post has received an upvote from the user
     */
    function _upvote(uint256 _postId)
        internal
        _notOwner(_postId)
        _hasNotVoted(_postId)
    {
        s_hasVoted[msg.sender][_postId] = true;
        s_posts[_postId].upvotes++;
        
        address postAuthAddress = s_postIdToAuthor[_postId];
        string memory postAuthorName = _getUserNameFromAddress(postAuthAddress);
        string memory upvoter = _getUserNameFromAddress(msg.sender);

        emit Upvoted(_postId, postAuthorName, upvoter);
    }

    /**
    * @dev This function allows a registered user to give a downvote to a post
    * @param _postId is the id of the post for which user wishes to give a downvote
    * @notice no user should be able to vote for their post. No user should vote for the same post more than once
    * @notice the function increments the number of downvotes for the post by 1, sets the callers voting status for the post as true and emits event that post has received a downvote from the user
     */
    function _downvote(uint256 _postId)
        internal
        _notOwner(_postId)
        _hasNotVoted(_postId)
    {
        s_hasVoted[msg.sender][_postId] = true;
        s_posts[_postId].downvotes++;
    
        address postAuthAddress = s_postIdToAuthor[_postId];
        string memory postAuthorName = _getUserNameFromAddress(postAuthAddress);
        string memory downvoterName = _getUserNameFromAddress(msg.sender);

        emit Downvoted(_postId, postAuthorName, downvoterName);
    }

    /**
     * @dev This function is to be called automatically using Chainlink Automation every VALIDITY_PERIOD (i.e. 30 days or as desirable). The function loops through an array of recentPosts and checks if posts are eligible for rewards and add the corresponding authors to an array of eligible authors for reward
     * @param _idsOfRecentPosts is an array of all recent posts from which the Contract will check for eligible posts
     */
    function _pickIdsOfEligiblePosts(uint256[] memory _idsOfRecentPosts) internal {

        uint256 len = _idsOfRecentPosts.length; // number of recent posts

        /** Loop through the array and pick posts that are eligible for reward */
        for (uint256 i; i < len; ) {
            // Check if post is eligible for rewards and add the postId to the array of eligible posts

            if (_isPostEligibleForReward(_idsOfRecentPosts[i])) {
                s_idsOfEligiblePosts.push(_idsOfRecentPosts[i]);
            }


            unchecked {
                i++;
            }
        }

    }


    ///////////////////////
    // Private Functions //
    ///////////////////////

    /**
     * @dev This function checks the the number of upvotes and number of downvotes of a post, calculates their difference to tell if the author of the post is eligible for rewards in that period.
     * @notice A user can be adjudged eligible on multiple grounds if they have multiple posts with significantly more number of upvotes than downvotes
     * @param _postId is the id of the post whose eligibility is to be determined
     */
    function _isPostEligibleForReward(uint256 _postId)
        private
        view
        returns (bool isEligible)
    {
        uint256 numOfUpvotes = _getPostById(_postId).upvotes; // get number of upvotes of post
        uint256 numOfDownvotes = _getPostById(_postId).downvotes; // get number of downvotes of post
        uint256 postScore = numOfUpvotes - numOfDownvotes > 0
            ? numOfUpvotes - numOfDownvotes
            : 0; // set minimum postScore to zero. We dont want negative values
        isEligible = postScore >= MIN_POST_SCORE ? true : false; // a post is adjudged eligible for reward if the post has ten (10) more upvotes than downvotes
    }

    

    /**
    * @dev this function resets the array containing the ids of posts eligible for reward. This function is called when the process for selecting the next winner is initiated
     */
    function _resetIdsOfEligiblePosts() internal {
        s_idsOfEligiblePosts = new uint256[](0);
    }

    /**
    * @dev this function resets the array containing the ids of recent winning post(s). This function is called when the next winner is just about to be selected
     */
    function _resetIdsOfRecentWinningPosts() internal {
        s_idsOfRecentWinningPosts = new uint256[](0);
    }

    /**
    * @dev this function adds a postId to the array containing the ids of winning post(s). This function is called whenever a winner is selected
    * @param _idOfWinningPost is the postId to be added to the s_idsOfRecentWinningPosts
     */
    function _addIdToIdsOfRecentWinningPosts(uint256 _idOfWinningPost) internal {
        s_idsOfRecentWinningPosts.push(_idOfWinningPost);
    }

    /**
    * @dev this function resets the array containing the ids of recent post(s). This function is called after a winner is selected. The array is reset so that new posts can be saved in the array for the next selection process. This way, an author doesn't get rewarded more than once on the same post
     */
    function _resetIdsOfRecentPosts() internal {
        s_idsOfRecentPosts = new uint256[](0);
    }


    //////////////////////
    // Getter Functions //
    //////////////////////

    function _getIdsOfRecentWinningPosts() internal view returns (uint256[] memory) {
        return s_idsOfRecentWinningPosts;
    }

    function _getIdsOfRecentPosts() internal view returns (uint256[] memory) {
        return s_idsOfRecentPosts;
    }

    function _getIdsOfEligiblePosts() internal view returns (uint256[] memory) {
        return s_idsOfEligiblePosts;
    }


    /**
    * @dev function retrieves all posts by a user given the userAddress
    * @param _userAddress is the wallet address of user
    * @return function returns an arry of all posts by the user
     */
    function _getUserPosts(address _userAddress)
        internal
        view
        returns (Post[] memory)
    {
        // Implementation to retrieve all posts by a user
        return s_userPosts[_userAddress];
    }

    /**
    * @dev function tells whether a user has cast vote on a post or not
    * @param _postId is the id of post. postId is unique
    * @return function returns a bool as the vote status
     */
    function _getUserVoteStatus(uint256 _postId) internal view returns(bool){
        return s_hasVoted[msg.sender][_postId];
    }
    /**
    * @dev function retrieves all information on a post given the postId
    * @param _postId is the id of the post. The postId is unique
    * @return function returns the post corresponding to that postId
     */
    function _getPostById(uint256 _postId) internal view returns (Post memory) {
        if(_postId >= _getAllPosts().length){
            revert ChainSphere__PostDoesNotExist();
        }

        return s_posts[_postId];
    }

    
    /**
    * @dev This function retrieves all post on the blockchain
     */
    function _getAllPosts() internal view returns (Post[] memory) {
        return s_posts;
    }

    /**
    * @dev This function retrieves the username of recent winners on the platform
     */
    function _getUsernameOfRecentWinners() internal returns(string[] memory) {
        uint256 len = s_idsOfRecentWinningPosts.length;
        for(uint256 i; i < len; ){
            s_userNamesOfRecentWinners.push(
                _getUserNameFromAddress(
                    _getPostById(
                        s_idsOfRecentWinningPosts[i]
                    ).author
                )
            );
            unchecked {
                i++;
            }
        }

        return s_userNamesOfRecentWinners;
    }

    /**
    * @dev This function retrieves all recent winning posts on the platform
     */
    function _getRecentWinningPosts() internal returns(Post[] memory) {
        uint256 len = s_idsOfRecentWinningPosts.length;
        for(uint256 i; i < len; ){
            s_recentWinningPosts.push(
                _getPostById(
                    s_idsOfRecentWinningPosts[i]
                )
            );
            unchecked {
                i++;
            }
        }

        return s_recentWinningPosts;
    }

    /**
    * @dev This function retrieves all recent trending posts on the platform. These are posts that have at least the minimum post score
     */
    function _getRecentTrendingPosts() internal returns(Post[] memory) {
        uint256 len = s_idsOfEligiblePosts.length;
        for(uint256 i; i < len; ){
            s_recentTrendingPosts.push(
                _getPostById(
                    s_idsOfEligiblePosts[i]
                )
            );
            unchecked {
                i++;
            }
        }

        return s_recentTrendingPosts;
    }

    /**
    * @dev function receives quantity of ether and gives its value in USD
     */
    function _getUsdValueOfEthAmount(uint256 _ethAmount)
        internal
        view
        returns (uint256)
    {
        uint256 usdValue = _ethAmount.getConversionRate(s_priceFeed);
        return usdValue;
    }

    
}
