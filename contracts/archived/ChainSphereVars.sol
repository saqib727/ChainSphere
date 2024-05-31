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

// import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
// import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
// // import {PriceConverter} from "./PriceConverter.sol";
// import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

// contract ChainSphereVars {
//     // using PriceConverter for uint256;
//     // VRFv2Consumer public vrfConsumer;

//     //////////////
//     /// Errors ///
//     //////////////
//     error ChainSphere__NotOwner();
//     error ChainSphere__NotPostOwner();
//     error ChainSphere__NotCommentOwner();
//     error ChainSphere__UsernameAlreadyTaken();
//     error ChainSphere__UserDoesNotExist();
//     error ChainSphere__OwnerCannotVote();
//     error ChainSphere__AlreadyVoted();
//     error ChainSphere__PaymentNotEnough();
//     error ChainSphere__UpkeepNotNeeded(
//         uint256 balance,
//         uint256 numOfEligibleAuthors
//     );
//     error ChainSphere__TransferFailed();
//     error ChainSphere__BatchTransferFailed(address winner);
//     error ChainSphere__NotProfileOwner();
//     error ChainSphere__PostDoesNotExist();

//     ///////////////////////////////////
//     /// Type Declarations (Structs) ///
//     ///////////////////////////////////

//     /**
//     * @dev This struct stores user information or profile
//     * @param id is uniquely generating id for each user. It can be used to uniquely identify a user
//     * @param userAddress is the wallet address of user. This is the address of the wallet the user used to sign up on the platform
//     * @param nickName is also known as the username of the user. This nickName (username) is unique such that it can be used to uniquely identify a user. This is supplied by the user during registration (sign up).
//     * @param fullNameOfUser is the full name of the user. This does not need to be unique, is supplied by the user during registration (sign up).
//     * @param bio is a short self introduction of the user. This can be used to know who the user is and what their aspirations are.
//     * @param profileImageHash is the hash of the profile image of the user
//      */
//     struct User {
//         uint256 id;
//         address userAddress;
//         string nickName; // must be unique
//         string fullNameOfUser;
//         string bio;
//         string profileImageHash;
//     }

//     /**
//     * @dev the post struct uniquely saves all the relevant information about a post
//     * @param postId is the id of the post. The postId is unique and is used to uniquely identify a post. This number is generated serially as each post is created
//     * @param content is the content of the post
//     * @param imgHash is the hash of the image that may be associated with a post. This is not mandatory as a user may decide to create a post without uploading any image
//     * @param timestamp is the time the post is created.
//     * @param upvotes is the number of upvotes acrued by the post. This indicates how useful other users perceive the post to be. A user cannot vote their own post, a user cannot cast more than one vote on a particular post
//     * @param downvotes is the number of downvotes acrued by the post. This indicates how not useful other users perceive the post to be. A user cannot vote their own post, a user cannot cast more than one vote on a particular post
//     * @param author is the address of the creator (author) of the post. This is useful to track for issuing of rewards for authors whose posts are adjuged as eligible for rewards.
//     * @param authorNickName is the username (nick name) of the creator (author) of the post.
//     * @param authorFullName is the full name of the creator (author) of the post.
//      */
//     struct Post {
//         uint256 postId;
//         string content;
//         string imgHash;
//         uint256 timestamp;
//         uint256 upvotes;
//         uint256 downvotes;
//         address author;
//     }

//     /**
//     * @dev the comment struct uniquely saves all the relevant information about a comment
//     * @param commentId is the id of the comment. The commentId is only unique with respect to each post. This number is generated serially as each comment is created on a post
//     * @param author is the address of the user who commented on the post. This is useful to track for issuing of rewards for authors whose posts are adjuged as eligible for rewards.
//     * @param postId is the id of the post. The postId is unique and is used to uniquely identify a post. This number is generated serially as each post is created
//     * @param content is the content of the comment
//     * @param timestamp is the time the comment was created.
//     * @param likesCount is the number of likes acrued by the comment. This indicates how useful other users perceive the comment to be. 
//      */
//     struct Comment {
//         uint256 commentId;
//         address author;
//         uint256 postId;
//         string content;
//         uint256 timestamp;
//         uint256 likesCount;
//     }

//     ///////////////////////
//     /// State Variables ///
//     ///////////////////////

//     /* For gas efficiency, we declare variables as private and define getter functions for them where necessary */

//     // Imported Variables
//     AggregatorV3Interface public s_priceFeed;

//     // Constants
//     uint256 public constant MINIMUM_USD = 5e18;
//     uint256 public constant MIN_POST_SCORE = 5;
//     uint256 public constant WINNING_REWARD = 0.01 ether;

//     // VRF2 Constants
//     uint16 public constant REQUEST_CONFIRMATIONS = 3;
//     uint32 public constant TEN = 10; // Maximum percentage of winners to be picked out of an array of eligible authors
//     uint32 public constant TWENTY = 20; // Number of eligible authors beyond which a maximum of 10% will be picked for award

//     // VRF2 Immutables
//     // @dev duration of the lottery in seconds
//     uint256 public immutable i_interval; // Period that must pass before a set of posts can be adjudged eligible for reward based on their postScore
//     VRFCoordinatorV2Interface public immutable i_vrfCoordinator;
//     bytes32 public immutable i_gasLane;
//     uint256 public immutable i_subscriptionId;
//     uint32 public immutable i_callbackGasLimit;

//     uint256 public s_lastTimeStamp;
//     // Mappings

//     /** Variables Relating to User */
//     User[] s_users; // array of users
//     mapping(address => User) public s_addressToUserProfile;
//     uint256 userId;
//     mapping(address => uint256) public s_userAddressToId; // gets userId using address of user
//     // mapping(address => string) public s_userAddressToUsername; // gets username (i.e. nickname) using address of user
//     string[] s_userNamesOfRecentWinners;

//     /** Variables Relating to Post */
//     Post[] s_posts; // array of all posts
//     uint256[] s_idsOfRecentPosts; // array of posts that are not more than VALIDITY_PERIOD old. This array is reset anytime authors have been picked for reward.
//     // Post[] s_postsEligibleForReward; // an array of eligible posts for display in the trending section on the frontend
//     mapping(uint256 => Post) public s_idToPost; // get full details of a post using the postId

//     mapping(address => uint256) public s_authorToPostId; // Get postId using address of the author
//     mapping(uint256 => address) public s_postIdToAuthor; // Get the address of the author of a post using the postId

//     mapping(string => address) public s_usernameToAddress; // get user address using their name
//     mapping(address => mapping(uint256 => bool)) public s_hasVoted; //Checks if a user has voted for a post or not
//     mapping(address => Post[]) public s_userPosts; // gets all posts by a user using the user address
//     mapping(uint256 postId => uint256 idInUserPosts) public s_postIdToIdInUserPosts; // mapping postId to the serial number of the post in s_userPosts
//     Post[] s_recentWinningPosts;
//     Post[] s_recentTrendingPosts;

//     /** Variables Relating to Comment */

//     mapping(uint256 => Comment[]) public s_postIdToComments; // gets array of comments on a post using the postId
//     mapping(uint256 => mapping(uint256 => address))
//         public s_postAndCommentIdToAddress; // gets comment author using the postId and commentId

//     mapping(address => Comment[]) public userComments; // gets an array of comments by a user using user address
//     mapping(uint256 => mapping(uint256 => mapping(address => bool)))
//         public s_likedComment; // indicates whether a comment is liked by a user using postId and commentId and userAddress
//     mapping(uint256 => mapping(uint256 => address[])) public s_likersOfComment; // gets an array of likers of a comment using the postId and commentId

//     /** Other Variables */

//     address public s_owner; // would have made this variable immutable but for the changes_Owner function in the contract
//     address[] public s_authorsEligibleForReward; // An array of users eligible for rewards. Addresses are marked payable so that winner can be paid

//     uint256[] public s_idsOfEligiblePosts; // array that holds postId of eligible posts for reward
//     uint256[] public s_idsOfRecentWinningPosts; // array that holds postId of the monst recent winning posts
//     uint32 public s_numOfWords; // number of random words to request from the Chainlink Oracle

//     //////////////
//     /// Events ///
//     //////////////

//     event UserRegistered(
//         uint256 indexed id,
//         address indexed userAddress,
//         string indexed username
//     );
//     event PostCreated(uint256 postId, string authorName);
//     event PostEdited(uint256 postId, string authorName);
//     event CommentCreated(
//         uint256 indexed commentId,
//         string postAuthor,
//         string commentAuthor,
//         uint256 postId
//     );
//     event PostLiked(
//         uint256 indexed postId,
//         address indexed postAuthor,
//         address indexed liker
//     );
//     event Upvoted(uint256 postId, string posthAuthorName, string upvoterName);
//     event Downvoted(
//         uint256 postId,
//         string posthAuthorName,
//         string downvoterName
//     );
//     // Event for rewarding users
//     event RewardSent(address indexed user, uint256 amount);
//     event RequestWinningAuthor(uint256 requestId);
//     event PickedWinner(address winner);

// }
