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

/// @dev Implements Chainlink VRFv2, Automation and Price Feed

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract SocialMedia is VRFConsumerBaseV2 {
    using PriceConverter for uint256;
    // VRFv2Consumer public vrfConsumer;

    //////////////
    /// Errors ///
    //////////////
    error SocialMedia__NotOwner();
    error SocialMedia_postnotExists();
    error SocialMedia_commentnotExists();
    error SocialMedia__NotPostOwner();
    error SocialMedia__NotCommentOwner();
    error SocialMedia__UsernameAlreadyTaken();
    error SocialMedia__UserDoesNotExist();
    error SocialMedia__OwnerCannotVote();
    error SocialMedia__AlreadyVoted();
    error SocialMedia__PaymentNotEnough();
    error SocialMedia__UpkeepNotNeeded(
        uint256 balance,
        uint256 numOfEligibleAuthors
    );
    error SocialMedia__TransferFailed();
    error SocialMedia__BatchTransferFailed(address winner);
    error SocialMedia__NotProfileOwner();

    ///////////////////////////////////
    /// Type Declarations (Structs) ///
    ///////////////////////////////////
    struct User {
        uint256 id;
        address userAddress;
        string name;
        string Username;
        string bio;
        string profileImageHash;
    }

    struct Post {
        uint256 postId;
        string content;
        string imgHash;
        uint256 timestamp;
        uint256 upvotes;
        uint256 downvotes;
        address author;
    }

    struct Comment {
        uint256 commentId;
        address author;
        uint256 postId;
        string content;
        uint256 timestamp;
        uint256 likesCount;
    }

    ///////////////////////
    /// State Variables ///
    ///////////////////////

    /* For gas efficiency, we declare variables as private and define getter functions for them where necessary */

    // Imported Variables
    AggregatorV3Interface private s_priceFeed;

    // Constants
    uint256 private constant MINIMUM_USD = 5e18;
    uint256 private constant MIN_POST_SCORE = 5;
    uint256 private constant WINNING_REWARD = 0.01 ether;

    // VRF2 Constants
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant TEN = 10; // Maximum percentage of winners to be picked out of an array of eligible authors
    uint32 private constant TWENTY = 20; // Number of eligible authors beyond which a maximum of 10% will be picked for award

    // VRF2 Immutables
    // @dev duration of the lottery in seconds
    uint256 private immutable i_interval; // Period that must pass before a set of posts can be adjudged eligible for reward based on their postScore
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;

    uint256 private s_lastTimeStamp;
    // Mappings

    /** Variables Relating to User */
    User[] s_users; // array of users
    mapping(address => User) private s_addressToUserProfile;
    uint256 userId;
    mapping(address => uint256) private s_userAddressToId; // gets userId using address of user

    /** Variables Relating to Post */
    Post[] s_posts; // array of all posts
    uint256[] s_idsOfRecentPosts; // array of posts that are not more than VALIDITY_PERIOD old. This array is reset anytime authors have been picked for reward.
    Post[] s_postsEligibleForReward; // an array of eligible posts for display in the trending section on the frontend
    mapping(uint256 => Post) private s_idToPost; // get full details of a post using the postId

    mapping(address => uint256) private s_authorToPostId; // Get postId using address of the author
    mapping(uint256 => address) private s_postIdToAuthor; // Get the address of the author of a post using the postId

    mapping(string => address) private s_usernameToAddress; // get user address using their name
    mapping(address => mapping(uint256 => bool)) private s_hasVoted; //Checks if a user has voted for a post or not
    mapping(address => Post[]) private userPosts; // gets all posts by a user using the user address

    /** Variables Relating to Comment */

    mapping(uint256 => Comment[]) private s_postIdToComments; // gets array of comments on a post using the postId
    mapping(uint256 => mapping(uint256 => address))
        private s_postAndCommentIdToAddress; // gets comment author using the postId and commentId

    mapping(address => Comment[]) private userComments; // gets an array of comments by a user using user address
    mapping(uint256 => mapping(uint256 => mapping(address => bool)))
        private s_likedComment; // indicates whether a comment is liked by a user using postId and commentId and userAddress
    mapping(uint256 => mapping(uint256 => address[])) private s_likersOfComment; // gets an array of likers of a comment using the postId and commentId

    /** Other Variables */

    address private s_owner; // would have made this variable immutable but for the changes_Owner function in the contract
    address[] private s_authorsEligibleForReward; // An array of users eligible for rewards. Addresses are marked payable so that winner can be paid

    uint256[] private s_idsOfEligiblePosts; // array that holds postId of eligible posts for reward
    uint256[] private s_idsOfRecentWinningPosts; // array that holds postId of the monst recent winning posts
    uint32 private s_numOfWords; // number of random words to request from the Chainlink Oracle

    //////////////
    /// Events ///
    //////////////

    event UserRegistered(
        uint256 indexed id,
        address indexed userAddress,
        string indexed username
    );
    event PostCreated(uint256 postId, string authorName);
    event PostEdited(uint256 postId, string authorName);
    event CommentCreated(
        uint256 indexed commentId,
        string postAuthor,
        string commentAuthor,
        uint256 postId
    );
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
    modifier onlyOwner() {
        if (msg.sender != s_owner) {
            revert SocialMedia__NotOwner();
        }
        _;
    }

    modifier onlyPostOwner(uint256 _postId) {
        if (_postId >= s_posts.length) {
            revert SocialMedia_postnotExists();
        }

        if (msg.sender != s_postIdToAuthor[_postId]) {
            revert SocialMedia__NotPostOwner();
        }
        _;
    }

    modifier onlyCommentOwner(uint256 _postId, uint256 _commentId) {
        if (_postId >= s_posts.length) {
            revert SocialMedia_postnotExists();
        }
        if (_commentId >= s_postIdToComments[_postId].length) {
            revert SocialMedia_commentnotExists();
        }
        if (msg.sender != s_postAndCommentIdToAddress[_postId][_commentId]) {
            revert SocialMedia__NotCommentOwner();
        }
        _;
    }

    modifier usernameTaken(string memory _username) {
        if (s_usernameToAddress[_username] != address(0)) {
            revert SocialMedia__UsernameAlreadyTaken();
        }
        _;
    }

    modifier checkUserExists(address _userAddress) {
        if (s_addressToUserProfile[_userAddress].userAddress == address(0)) {
            revert SocialMedia__UserDoesNotExist();
        }
        _;
    }

    modifier notOwner(uint256 _postId) {
        if (msg.sender == s_postIdToAuthor[_postId]) {
            revert SocialMedia__OwnerCannotVote();
        }
        _;
    }

    modifier hasNotVoted(uint256 _postId) {
        if (s_hasVoted[msg.sender][_postId]) {
            revert SocialMedia__AlreadyVoted();
        }
        _;
    }

    modifier hasPaid() {
        if (msg.value.getConversionRate(s_priceFeed) < MINIMUM_USD) {
            revert SocialMedia__PaymentNotEnough();
        }
        _;
    }

    modifier onlyProfileOwner(uint256 _userId) {
        // check if msg.sender is the profile owner
        if (msg.sender != getUserById(_userId).userAddress) {
            revert SocialMedia__NotProfileOwner();
        }
        _;
    }

    modifier postExists(uint256 _postID) {
        if (_postID >= s_posts.length) {
            revert SocialMedia_postnotExists();
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
        uint64 subscriptionId,
        uint32 callbackGasLimit,
        address link,
        uint256 deployerKey
    ) VRFConsumerBaseV2(vrfCoordinator) {
        s_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
        i_interval = interval;
        s_lastTimeStamp = block.timestamp;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinator);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
    }

    /////////////////
    /// Functions ///
    /////////////////

    // The receive function
    /**
     * @dev this function enables the Smart Contract to receive payment
     */
    receive() external payable {}

    fallback() external payable {}

    function registerUser(string memory _name, string memory _username)
        public
        usernameTaken(_username)
    {
        uint256 id = userId++;
        // For now, this is the way to create a post with empty comments
        User memory newUser;

        newUser.id = id;
        newUser.userAddress = msg.sender;
        newUser.name = _name;
        newUser.Username = _username;
        newUser.bio = ""; //user will edit in editmy profile
        newUser.profileImageHash = ""; //user will edit in editmyprofile
        s_addressToUserProfile[msg.sender] = newUser;
        s_userAddressToId[msg.sender] = id;

        s_usernameToAddress[_username] = msg.sender;

        // Add user to list of users
        s_users.push(newUser);
        emit UserRegistered(id, msg.sender, _username);
    }

    function changeUsername(uint256 _userId, string memory _newName)
        public
        checkUserExists(msg.sender)
        onlyProfileOwner(_userId)
        usernameTaken(_newName)
    {
        // get userId using the user address
        // uint256 currentUserId = _userId;
        // change user name using their id
        s_users[_userId].Username = _newName;
    }

    function editMyProfile(
        uint256 _userId,
        string memory _bio,
        string memory _profileImageHash,
        string memory _name
    ) public checkUserExists(msg.sender) onlyProfileOwner(_userId) {
        User storage user = s_users[_userId];
        user.bio = _bio;
        user.profileImageHash = _profileImageHash;
        user.name = _name;
    }

    /**
     * only a registered user can create posts on the platform
     */
    function createPost(string memory _content, string memory _imgHash)
        public
        checkUserExists(msg.sender)
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
            author: msg.sender
        });

        string memory nameOfUser = getUserNameFromAddress(msg.sender);

        userPosts[msg.sender].push(newPost); // Add the post to userPosts
        s_posts.push(newPost); // Add the post to the array of posts
        s_idsOfRecentPosts.push(newPost.postId); // Add the postId to the array of ids of recent posts for possible nomination for reward
        s_authorToPostId[msg.sender] = postId; // map post to the author
        s_postIdToAuthor[postId] = msg.sender;
        emit PostCreated(postId, nameOfUser);
    }

    /**
     * @dev A user should pay to edit post. The rationale is, to ensure users go through their content before posting since editing of content is not free
     * @notice To effect the payment functionality, we include a receive function to enable the smart contract receive ether. Also, we use Chainlink pricefeed to ensure ether is amount has the required usd equivalent
     */
    function editPost(
        uint256 _postId,
        string memory _content,
        string memory _imgHash
    ) public onlyPostOwner(_postId) {
        s_posts[_postId].content = _content;
        s_posts[_postId].imgHash = _imgHash;
        string memory nameOfUser = getUserNameFromAddress(msg.sender);
        emit PostEdited(_postId, nameOfUser);
    }

    function deletePost(uint256 _postId)
        public
        payable
        onlyPostOwner(_postId)
        hasPaid
    {
        // delete the content of post by
        s_posts[_postId].content = "";
        s_posts[_postId].author = address(0);
    }

    function upvote(uint256 _postId)
        public
        notOwner(_postId)
        hasNotVoted(_postId)
    {
        s_posts[_postId].upvotes++;
        s_hasVoted[msg.sender][_postId] = true;
        // s_voters.push(msg.sender);
        address postAuthAddress = s_postIdToAuthor[_postId];
        string memory postAuthorName = getUserNameFromAddress(postAuthAddress);
        string memory upvoter = getUserNameFromAddress(msg.sender);

        emit Upvoted(_postId, postAuthorName, upvoter);
    }

    function downvote(uint256 _postId)
        public
        notOwner(_postId)
        hasNotVoted(_postId)
    {
        s_posts[_postId].downvotes++;
        s_hasVoted[msg.sender][_postId] = true;
        // s_voters.push(msg.sender);
        address postAuthAddress = s_postIdToAuthor[_postId];
        string memory postAuthorName = getUserNameFromAddress(postAuthAddress);
        string memory downvoterName = getUserNameFromAddress(msg.sender);

        emit Downvoted(_postId, postAuthorName, downvoterName);
    }

    /**
     * @dev createComment enables registered users to comment on any post
     * @notice Since the postId is unique and can be mapped to author of the post, we only need the postId to uniquely reference any post in order to comment on it
     * Because in any social media platform there are so much more comments than posts, we allow the commentId not to be unique in general. However, comment ids are unique relative to any given post. Our thought is that this will prevent overflow
     */
    function createComment(uint256 _postId, string memory _content)
        public
        checkUserExists(msg.sender)
        postExists(_postId)
    {
        //
        uint256 commentId = s_postIdToComments[_postId].length;

        Comment memory newComment = Comment({
            commentId: commentId,
            author: msg.sender,
            postId: _postId,
            content: _content,
            timestamp: block.timestamp,
            likesCount: 0
        });
        // s_comments[commentId] = Comment(commentId, msg.sender, _postId, _content, block.timestamp, 0);
        string memory postAuthor = getUserById(_postId).Username;
        string memory commenter = getUserNameFromAddress(msg.sender);

        s_postAndCommentIdToAddress[_postId][commentId] = msg.sender;
        s_postIdToComments[_postId].push(newComment);

        emit CommentCreated(commentId, postAuthor, commenter, _postId);
    }

    /**
     * @dev only the user who created a comment should be able to edit it.
     */
    function editComment(
        uint256 _postId,
        uint256 _commentId,
        string memory _content
    ) public onlyCommentOwner(_postId, _commentId) {
        // get the comment from the Blockchain (call by reference) and update it
        s_postIdToComments[_postId][_commentId].content = _content;
    }

    /**
     * @dev only the user who created a comment should be able to delete it. Also, a user should pay to delete their post
     */
    function deleteComment(uint256 _postId, uint256 _commentId)
        public
        payable
        onlyCommentOwner(_postId, _commentId)
        hasPaid
    {
        // get the comment from the Blockchain (call by reference) and update it
        s_postIdToComments[_postId][_commentId].content = ""; // delete content
        s_postIdToComments[_postId][_commentId].author = address(0); // delete address of comment author
    }

    function likeComment(uint256 _postId, uint256 _commentId)
        public
        checkUserExists(msg.sender)
    {
        // retrieve the comment from the Blockchain in increment number of likes
        s_postIdToComments[_postId][_commentId].likesCount++;
        // There is need to note the users that like a comment
        s_likedComment[_postId][_commentId][msg.sender] = true;
        // Add liker to an array of users that liked the comment
        s_likersOfComment[_postId][_commentId].push(msg.sender);
    }

    ///////////////////////
    // Private Functions //
    ///////////////////////

    /**
     * @dev This function checks the the number of upvotes and number of downvotes of a post, calculates their difference to tell if the author of the post is eligible for rewards in that period.
     * @notice A user can be adjudged eligible on multiple grounds if they have multiple posts with significantly more number of upvotes than downvotes
     */
    function _isPostEligibleForReward(uint256 _postId)
        private
        view
        returns (bool isEligible)
    {
        uint256 numOfUpvotes = getPostById(_postId).upvotes; // get number of upvotes of post
        uint256 numOfDownvotes = getPostById(_postId).downvotes; // get number of downvotes of post
        uint256 postScore = numOfUpvotes - numOfDownvotes > 0
            ? numOfUpvotes - numOfDownvotes
            : 0; // set minimum postScore to zero. We dont want negative values
        isEligible = postScore >= MIN_POST_SCORE ? true : false; // a post is adjudged eligible for reward if the post has ten (10) more upvotes than downvotes
    }

    /**
     * @dev This function is to be called automatically using Chainlink Automation every VALIDITY_PERIOD (i.e. 30 days or as desirable). The function loops through an array of recentPosts and checks if posts are eligible for rewards and add the corresponding authors to an array of eligible authors for reward
     */
    function _pickIdsOfEligiblePosts() internal {
        uint256 len = s_idsOfRecentPosts.length; // number of recent posts
        uint256 i; // define the counter variable

        /** Loop through the array and pick posts that are eligible for reward */
        for (i; i < len; ) {
            // Check if author is eligible for rewards and add their address to the array of eligible users

            if (_isPostEligibleForReward(s_idsOfRecentPosts[i])) {
                s_idsOfEligiblePosts.push(s_idsOfRecentPosts[i]);
            }

            unchecked {
                i++;
            }
        }

        // return s_idsOfEligiblePosts;
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
        // call the _pickEligibleAuthors function to determine authors that are eligible for reward
        _pickIdsOfEligiblePosts(); // this updates the s_idsOfEligiblePosts array

        bool timeHasPassed = (block.timestamp - s_lastTimeStamp) >= i_interval; // checks if enough time has passed
        bool hasBalance = address(this).balance > 0; // Contract has ETH
        bool hasAuthors = s_idsOfEligiblePosts.length > 0; // Contract has players
        upkeepNeeded = (timeHasPassed && hasBalance && hasAuthors);
        return (upkeepNeeded, "0x0");
    }

    function performUpkeep(
        bytes calldata /* performData */
    ) external {
        // Checks

        (bool upkeepNeeded, ) = CheckUpkeep(" ");
        if (!upkeepNeeded) {
            revert SocialMedia__UpkeepNotNeeded(
                address(this).balance,
                s_idsOfEligiblePosts.length
            );
        }

        // Effects (on our Contract)

        // 1. Request RNG from VRF
        // 2. Receive the random number generated

        // Interactions (with other Contracts)
        s_numOfWords = s_idsOfEligiblePosts.length <= TWENTY
            ? 1
            : uint32(s_idsOfEligiblePosts.length % TEN); // Pick one winner or a max ten percent of eligible winners

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

        s_idsOfRecentWinningPosts = new uint256[](0); // reset array of postId of most recent winning posts

        if (randomWords.length == 1) {
            uint256 ranNumber = randomWords[0] % s_idsOfEligiblePosts.length;
            uint256 idOfWinningPost = s_idsOfEligiblePosts[ranNumber]; // get the postId
            s_idsOfRecentWinningPosts.push(idOfWinningPost);
            address payable winner = payable(
                getPostById(idOfWinningPost).author
            );

            // reset the s_recentPosts array
            s_idsOfRecentPosts = new uint256[](0); // reset the array of recent posts
            s_lastTimeStamp = block.timestamp; // reset the timer for the next interval of posts to be considered

            emit PickedWinner(winner);

            // Interactions (With other Contracts)

            // pay the winner
            (bool success, ) = winner.call{value: WINNING_REWARD}("");
            if (!success) {
                revert SocialMedia__TransferFailed();
            }
        } else {
            uint256 len = randomWords.length;
            uint256 i;
            for (i; i < len; ) {
                uint256 ranNumber = randomWords[i] %
                    s_idsOfEligiblePosts.length;
                uint256 idOfWinningPost = s_idsOfEligiblePosts[ranNumber]; // get the postId
                s_idsOfRecentWinningPosts.push(idOfWinningPost);
                address payable winner = payable(
                    getPostById(idOfWinningPost).author
                );

                emit PickedWinner(winner);

                // Interactions (With other Contracts)

                // pay the winner
                (bool success, ) = winner.call{value: WINNING_REWARD}("");
                if (!success) {
                    revert SocialMedia__BatchTransferFailed(winner);
                }

                unchecked {
                    i++;
                }
            }
        }
    }

    //////////////////////
    // Getter Functions //
    //////////////////////

    function getUsdValueOfEthAmount(uint256 _ethAmount)
        public
        view
        returns (uint256)
    {
        uint256 usdValue = _ethAmount.getConversionRate(s_priceFeed);
        return usdValue;
    }

    function getRecentWinners() public view returns (uint256[] memory) {
        return s_idsOfRecentWinningPosts;
    }

    function getIdsOfRecentPosts() public view returns (uint256[] memory) {
        return s_idsOfRecentPosts;
    }

    function getIdsOfEligiblePosts() public view returns (uint256[] memory) {
        return s_idsOfEligiblePosts;
    }

    function getUser(address _userAddress) public view returns (User memory) {
        return s_addressToUserProfile[_userAddress];
    }

    function getUserPosts(address _userAddress)
        public
        view
        returns (Post[] memory)
    {
        // Implementation to retrieve all posts by a user
        return userPosts[_userAddress];
    }

    function getUserById(uint256 _userId) public view returns (User memory) {
        return s_users[_userId];
    }

    function getPostById(uint256 _postId) public view returns (Post memory) {
        return s_posts[_postId];
    }

    function getCommentByPostIdAndCommentId(uint256 _postId, uint256 _commentId)
        public
        view
        returns (Comment memory)
    {
        return s_postIdToComments[_postId][_commentId];
    }

    function getCommentLikersByPostIdAndCommentId(
        uint256 _postId,
        uint256 _commentId
    ) public view returns (address[] memory) {
        return s_likersOfComment[_postId][_commentId];
    }

    function getUserComments(address _userAddress)
        public
        view
        returns (Comment[] memory)
    {
        // Implementation to retrieve all comments by a user
        return userComments[_userAddress];
    }

    function getUserNameFromAddress(address _userAddress)
        public
        view
        returns (string memory nameOfUser)
    {
        User memory user = s_addressToUserProfile[_userAddress];
        nameOfUser = user.Username;
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

    function changeOwner(address _newOwner) public onlyOwner {
        s_owner = _newOwner;
    }

    function getAllPosts() public view returns (Post[] memory) {
        return s_posts;
    }
}
