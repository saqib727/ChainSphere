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

import { PriceConverter } from "./PriceConverter.sol";

contract SocialMedia {
    using PriceConverter for uint256;

    //////////////
    /// Errors ///
    //////////////
    error SocialMedia__NotOwner();
    error SocialMedia__NotPostOwner();
    error SocialMedia__NotCommentOwner();
    error SocialMedia__UsernameAlreadyTaken();
    error SocialMedia__UserDoesNotExist();
    error SocialMedia__OwnerCannotVote();
    error SocialMedia__AlreadyVoted(); 
    
    ///////////////////////////////////
    /// Type Declarations (Structs) ///
    ///////////////////////////////////
    struct User {
        uint256 id;
        address userAddress;
        string name;
        string bio;
        string profileImageHash;
        // Post[] userPosts;
    }
    
    struct Post {
        uint256 postId;
        string content;
        string imgHash;
        uint256 timestamp;
        uint256 upvotes;
        uint256 downvotes;
        address author;
        // Comment[] postComments;
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

    // Mappings
    mapping(address userAddress => User) private s_addressToUserProfile;
    mapping(uint256 postId => Post) private s_idToPost;
    mapping(uint256 commentId => Comment) private s_comments;

    // Map every post to the author using the postId
    mapping(address userAddress => uint256 postId) private s_userAddressToPostId;
    
    /* For gas efficiency, we declare variables as private and define getter functions for them where necessary */
    address private owner; // would have made this variable immutable but for the changeOwner function in the contract
    mapping(string name => address userAddress) private s_usernameToAddress;
    address[] private s_voters;
    mapping(address user => mapping(uint256 postId => bool voteStatus)) private s_hasVoted; //Checks if a user has voted or not
    // Comment[] commentsArray;
    // Post[] postsArray;
    mapping(address user => Post[]) private userPosts; // maps a user address to array of posts
    mapping(address postAuthor => mapping(uint256 postId => Comment[])) private postComments; // maps address of the author of post and postId to array of comments
    mapping(address user => Comment[]) private userComments; // maps a user address to array of comments
    uint256 userId;
    mapping(address userAddress => uint256 userId) private s_userAddressToId;
    
    User[] s_users; // array of users
    Post[] s_posts; // array of posts

    
    //////////////
    /// Events ///
    //////////////

    event UserRegistered(uint256 indexed id, address indexed userAddress, string indexed name);
    event PostCreated(uint256 postId, string authorName);
    event PostEdited(uint256 postId, address author);
    event CommentCreated(uint256 indexed commentId, address indexed postAuthor, address indexed commentAuthor, uint256 postId);
    event PostLiked(uint256 indexed postId, address indexed postAuthor, address indexed liker);
    event Upvoted(uint256 postId, address voter);
    event Downvoted(uint256 postId, address voter);
    
    /////////////////
    /// Modifiers ///
    /////////////////
    modifier onlyOwner() {
        if(msg.sender != owner){
            revert SocialMedia__NotOwner();
        }
        _;
    }
    
    modifier onlyPostOwner(uint _postId) {
        if(msg.sender != s_idToPost[_postId].author){
            revert SocialMedia__NotPostOwner();
        }
        _;
    }
    
    modifier onlyCommentOwner(uint _commentId) {
        if(msg.sender != s_comments[_commentId].author){
            revert SocialMedia__NotCommentOwner();
        }
        _;
    }
    
    modifier usernameTaken(string memory _name) {
        if(s_usernameToAddress[_name] != address(0)){
            revert SocialMedia__UsernameAlreadyTaken();
        }
        _;
    }
    
    modifier checkUserExists(address _userAddress) {
        if(s_addressToUserProfile[_userAddress].userAddress == address(0)){
            revert SocialMedia__UserDoesNotExist();
        }
        _;
    }
    
    modifier notOwner(uint256 _postId) {
        if(msg.sender == s_idToPost[_postId].author){
            revert SocialMedia__OwnerCannotVote();
        }
        _;
    }

    modifier hasNotVoted(uint256 _postId) {
        if(s_hasVoted[msg.sender][_postId]){
           revert SocialMedia__AlreadyVoted(); 
        }
        _;
    }
    
    ///////////////////
    /// Constructor ///
    ///////////////////
    constructor() {
        owner = msg.sender;
    }
    
    /////////////////
    /// Functions ///
    /////////////////

    // The receive function
    /**
    * @dev this function enables the Smart Contract to receive payment
     */
    receive() external payable {}

    function registerUser(string memory _name, string memory _bio, string memory _profileImageHash) public usernameTaken(_name) {
        uint256 id = userId++;
        // For now, this is the way to create a post with empty comments
        User memory newUser;

        newUser.id = id;
        newUser.userAddress = msg.sender;
        newUser.name = _name;
        newUser.bio = _bio;
        newUser.profileImageHash = _profileImageHash;
        s_addressToUserProfile[msg.sender]=newUser;
        s_userAddressToId[msg.sender] = id;

        s_usernameToAddress[_name] = msg.sender;

        // Add user to list of users
        s_users.push(newUser);
        emit UserRegistered(id, msg.sender, _name);
    }
    
    function changeUsername(string memory _newName) public checkUserExists(msg.sender) usernameTaken(_newName) {
        
        // get userId using the user address
        uint256 currentUserId = s_userAddressToId[msg.sender];
        // change user name using their id
        s_users[currentUserId].name = _newName;
    }
    
    /**
    * only a registered user can create posts on the platform
     */
    function createPost(string memory _content, string memory _imgHash) public checkUserExists(msg.sender) {
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
        
        // Add the post to userPosts
        userPosts[msg.sender].push(newPost);
        // Add the post to the array of posts
        s_posts.push(newPost);
        // map post to the author
        s_userAddressToPostId[msg.sender] = postId;
        emit PostCreated(postId, nameOfUser);
    }
    
    /**
    * @dev A user should pay to edit post. The rationale is, to ensure users go through their content before posting since editing of content is not free
    * @notice To effect the payment functionality, we include a receive function to enable the smart contract receive ether. Also, we use Chainlink pricefeed to ensure ether is amount has the required usd equivalent
     */
    function editPost(uint _postId, string memory _content, string memory _imgHash) public onlyPostOwner(_postId) {
        Post storage post = s_idToPost[_postId];
        post.content = _content;
        post.imgHash = _imgHash;
        emit PostEdited(_postId, msg.sender);
    }
    
    function deletePost(uint _postId) public onlyPostOwner(_postId) {
        delete s_idToPost[_postId];
    }
    
    function upvote(uint _postId) public notOwner(_postId) hasNotVoted(_postId) {
        s_idToPost[_postId].upvotes++;
        s_hasVoted[msg.sender][_postId] = true;
        s_voters.push(msg.sender);
        emit Upvoted(_postId, msg.sender);
    }
    
    function downvote(uint _postId) public notOwner(_postId) hasNotVoted(_postId) {
        s_idToPost[_postId].downvotes++;
        s_hasVoted[msg.sender][_postId] = true;
        s_voters.push(msg.sender);
        emit Downvoted(_postId, msg.sender);
    }
    
    /** Deleted the function that used a for loop to determine
    * vote status of user because for loops are not gas efficient in
    * Solidity.
    * Replaced the function with a mapping `s_hasVoted` in the mappings section above.
     */
    
    function getUserPosts(address _userAddress) public view returns(Post[] memory) {
        // Implementation to retrieve all posts by a user
        return userPosts[_userAddress];

    }
    
    function createComment(address _postAuthor, uint _postId, string memory _content) public {
        uint256 commentId = generateCommentId();
        
        Comment memory newComment = Comment({
            commentId: commentId,
            author: msg.sender,
            postId: _postId,
            content: _content,
            timestamp: block.timestamp,
            likesCount: 0
        });
        // s_comments[commentId] = Comment(commentId, msg.sender, _postId, _content, block.timestamp, 0);
        postComments[_postAuthor][_postId].push(newComment);

        // emit CommentCreated(commentId, msg.sender, _postId);
        emit CommentCreated(commentId, _postAuthor, msg.sender, _postId);
    }
    
    function editComment(uint256 _commentId, string memory _content) public onlyCommentOwner(_commentId) {
        Comment storage comment = s_comments[_commentId];
        comment.content = _content;
    }
    
    function deleteComment(uint _commentId) public onlyCommentOwner(_commentId) {
        delete s_comments[_commentId];
    }
    
    function likeComment(uint _commentId) public {
        s_comments[_commentId].likesCount++;
    }
    
    function getUser(address _userAddress) public view returns(User memory) {
        return s_addressToUserProfile[_userAddress];
    }

    function getUserById(uint256 _userId) public view returns(User memory) {
        return s_users[_userId];
    }

    function getPostById(uint256 _postId) public view returns(Post memory) {
        return s_posts[_postId];
    }

    function getUserComments(address _userAddress) public view returns(Comment[] memory) {
        // Implementation to retrieve all comments by a user
        return userComments[_userAddress];
    }
    
    function getUserNameFromAddress(address _userAddress) public view returns(string memory nameOfUser) {
        User memory user = s_addressToUserProfile[_userAddress];
        nameOfUser = user.name;
    }
    // Owner functions
    function getBalance() public view onlyOwner returns(uint) {
        return address(this).balance;
    }
    

    function transferContractBalance(address payable _to) public onlyOwner {
        _to.transfer(address(this).balance);
    }
    
    function stopDapp() public onlyOwner {
        // Implement to stop the Dapp
    }
    
    function startDapp() public onlyOwner {
        // Implement to start the Dapp
    }
    
    function changeOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }
    
    // Internal functions
    function generateUserId() internal pure returns(uint) {
        // Implementation to generate unique user IDs
        return 1;
    }
    
    function generatePostId() internal pure returns(uint) {
        // Implementation to generate unique post IDs
        return 1;
    }
    
    function generateCommentId() internal  pure returns(uint) {
        // Implementation to generate unique comment IDs
        return 1;
    }
}
