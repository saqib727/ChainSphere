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

/// @dev Implements Chainlink VRFv2.5, Automation and Price Feed

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import { ChainSphereUserProfile as CSUserProfile}  from "./ChainSphereUserProfile.sol";
import { ChainSpherePosts as CSPosts}  from "./ChainSpherePosts.sol";
import { ChainSphereComments as CSComments}  from "./ChainSphereComments.sol";

contract ChainSphere is VRFConsumerBaseV2, CSUserProfile, CSPosts, CSComments {
    using PriceConverter for uint256;
    

    //////////////
    /// Errors ///
    //////////////
    error ChainSphere__NotOwner();

    // Imported Variables
    AggregatorV3Interface private s_priceFeed;

    // Constants

    // VRF2 Constants
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint8 private constant TEN = 10; // Maximum percentage of winners to be picked out of an array of eligible authors
    uint8 private constant TWENTY = 20; // Number of eligible authors beyond which a maximum of 10% will be picked for award
    uint8 private constant HUNDRED = 100;

    
    uint32 private s_numOfWords; // number of random words to request from the Chainlink Oracle

    uint256 private immutable i_interval; // Period that must pass before a set of posts can be adjudged eligible for reward based on their postScore
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    uint256 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;

    uint256 private s_lastTimeStamp;
    address private s_owner; // would have made this variable immutable but for the changes_Owner function in the contract
    

    /////////////////
    /// Modifiers ///
    /////////////////

    modifier onlyOwner() {
        if (msg.sender != getContractOwner()) {
            revert ChainSphere__NotOwner();
        }
        _;
    }

    modifier onlyPostOwner(uint256 _postId) {
        if (msg.sender != getPostById(_postId).author) {
            revert ChainSphere__NotPostOwner();
        }
        _;
    }

    ///////////////////
    /// Constructor ///
    ///////////////////
    constructor(
        address priceFeed,
        uint256 interval,
        address vrfCoordinator,
        bytes32 gasLane,
        uint256 subscriptionId,
        uint32 callbackGasLimit,
        uint256 minimumUsd
    ) VRFConsumerBaseV2(vrfCoordinator) CSComments(priceFeed, minimumUsd){
        s_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
        i_interval = interval;
        s_lastTimeStamp = block.timestamp;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinator);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
    }

    //////////////////////////////////////////
    /// The Receive and Fallback Functions ///
    //////////////////////////////////////////

    /**
     * @dev this function enables the Smart Contract to receive payment
     * @notice this function allows the Contract to receive ETH as value sent alongside a function call in the Smart Contract
     */
    receive() external payable {}

    /**
     * @dev this function enables the Smart Contract to receive payment
     * @notice this function allows the Contract to receive ETH even without a function call in the Smart Contract e.g. by just sending ETH using the Contract Address
     */
    fallback() external payable {}


    ////////////////////////
    /// Public Functions ///
    ////////////////////////

    /**
    * @dev This function enables a user to be registered on ChainSphere
    * @param _fullNameOfUser is the full name of the User
    * @param _username is the user's nick name which must be unique. No two accounts are allowed to have the same nick name
     */
    function registerUser(string memory _fullNameOfUser, string memory _username)
        public
    {
        _registerUser(_fullNameOfUser, _username);
    }

    /**
    * @dev this function allows a user to change thier nick name
    * @param _userId is the id of the user which is a unique number
    * @param _newNickName is the new nick name the user wishes to change to
    * @notice the function checks if the caller is the owner of the profile and if _newNickName is not registered on the platform yet
     */
    function changeUsername(uint256 _userId, string memory _newNickName)
        public
    {
        _changeUsername(_userId, _newNickName);
    }

    /**
    * @dev this function allows a user to edit their profile
    * @param _userId is the id of the user which is a unique number
    * @param _bio is a short self introduction about the user
    * @param _profileImageHash is a hash of the profile image uploaded by the user
    * @param _newName is the new full name of the user
    * @notice the function checks if the caller is registered and is the owner of the profile 
    * @notice it is not mandatory for all parameters to be supplied before calling the function. If any parameter is not supplied, that portion of the user profile is not updated
     */
    function editUserProfile(
        uint256 _userId,
        string memory _bio,
        string memory _profileImageHash,
        string memory _newName
    ) public {

        _editUserProfile(_userId, _bio, _profileImageHash, _newName);
    }

    /**
     * @dev This function allows only a registered user to create posts on the platform
     * @param _content is the content of the post by user
     * @param _imgHash is the hash of the image uploaded by the user
     */
    function createPost(string memory _content, string memory _imgHash)
        public
    {
        _createPost(_content, _imgHash);
    }

    /**
     * @dev This function allows only the owner of a post to edit their post
     * @param _postId is the id of the post to be edited
     * @param _content is the content of the post by user
     * @param _imgHash is the hash of the image uploaded by the user. This is optional
     * 
     */
    function editPost(
        uint256 _postId,
        string memory _content,
        string memory _imgHash
    ) public {
        _editPost(_postId, _content, _imgHash);
    }

    /**
     * @dev A user should pay to delete post. The rationale is, to ensure users go through their content before posting since deleting of content is not free
     * @param _postId is the id of the post to be deleted
     * @notice The function checks if the user has paid the required fee for deleting post before proceeding with the action. To effect the payment functionality, we include a receive function to enable the smart contract receive ether. Also, we use Chainlink pricefeed to ensure ether is amount has the required usd equivalent
     */
    function deletePost(uint256 _postId) public payable onlyPostOwner(_postId)  CSPosts._hasPaid  {
        _deletePost(_postId);
    }

    /**
    * @dev This function allows a registered user to give an upvote to a post
    * @param _postId is the id of the post for which user wishes to give an upvote
    * @notice no user should be able to vote for their post. No user should vote for the same post more than once
    * @notice the function increments the number of upvotes for the post by 1, sets the callers voting status for the post as true and emits event that post has received an upvote from the user
     */
    function upvote(uint256 _postId)
        public
    {
        _upvote(_postId);
    }

    /**
    * @dev This function allows a registered user to give a downvote to a post
    * @param _postId is the id of the post for which user wishes to give a downvote
    * @notice no user should be able to vote for their post. No user should vote for the same post more than once
    * @notice the function increments the number of downvotes for the post by 1, sets the callers voting status for the post as true and emits event that post has received a downvote from the user
     */
    function downvote(uint256 _postId)
        public
    {
        _downvote(_postId);
    }

    /**
     * @dev createComment enables registered users to comment on any post
     * @param _postId is the id of the post for which user wishes to comment on
     * @param _content is the text i.e. the comment the user wishes to create on the post
     * @notice Since the postId is unique and can be mapped to author of the post, we only need the postId to uniquely reference any post in order to comment on it
     * Because in any social media platform there are so much more comments than posts, we allow the commentId not to be unique in general. However, comment ids are unique relative to any given post. Our thought is that this will prevent overflow
     */
    function createComment(uint256 _postId, string memory _content)
        public
    {
        
        _createComment(_postId, _content);
    }

    /**
     * @dev This function allows only the user who created a comment to edit it.
     * @param _postId is the id of the post on which the comment was made
     * @param _commentId is the id of the comment of interest
     * @param _content is the new content of the comment
     */
    function editComment(
        uint256 _postId, uint256 _commentId, string memory _content
    ) public {
        _editComment(_postId, _commentId, _content);
    }

    /**
     * @dev This function allows only the user who created a comment to delete it. 
     * @param _postId is the id of the post on which the comment was made
     * @param _commentId is the id of the comment of interest
     * @notice the function checks if the caller is the owner of the comment and has paid the fee for deleting comment
     */
    function deleteComment(uint256 _postId, uint256 _commentId) public payable  CSPosts._hasPaid  {
        _deleteComment(_postId, _commentId); 
    }

    /**
    * @dev this function allows a registered user to like any comment
    * @param _postId is the id of the post on which the comment was made
    * @param _commentId is the id of the comment in question
    * @notice the function increments the number of likes on the comment by 1 and adds user to an array of likers
     */
    function likeComment(uint256 _postId, uint256 _commentId)
        public
    {
        _likeComment(_postId, _commentId);
        
    }

    
    /////////////////////////
    // Chainlink Functions //
    /////////////////////////

    // 1. Get a random number
    // 2. Use the random number to pick the winner
    // 3. Be automatically called

    // Chainlink Automation

    // When is the winner supposed to be picked?
    /**
     * @dev This is the function that the Chainlink Automation nodes call
     * to see if it's time to perform an upkeep.
     * The following should be true for this to return true:
     * 1. the time interval has passed between tournaments
     * 2. there is at least 1 author eligible for reward
     * 3. the contract has ETH (i.e. the Contract has received some payments)
     * 4. (Implicit) the subscription is funded with LINK
     */

    function CheckUpkeep(
        bytes memory /* checkData */
    )
        public
        returns (
            bool upkeepNeeded,
            bytes memory /* performData */
        )
    {
        // reset the s_idsOfEligiblePosts array 
        resetIdsOfEligiblePosts();

        // call the _pickEligibleAuthors function to determine authors that are eligible for reward
        _pickIdsOfEligiblePosts(getIdsOfRecentPosts()); // this updates the s_idsOfEligiblePosts array

        bool timeHasPassed = (block.timestamp - s_lastTimeStamp) >= i_interval; // checks if enough time has passed
        bool hasBalance = address(this).balance > 0; // Contract has ETH
        bool hasAuthors = getIdsOfEligiblePosts().length > 0; // Contract has authors eligible for reward
        upkeepNeeded = (timeHasPassed && hasBalance && hasAuthors);
        return (upkeepNeeded, "0x0");
    }

    function performUpkeep(
        bytes calldata /* performData */
    ) external {
        // Checks

        (bool upkeepNeeded, ) = CheckUpkeep(" ");
        if (!upkeepNeeded) {
            revert ChainSphere__UpkeepNotNeeded(
                address(this).balance,
                getIdsOfEligiblePosts().length
            );
        }

        // Effects (on our Contract)

        // 1. Request RNG from VRF
        // 2. Receive the random number generated

        // Interactions (with other Contracts)
        s_numOfWords = getIdsOfEligiblePosts().length <= TWENTY
            ? 1
            : uint32(getIdsOfEligiblePosts().length % TEN); // Pick one winner or a max ten percent of eligible winners

        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            s_numOfWords
        );

        emit RequestWinningAuthor(requestId);
    }

    function fulfillRandomWords(
        uint256, /*requestId*/
        uint256[] memory randomWords
    ) internal override {
        // Checks

        // Effects (on our Contract)

        resetIdsOfRecentPosts(); // reset the array of recent posts
        s_lastTimeStamp = block.timestamp; // reset the timer for the next interval of posts to be considered
            
        resetIdsOfRecentWinningPosts(); // reset array of postId of most recent winning posts

        if (randomWords.length == 1) {
            uint256 WINNING_REWARD = uint256((address(this).balance * TWENTY)/HUNDRED);
            uint256 ranNumber = randomWords[0] % getIdsOfEligiblePosts().length;
            uint256 idOfWinningPost = getIdsOfEligiblePosts()[ranNumber]; // get the postId
            addIdToIdsOfRecentWinningPosts(idOfWinningPost);
            address payable winner = payable(
                getPostById(idOfWinningPost).author
            );

            emit PickedWinner(winner);

            // Interactions (With other Contracts)

            // pay the winner
            (bool success, ) = winner.call{value: WINNING_REWARD}(""); // c make the winning reward vary according to the income generated on the platform
            if (!success) {
                revert ChainSphere__TransferFailed();
            }
        } else {
            uint256 len = randomWords.length;
            uint256 WINNING_REWARD = uint256((address(this).balance * TWENTY)/(HUNDRED * len));
            uint256 i;
            for (i; i < len; ) {
                uint256 ranNumber = randomWords[i] % getIdsOfEligiblePosts().length;
                uint256 idOfWinningPost = getIdsOfEligiblePosts()[ranNumber]; // get the postId
                addIdToIdsOfRecentWinningPosts(idOfWinningPost);
                address payable winner = payable(
                    getPostById(idOfWinningPost).author
                );

                emit PickedWinner(winner);

                // Interactions (With other Contracts)

                // pay the winner
                (bool success, ) = winner.call{value: WINNING_REWARD}(""); // c make the winning reward vary according to the income generated on the platform
                if (!success) {
                    revert ChainSphere__BatchTransferFailed(winner);
                }

                unchecked {
                    i++;
                }
            }
        }
    }
    

    ///////////////////////
    // Private Functions //
    ///////////////////////

    /**
    * @dev this function resets the array containing the ids of posts eligible for reward. This function is called when the process for selecting the next winner is initiated
    * @notice only this contract should be able to call this function.
     */
    function resetIdsOfEligiblePosts() private {
        _resetIdsOfEligiblePosts();
    }

    /**
    * @dev this function resets the array containing the ids of recent winning post(s). This function is called when the next winner is just about to be selected
    * @notice only this contract should be able to call this function.
     */
    function resetIdsOfRecentWinningPosts() private {
        _resetIdsOfRecentWinningPosts();
    }

    /**
    * @dev this function adds a postId to the array containing the ids of winning post(s). This function is called whenever a winner is selected
    * @param _idOfWinningPost is the postId to be added to the s_idsOfRecentWinningPosts
    * @notice only this contract should be able to call this function.
     */
    function addIdToIdsOfRecentWinningPosts(uint256 _idOfWinningPost) private {
        _addIdToIdsOfRecentWinningPosts(_idOfWinningPost);
    }

    /**
    * @dev this function resets the array containing the ids of recent post(s). This function is called after a winner is selected. The array is reset so that new posts can be saved in the array for the next selection process. This way, an author doesn't get rewarded more than once on the same post
    * @notice only this contract should be able to call this function.
     */
    function resetIdsOfRecentPosts() private {
        _resetIdsOfRecentPosts();
    }

    //////////////////////
    // Getter Functions //
    //////////////////////

    /**
    * @dev function receives quantity of ether and gives its value in USD
     */
    function getUsdValueOfEthAmount(uint256 _ethAmount)
        public
        view
        returns (uint256)
    {
        return _getUsdValueOfEthAmount(_ethAmount);
    }

    function getIdsOfRecentWinningPosts() public view returns (uint256[] memory) {
        return _getIdsOfRecentWinningPosts();
    }

    function getIdsOfRecentPosts() public view returns (uint256[] memory) {
        return _getIdsOfRecentPosts();
    }

    function getIdsOfEligiblePosts() public view returns (uint256[] memory) {
        return _getIdsOfEligiblePosts();
    }

    /**
    * @dev function retrieves user profile given the userAddress
    * @param _userAddress is the wallet address of user
    * @return function returns the profile of the user
     */
    function getUser(address _userAddress) public view returns (User memory) {
        return _getUser(_userAddress);
    }

    /**
    * @dev function retrieves all posts by a user given the userAddress
    * @param _userAddress is the wallet address of user
    * @return function returns an arry of all posts by the user
     */
    function getUserPosts(address _userAddress)
        public
        view
        returns (Post[] memory)
    {
        return _getUserPosts(_userAddress);
    }

    /**
    * @dev function retrieves user profile given the userId
    * @param _userId is the id of user. userId is unique
    * @return function returns the profile of the user
     */
    function getUserById(uint256 _userId) public view returns (User memory) {
        return _getUserById(_userId);
    }

    function getUserVoteStatus(uint256 _postId) public view returns(bool){
        return _getUserVoteStatus(_postId);
    }

    /**
    * @dev function retrieves all information on a post given the postId
    * @param _postId is the id of the post. The postId is unique
    * @return function returns the post corresponding to that postId
     */
    function getPostById(uint256 _postId) public view returns (Post memory) {
        return _getPostById(_postId);
    }

    /**
    * @dev function retrieves all information about a comment on a post given the postId and the commentId
    * @param _commentId is the id of the comment. 
    * @return function returns the comment corresponding to that postId and commentId
     */
    function getCommentByCommentId(uint256 _commentId)
        public
        view
        returns (Comment memory)
    {
        return _getCommentByCommentId(_commentId);
    }

    /**
    * @dev function retrieves all users that liked a comment on a post given the postId and the commentId
    * @param _commentId is the id of the comment. 
    * @return function returns an array of userAddresses that liked the  comment
     */
    function getCommentLikersByPostIdAndCommentId(
        uint256 _postId,
        uint256 _commentId
    ) public view returns (address[] memory) {
        return _getCommentLikersByPostIdAndCommentId(_postId, _commentId);
    }

    /**
    * @dev function retrieves all comments by a user given the userAddress
    * @param _userAddress is the wallet address of user
    * @return function returns an arry of all comments by the user
     */
    function getUserComments(address _userAddress)
        public
        view
        returns (Comment[] memory)
    {
        return _getUserComments(_userAddress);
    }

    /**
    * @dev function retrieves username(i.e. nickname) of user given the userAddress
    * @param _userAddress is the wallet address of user
    * @notice function returns username(i.e. nickname) of the user
     */
    function getUserNameFromAddress(address _userAddress)
        public
        view
        returns (string memory)
    {
        return _getUserNameFromAddress(_userAddress);
    }

    /**
    * @dev function retrieves userAddress given username(i.e. nickname) of user
    * @param _username is the username or nick name of user
    * @notice function returns wallet address of the user
     */
    function getAddressFromUsername(string memory _username) public view returns(address) {
        return _getAddressFromUsername(_username);
    }
    
    /**
    * @dev This function retrieves all post on the blockchain
     */
    function getAllPosts() public view returns (Post[] memory) {
        return _getAllPosts();
    }

    /**
    * @dev This function retrieves the username of recent winners on the platform
     */
    function getUsernameOfRecentWinners() public returns(string[] memory) {
        return _getUsernameOfRecentWinners();
    }

    /**
    * @dev This function retrieves all recent winning posts on the platform
     */
    function getRecentWinningPosts() public returns(Post[] memory) {
        return _getRecentWinningPosts();
    }

    /**
    * @dev This function retrieves all recent trending posts on the platform. These are posts that have at least the minimum post score
     */
    function getRecentTrendingPosts() public returns(Post[] memory) {
        return _getRecentTrendingPosts();
    }

    // Owner functions
    function getBalance() public view onlyOwner returns (uint256) {
        return address(this).balance;
    }

    function getContractOwner() public view returns (address) {
        return s_owner;
    }

    function transferContractBalance(address payable _to) public onlyOwner {
        _to.transfer(address(this).balance);
    }

    /**
    * @dev function retrieves all comments on a given post
    * @param _postId is the id of the post we want to retrieve its comments
    * @return function returns an arry of all comments on the post
     */
    function getCommentsByPostId(uint256 _postId) public view returns(Comment[] memory) {
        return _getCommentsByPostId(_postId);
    }


}
