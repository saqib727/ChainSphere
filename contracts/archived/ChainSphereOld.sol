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
// import {PriceConverter} from "./PriceConverter.sol";
// import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
// import { ChainSphereVars as CSVars}  from "./ChainSphereVars.sol";

// contract ChainSphere is VRFConsumerBaseV2, CSVars {
//     using PriceConverter for uint256;
//     // VRFv2Consumer public vrfConsumer;

//     /////////////////
//     /// Modifiers ///
//     /////////////////

//     modifier onlyOwner() {
//         if (msg.sender != getContractOwner()) {
//             revert ChainSphere__NotOwner();
//         }
//         _;
//     }

//     modifier onlyPostOwner(uint256 _postId) {
//         if (msg.sender != getPostById(_postId).author) {
//             revert ChainSphere__NotPostOwner();
//         }
//         _;
//     }

//     modifier onlyCommentOwner(uint256 _postId, uint256 _commentId) {
//         if (msg.sender != getCommentByPostIdAndCommentId(_postId, _commentId).author) {
//             revert ChainSphere__NotCommentOwner();
//         }
//         _;
//     }

//     modifier usernameTaken(string memory _username) {
//         if (getAddressFromUsername(_username) != address(0)) {
//             revert ChainSphere__UsernameAlreadyTaken();
//         }
//         _;
//     }

//     modifier checkUserExists(address _userAddress) {
//         if (getUser(_userAddress).userAddress == address(0)) {
//             revert ChainSphere__UserDoesNotExist();
//         }
//         _;
//     }

//     modifier notOwner(uint256 _postId) {
//         if (msg.sender == getPostById(_postId).author) {
//             revert ChainSphere__OwnerCannotVote();
//         }
//         _;
//     }

//     modifier hasNotVoted(uint256 _postId) {
//         if (getUserVoteStatus(_postId)) {
//             revert ChainSphere__AlreadyVoted();
//         }
//         _;
//     }

//     modifier hasPaid() {
//         if (msg.value.getConversionRate(s_priceFeed) < MINIMUM_USD) {
//             revert ChainSphere__PaymentNotEnough();
//         }
//         _;
//     }

//     modifier onlyProfileOwner(uint256 _userId) {
//         // check if msg.sender is the profile owner
//         if (msg.sender != getUserById(_userId).userAddress) {
//             revert ChainSphere__NotProfileOwner();
//         }
//         _;
//     }

//     modifier postExists(uint256 _postId) {
//         if(getPostById(_postId).author == address(0)){
//             revert ChainSphere__PostDoesNotExist();
//         }
//         _;
//     }

//     ///////////////////
//     /// Constructor ///
//     ///////////////////
//     constructor(
//         address priceFeed,
//         uint256 interval,
//         address vrfCoordinator,
//         bytes32 gasLane,
//         uint256 subscriptionId,
//         uint32 callbackGasLimit,
//         address link,
//         uint256 deployerKey
//     ) VRFConsumerBaseV2(vrfCoordinator) {
//         CSVars.s_owner = msg.sender;
//         CSVars.s_priceFeed = AggregatorV3Interface(priceFeed);
//         CSVars.i_interval = interval;
//         CSVars.s_lastTimeStamp = block.timestamp;
//         CSVars.i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinator);
//         CSVars.i_gasLane = gasLane;
//         CSVars.i_subscriptionId = subscriptionId;
//         CSVars.i_callbackGasLimit = callbackGasLimit;
//     }

//     /////////////////
//     /// Functions ///
//     /////////////////

//     // The receive function
//     /**
//      * @dev this function enables the Smart Contract to receive payment
//      */
//     receive() external payable {}

//     fallback() external payable {}

//     /**
//     * @dev This function enables a user to be registered on ChainSphere
//     * @param _fullNameOfUser is the full name of the User
//     * @param _username is the user's nick name which must be unique. No two accounts are allowed to have the same nick name
//      */
//     function registerUser(string memory _fullNameOfUser, string memory _username)
//         public
//         usernameTaken(_username)
//     {
//         uint256 id = userId++;
//         // For now, this is the way to create a post with empty comments
//         User memory newUser;

//         newUser.id = id;
//         newUser.userAddress = msg.sender;
//         newUser.fullNameOfUser = _fullNameOfUser;
//         newUser.nickName = _username;
//         CSVars.s_addressToUserProfile[msg.sender] = newUser;
//         CSVars.s_userAddressToId[msg.sender] = id;

//         CSVars.s_usernameToAddress[_username] = msg.sender;
//         // CSVars.s_userAddressToUsername[msg.sender] = _username;

//         // Add user to list of users
//         s_users.push(newUser);
//         emit UserRegistered(id, msg.sender, _username);
//     }

//     /**
//     * @dev this function allows a user to change thier nick name
//     * @param _userId is the id of the user which is a unique number
//     * @param _newNickName is the new nick name the user wishes to change to
//     * @notice the function checks if the caller is the owner of the profile and if _newNickName is not registered on the platform yet
//      */
//     function changeUsername(uint256 _userId, string memory _newNickName)
//         public
//         checkUserExists(msg.sender)
//         onlyProfileOwner(_userId)
//         usernameTaken(_newNickName)
//     {
//         // get userId using the user address
//         // uint256 currentUserId = _userId;
//         // change user name using their id
//         s_users[_userId].nickName = _newNickName;
//     }

//     /**
//     * @dev this function allows a user to edit their profile
//     * @param _userId is the id of the user which is a unique number
//     * @param _bio is a short self introduction about the user
//     * @param _profileImageHash is a hash of the profile image uploaded by the user
//     * @param _newName is the new full name of the user
//     * @notice the function checks if the caller is registered and is the owner of the profile 
//     * @notice it is not mandatory for all parameters to be supplied before calling the function. If any parameter is not supplied, that portion of the user profile is not updated
//      */
//     function editUserProfile(
//         uint256 _userId,
//         string memory _bio,
//         string memory _profileImageHash,
//         string memory _newName
//     ) public checkUserExists(msg.sender) onlyProfileOwner(_userId) {

//         if(keccak256(abi.encode(_bio)) != keccak256(abi.encode(""))){
//             CSVars.s_users[_userId].bio = _bio; // bio is only updated if supplied by user
//         }

//         if(keccak256(abi.encode(_profileImageHash)) != keccak256(abi.encode(""))){
//             CSVars.s_users[_userId].profileImageHash = _profileImageHash; // profileImageHash is only updated if supplied by user
//         }
        
//         if(keccak256(abi.encode(_profileImageHash)) != keccak256(abi.encode(""))){
//             CSVars.s_users[_userId].fullNameOfUser = _newName; // fullNameOfUser is only updated if supplied by user
//         }
//     }

//     /**
//      * @dev This function allows only a registered user to create posts on the platform
//      * @param _content is the content of the post by user
//      * @param _imgHash is the hash of the image uploaded by the user
//      */
//     function createPost(string memory _content, string memory _imgHash)
//         public
//         checkUserExists(msg.sender)
//     {
//         // generate id's for posts in a serial manner
//         uint256 postId = CSVars.s_posts.length;

//         // Initialize an instance of a post for the user
//         Post memory newPost = Post({
//             postId: postId,
//             content: _content,
//             imgHash: _imgHash,
//             timestamp: block.timestamp,
//             upvotes: 0,
//             downvotes: 0,
//             author: msg.sender
//         });

//         string memory nameOfUser = getUserNameFromAddress(msg.sender);

//         // task: create a mapping that links postId to idInUserPosts
//         uint256 idInUserPosts = CSVars.s_userPosts[msg.sender].length;
//         CSVars.s_userPosts[msg.sender].push(newPost); // Add the post to CSVars.s_userPosts
//         CSVars.s_postIdToIdInUserPosts[newPost.postId] = idInUserPosts; // map the postId to idInUserPosts
//         CSVars.s_posts.push(newPost); // Add the post to the array of posts
//         CSVars.s_idsOfRecentPosts.push(newPost.postId); // Add the postId to the array of ids of recent posts for possible nomination for reward
//         CSVars.s_authorToPostId[msg.sender] = postId; // map post to the author
//         CSVars.s_postIdToAuthor[postId] = msg.sender;
//         emit PostCreated(postId, nameOfUser);
//     }

//     /**
//      * @dev This function allows only the owner of a post to edit their post
//      * @param _postId is the id of the post to be edited
//      * @param _content is the content of the post by user
//      * @param _imgHash is the hash of the image uploaded by the user. This is optional
//      * 
//      */
//     function editPost(
//         uint256 _postId,
//         string memory _content,
//         string memory _imgHash
//     ) public onlyPostOwner(_postId) {
//         CSVars.s_posts[_postId].content = _content;
//         if(keccak256(abi.encode(_imgHash)) != keccak256(abi.encode(""))){
//             CSVars.s_posts[_postId].imgHash = _imgHash; // this is only triggered if the picture of the post is changed
//         }
//         string memory nameOfUser = getUserNameFromAddress(msg.sender);
//         emit PostEdited(_postId, nameOfUser);
//     }

//     /**
//      * @dev A user should pay to delete post. The rationale is, to ensure users go through their content before posting since deleting of content is not free
//      * @param _postId is the id of the post to be deleted
//      * @notice The function checks if the user has paid the required fee for deleting post before proceeding with the action. To effect the payment functionality, we include a receive function to enable the smart contract receive ether. Also, we use Chainlink pricefeed to ensure ether is amount has the required usd equivalent
//      */
//     function deletePost(uint256 _postId)
//         public
//         payable
//         onlyPostOwner(_postId)
//         hasPaid
//     {
//         address currentUser  = CSVars.s_posts[_postId].author;
//         // reset the post
//         CSVars.s_posts[_postId] = Post({
//             postId: _postId,
//             content: "",
//             imgHash: "",
//             timestamp: 0,
//             upvotes: 0,
//             downvotes: 0,
//             author: address(0)
//         });
//         // reset previous mappings
//         CSVars.s_postIdToAuthor[_postId] = address(0); // undo the initial mapping
//         CSVars.s_authorToPostId[address(0)] = _postId; // undo the initial mapping
//         uint256 idOfPostInArray = CSVars.s_postIdToIdInUserPosts[_postId];
//         CSVars.s_userPosts[currentUser][idOfPostInArray].author = address(0); // reset author address to address 0
//         CSVars.s_userPosts[currentUser][idOfPostInArray].content = ""; // reset content to empty string
//         // ? How do we remove post from CSVars.s_userPosts array?
//     }

//     /**
//     * @dev This function allows a registered user to give an upvote to a post
//     * @param _postId is the id of the post for which user wishes to give an upvote
//     * @notice no user should be able to vote for their post. No user should vote for the same post more than once
//     * @notice the function increments the number of upvotes for the post by 1, sets the callers voting status for the post as true and emits event that post has received an upvote from the user
//      */
//     function upvote(uint256 _postId)
//         public
//         notOwner(_postId)
//         hasNotVoted(_postId)
//     {
//         CSVars.s_posts[_postId].upvotes++;
//         CSVars.s_hasVoted[msg.sender][_postId] = true;
//         // s_voters.push(msg.sender);
//         address postAuthAddress = CSVars.s_postIdToAuthor[_postId];
//         string memory postAuthorName = getUserNameFromAddress(postAuthAddress);
//         string memory upvoter = getUserNameFromAddress(msg.sender);

//         emit Upvoted(_postId, postAuthorName, upvoter);
//     }

//     /**
//     * @dev This function allows a registered user to give a downvote to a post
//     * @param _postId is the id of the post for which user wishes to give a downvote
//     * @notice no user should be able to vote for their post. No user should vote for the same post more than once
//     * @notice the function increments the number of downvotes for the post by 1, sets the callers voting status for the post as true and emits event that post has received a downvote from the user
//      */
//     function downvote(uint256 _postId)
//         public
//         notOwner(_postId)
//         hasNotVoted(_postId)
//     {
//         CSVars.s_posts[_postId].downvotes++;
//         CSVars.s_hasVoted[msg.sender][_postId] = true;
//         // s_voters.push(msg.sender);
//         address postAuthAddress = CSVars.s_postIdToAuthor[_postId];
//         string memory postAuthorName = getUserNameFromAddress(postAuthAddress);
//         string memory downvoterName = getUserNameFromAddress(msg.sender);

//         emit Downvoted(_postId, postAuthorName, downvoterName);
//     }

//     /**
//      * @dev createComment enables registered users to comment on any post
//      * @notice Since the postId is unique and can be mapped to author of the post, we only need the postId to uniquely reference any post in order to comment on it
//      * Because in any social media platform there are so much more comments than posts, we allow the commentId not to be unique in general. However, comment ids are unique relative to any given post. Our thought is that this will prevent overflow
//      */
//     function createComment(uint256 _postId, string memory _content)
//         public
//         checkUserExists(msg.sender) postExists(_postId)
//     {
        
//         uint256 _commentId = CSVars.s_postIdToComments[_postId].length;

//         Comment memory newComment = Comment({
//             commentId: _commentId,
//             author: msg.sender,
//             postId: _postId,
//             content: _content,
//             timestamp: block.timestamp,
//             likesCount: 0
//         });
        
//         string memory postAuthor = getUserById(_postId).nickName;
//         string memory commenter = getUserNameFromAddress(msg.sender);

//         CSVars.s_postAndCommentIdToAddress[_postId][_commentId] = msg.sender;
//         CSVars.s_postIdToComments[_postId].push(newComment);

//         emit CommentCreated(_commentId, postAuthor, commenter, _postId);
//     }

//     /**
//      * @dev This function allows only the user who created a comment to edit it.
//      * @param _postId is the id of the post which was commented
//      * @param _commentId is the id of the comment of interest
//      * @param _content is the new content of the comment
//      */
//     function editComment(
//         uint256 _postId,
//         uint256 _commentId,
//         string memory _content
//     ) public onlyCommentOwner(_postId, _commentId) {
//         // get the comment from the Blockchain (call by reference) and update it
//         CSVars.s_postIdToComments[_postId][_commentId].content = _content;
//     }

//     /**
//      * @dev This function allows only the user who created a comment to delete it. 
//      * @param _postId is the id of the post which was commented
//      * @param _commentId is the id of the comment of interest
//      * @notice the function checks if the caller is the owner of the comment and has paid the fee for deleting comment
//      */
//     function deleteComment(uint256 _postId, uint256 _commentId)
//         public
//         payable
//         onlyCommentOwner(_postId, _commentId)
//         hasPaid
//     {
//         // get the comment from the Blockchain (call by reference) and update it
//         CSVars.s_postIdToComments[_postId][_commentId].content = ""; // delete content
//         CSVars.s_postIdToComments[_postId][_commentId].author = address(0); // delete address of comment author
//     }

//     /**
//     * @dev this function allows a registered user to like any comment
//     * @param _postId is the id of the post commented
//     * @param _commentId is the id of the comment in question
//     * @notice the function increments the number of likes on the comment by 1 and adds user to an array of likers
//      */
//     function likeComment(uint256 _postId, uint256 _commentId)
//         public
//         checkUserExists(msg.sender)
//     {
//         if(CSVars.s_likedComment[_postId][_commentId][msg.sender] == false){
//             // There is need to note the users that like a comment
//             CSVars.s_likedComment[_postId][_commentId][msg.sender] = true;
//             // retrieve the comment from the Blockchain in increment number of likes
//             CSVars.s_postIdToComments[_postId][_commentId].likesCount++;
//             // Add liker to an array of users that liked the comment
//             CSVars.s_likersOfComment[_postId][_commentId].push(msg.sender);
//         }
        
//     }

//     ///////////////////////
//     // Private Functions //
//     ///////////////////////

//     /**
//      * @dev This function checks the the number of upvotes and number of downvotes of a post, calculates their difference to tell if the author of the post is eligible for rewards in that period.
//      * @notice A user can be adjudged eligible on multiple grounds if they have multiple posts with significantly more number of upvotes than downvotes
//      */
//     function _isPostEligibleForReward(uint256 _postId)
//         private
//         view
//         returns (bool isEligible)
//     {
//         uint256 numOfUpvotes = getPostById(_postId).upvotes; // get number of upvotes of post
//         uint256 numOfDownvotes = getPostById(_postId).downvotes; // get number of downvotes of post
//         uint256 postScore = numOfUpvotes - numOfDownvotes > 0
//             ? numOfUpvotes - numOfDownvotes
//             : 0; // set minimum postScore to zero. We dont want negative values
//         isEligible = postScore >= CSVars.MIN_POST_SCORE ? true : false; // a post is adjudged eligible for reward if the post has ten (10) more upvotes than downvotes
//     }

//     /**
//      * @dev This function is to be called automatically using Chainlink Automation every VALIDITY_PERIOD (i.e. 30 days or as desirable). The function loops through an array of recentPosts and checks if posts are eligible for rewards and add the corresponding authors to an array of eligible authors for reward
//      */
//     function _pickIdsOfEligiblePosts(uint256[] memory _idsOfRecentPosts) internal {
//         // uint256 len = CSVars.s_idsOfRecentPosts.length; // number of recent posts

//         uint256 len = _idsOfRecentPosts.length; // number of recent posts

//         /** Loop through the array and pick posts that are eligible for reward */
//         for (uint256 i; i < len; ) {
//             // Check if post is eligible for rewards and add the postId to the array of eligible posts

//             // if (_isPostEligibleForReward(CSVars.s_idsOfRecentPosts[i])) {
//             //     CSVars.s_idsOfEligiblePosts.push(CSVars.s_idsOfRecentPosts[i]);
//             // }

//             if (_isPostEligibleForReward(_idsOfRecentPosts[i])) {
//                 CSVars.s_idsOfEligiblePosts.push(_idsOfRecentPosts[i]);
//             }


//             unchecked {
//                 i++;
//             }
//         }

//     }

//     /////////////////////////
//     // Chainlink Functions //
//     /////////////////////////

//     // 1. Get a random number
//     // 2. Use the random number to pick the winner
//     // 3. Be automatically called

//     // Chainlink Automation

//     // When is the winner supposed to be picked?
//     /**
//      * @dev This is the function that the Chainlink Automation nodes call
//      * to see if it's time to perform an upkeep.
//      * The following should be true for this to return true:
//      * 1. the time interval has passed between tournaments
//      * 2. there is at least 1 author eligible for reward
//      * 3. the contract has ETH (i.e. the Contract has received some payments)
//      * 4. (Implicit) the subscription is funded with LINK
//      */
//     function CheckUpkeep(
//         bytes memory /* checkData */
//     )
//         public
//         returns (
//             bool upkeepNeeded,
//             bytes memory /* performData */
//         )
//     {
//         // reset the CSVars.s_idsOfEligiblePosts array
//         CSVars.s_idsOfEligiblePosts = new uint256[](0);

//         // call the _pickEligibleAuthors function to determine authors that are eligible for reward
//         _pickIdsOfEligiblePosts(CSVars.s_idsOfRecentPosts); // this updates the CSVars.s_idsOfEligiblePosts array

//         bool timeHasPassed = (block.timestamp - CSVars.s_lastTimeStamp) >= CSVars.i_interval; // checks if enough time has passed
//         bool hasBalance = address(this).balance > 0; // Contract has ETH
//         bool hasAuthors = CSVars.s_idsOfEligiblePosts.length > 0; // Contract has players
//         upkeepNeeded = (timeHasPassed && hasBalance && hasAuthors);
//         return (upkeepNeeded, "0x0");
//     }

//     function performUpkeep(
//         bytes calldata /* performData */
//     ) external {
//         // Checks

//         (bool upkeepNeeded, ) = CheckUpkeep(" ");
//         if (!upkeepNeeded) {
//             revert ChainSphere__UpkeepNotNeeded(
//                 address(this).balance,
//                 CSVars.s_idsOfEligiblePosts.length
//             );
//         }

//         // Effects (on our Contract)

//         // 1. Request RNG from VRF
//         // 2. Receive the random number generated

//         // Interactions (with other Contracts)
//         CSVars.s_numOfWords = CSVars.s_idsOfEligiblePosts.length <= CSVars.TWENTY
//             ? 1
//             : uint32(CSVars.s_idsOfEligiblePosts.length % CSVars.TEN); // Pick one winner or a max ten percent of eligible winners

//         uint256 requestId = CSVars.i_vrfCoordinator.requestRandomWords(
//             CSVars.i_gasLane,
//             CSVars.i_subscriptionId,
//             CSVars.REQUEST_CONFIRMATIONS,
//             CSVars.i_callbackGasLimit,
//             CSVars.s_numOfWords
//         );

//         emit RequestWinningAuthor(requestId);
//     }

//     function fulfillRandomWords(
//         uint256, /*requestId*/
//         uint256[] memory randomWords
//     ) internal override {
//         // Checks

//         // Effects (on our Contract)

//         CSVars.s_idsOfRecentWinningPosts = new uint256[](0); // reset array of postId of most recent winning posts

//         if (randomWords.length == 1) {
//             uint256 ranNumber = randomWords[0] % CSVars.s_idsOfEligiblePosts.length;
//             uint256 idOfWinningPost = CSVars.s_idsOfEligiblePosts[ranNumber]; // get the postId
//             CSVars.s_idsOfRecentWinningPosts.push(idOfWinningPost);
//             address payable winner = payable(
//                 getPostById(idOfWinningPost).author
//             );

//             // reset the s_recentPosts array
//             CSVars.s_idsOfRecentPosts = new uint256[](0); // reset the array of recent posts
//             CSVars.s_lastTimeStamp = block.timestamp; // reset the timer for the next interval of posts to be considered

//             emit PickedWinner(winner);

//             // Interactions (With other Contracts)

//             // pay the winner
//             (bool success, ) = winner.call{value: CSVars.WINNING_REWARD}("");
//             if (!success) {
//                 revert ChainSphere__TransferFailed();
//             }
//         } else {
//             uint256 len = randomWords.length;
//             uint256 i;
//             for (i; i < len; ) {
//                 uint256 ranNumber = randomWords[i] %
//                     CSVars.s_idsOfEligiblePosts.length;
//                 uint256 idOfWinningPost = CSVars.s_idsOfEligiblePosts[ranNumber]; // get the postId
//                 CSVars.s_idsOfRecentWinningPosts.push(idOfWinningPost);
//                 address payable winner = payable(
//                     getPostById(idOfWinningPost).author
//                 );

//                 emit PickedWinner(winner);

//                 // Interactions (With other Contracts)

//                 // pay the winner
//                 (bool success, ) = winner.call{value: CSVars.WINNING_REWARD}("");
//                 if (!success) {
//                     revert ChainSphere__BatchTransferFailed(winner);
//                 }

//                 unchecked {
//                     i++;
//                 }
//             }
//         }
//     }

//     //////////////////////
//     // Getter Functions //
//     //////////////////////

//     /**
//     * @dev function receives quantity of ether and gives its value in USD
//      */
//     function getUsdValueOfEthAmount(uint256 _ethAmount)
//         public
//         view
//         returns (uint256)
//     {
//         uint256 usdValue = _ethAmount.getConversionRate(CSVars.s_priceFeed);
//         return usdValue;
//     }

//     function getIdsOfRecentWinningPosts() public view returns (uint256[] memory) {
//         return CSVars.s_idsOfRecentWinningPosts;
//     }

//     function getIdsOfRecentPosts() public view returns (uint256[] memory) {
//         return CSVars.s_idsOfRecentPosts;
//     }

//     function getIdsOfEligiblePosts() public view returns (uint256[] memory) {
//         return CSVars.s_idsOfEligiblePosts;
//     }

//     /**
//     * @dev function retrieves user profile given the userAddress
//     * @param _userAddress is the wallet address of user
//     * @return function returns the profile of the user
//      */
//     function getUser(address _userAddress) public view returns (User memory) {
//         return CSVars.s_addressToUserProfile[_userAddress];
//     }

//     /**
//     * @dev function retrieves all posts by a user given the userAddress
//     * @param _userAddress is the wallet address of user
//     * @return function returns an arry of all posts by the user
//      */
//     function getUserPosts(address _userAddress)
//         public
//         view
//         returns (Post[] memory)
//     {
//         // Implementation to retrieve all posts by a user
//         return CSVars.s_userPosts[_userAddress];
//     }

//     /**
//     * @dev function retrieves user profile given the userId
//     * @param _userId is the id of user. userId is unique
//     * @return function returns the profile of the user
//      */
//     function getUserById(uint256 _userId) public view returns (User memory) {
//         return s_users[_userId];
//     }

//     function getUserVoteStatus(uint256 _postId) public view returns(bool){
//         return CSVars.s_hasVoted[msg.sender][_postId];
//     }
//     /**
//     * @dev function retrieves all information on a post given the postId
//     * @param _postId is the id of the post. The postId is unique
//     * @return function returns the post corresponding to that postId
//      */
//     function getPostById(uint256 _postId) public view returns (Post memory) {
//         return CSVars.s_posts[_postId];
//     }

//     /**
//     * @dev function retrieves all information about a comment on a post given the postId and the commentId
//     * @param _postId is the id of the post. The postId is unique
//     * @param _commentId is the id of the comment. 
//     * @return function returns the comment corresponding to that postId and commentId
//      */
//     function getCommentByPostIdAndCommentId(uint256 _postId, uint256 _commentId)
//         public
//         view
//         returns (Comment memory)
//     {
//         return CSVars.s_postIdToComments[_postId][_commentId];
//     }

//     /**
//     * @dev function retrieves all users that liked a comment on a post given the postId and the commentId
//     * @param _postId is the id of the post. The postId is unique
//     * @param _commentId is the id of the comment. 
//     * @return function returns an array of userAddresses that liked the  comment
//      */
//     function getCommentLikersByPostIdAndCommentId(
//         uint256 _postId,
//         uint256 _commentId
//     ) public view returns (address[] memory) {
//         return CSVars.s_likersOfComment[_postId][_commentId];
//     }

//     /**
//     * @dev function retrieves all comments by a user given the userAddress
//     * @param _userAddress is the wallet address of user
//     * @return function returns an arry of all comments by the user
//      */
//     function getUserComments(address _userAddress)
//         public
//         view
//         returns (Comment[] memory)
//     {
//         // Implementation to retrieve all comments by a user
//         return CSVars.userComments[_userAddress];
//     }

//     /**
//     * @dev function retrieves username(i.e. nickname) of user given the userAddress
//     * @param _userAddress is the wallet address of user
//     * @notice function returns username(i.e. nickname) of the user
//      */
//     function getUserNameFromAddress(address _userAddress)
//         public
//         view
//         returns (string memory nickNameOfUser)
//     {
//         // User memory user = CSVars.s_addressToUserProfile[_userAddress];
//         nickNameOfUser = CSVars.s_addressToUserProfile[_userAddress].nickName;
//     }

//     /**
//     * @dev function retrieves userAddress given username(i.e. nickname) of user
//     * @param _username is the username or nick name of user
//     * @notice function returns wallet address of the user
//      */
//     function getAddressFromUsername(string memory _username) public view returns(address) {
//         return CSVars.s_usernameToAddress[_username];
//     }
    
//     /**
//     * @dev This function retrieves all post on the blockchain
//      */
//     function getAllPosts() public view returns (Post[] memory) {
//         return CSVars.s_posts;
//     }

//     /**
//     * @dev This function retrieves the username of recent winners on the platform
//      */
//     function getUsernameOfRecentWinners() public returns(string[] memory) {
//         // string[] storage userNamesOfRecentWinners;
//         uint256 len = CSVars.s_idsOfRecentWinningPosts.length;
//         for(uint256 i; i < len; ){
//             CSVars.s_userNamesOfRecentWinners.push(
//                 getUserNameFromAddress(
//                     getPostById(
//                         CSVars.s_idsOfRecentWinningPosts[i]
//                     ).author
//                 )
//             );
//             unchecked {
//                 i++;
//             }
//         }

//         return CSVars.s_userNamesOfRecentWinners;
//     }

//     /**
//     * @dev This function retrieves all recent winning posts on the platform
//      */
//     function getRecentWinningPosts() public returns(Post[] memory) {
//         // Post[] storage recentWinningPosts;
//         uint256 len = CSVars.s_idsOfRecentWinningPosts.length;
//         for(uint256 i; i < len; ){
//             CSVars.s_recentWinningPosts.push(
//                 getPostById(
//                     CSVars.s_idsOfRecentWinningPosts[i]
//                 )
//             );
//             unchecked {
//                 i++;
//             }
//         }

//         return CSVars.s_recentWinningPosts;
//     }

//     /**
//     * @dev This function retrieves all recent trending posts on the platform. These are posts that have at least the minimum post score
//      */
//     function getRecentTrendingPosts() public returns(Post[] memory) {
//         // Post[] storage recentWinningPosts;
//         uint256 len = CSVars.s_idsOfEligiblePosts.length;
//         for(uint256 i; i < len; ){
//             CSVars.s_recentTrendingPosts.push(
//                 getPostById(
//                     CSVars.s_idsOfEligiblePosts[i]
//                 )
//             );
//             unchecked {
//                 i++;
//             }
//         }

//         return CSVars.s_recentTrendingPosts;
//     }

//     // Owner functions
//     function getBalance() public view onlyOwner returns (uint256) {
//         return address(this).balance;
//     }

//     function getContractOwner() public view returns (address) {
//         return CSVars.s_owner;
//     }

//     function transferContractBalance(address payable _to) public onlyOwner {
//         _to.transfer(address(this).balance);
//     }

//     function changeOwner(address _newOwner) public onlyOwner {
//         CSVars.s_owner = _newOwner;
//     }


// }
