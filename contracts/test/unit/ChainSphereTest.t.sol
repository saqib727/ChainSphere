// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import { Test, console} from "forge-std/Test.sol";
import { ChainSphere } from "../../src/ChainSphere.sol";
// import { ChainSphereVars } from "../../src/sol";
import { DeployChainSphere } from "../../script/DeployChainSphere.s.sol";
import { HelperConfig } from "../../script/HelperConfig.s.sol";
import { Vm } from "forge-std/Vm.sol";
import { VRFCoordinatorV2Mock } from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import { ChainSphereUserProfile as CSUserProfile}  from "../../src/ChainSphereUserProfile.sol";
import { ChainSpherePosts as CSPosts}  from "../../src/ChainSpherePosts.sol";
import { ChainSphereComments as CSComments}  from "../../src/ChainSphereComments.sol";


contract ChainSphereTest is Test {
    
    ///////////////////////////////////
    /// Type Declarations (Structs) ///
    ///////////////////////////////////
    struct User {
        uint256 id;
        address userAddress;
        string name;
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

    // Declaring variable types
    ChainSphere chainSphere;
    DeployChainSphere deployer;
    HelperConfig helperConfig;

    address priceFeed;
    uint256 interval;
    address vrfCoordinator;
    bytes32 gasLane;
    uint256 subscriptionId;
    uint32 callbackGasLimit;
    address link;
    uint256 minimumUsd;

    // Constants
    uint256 private constant STARTING_BALANCE = 10 ether;
    uint256 private constant EDITING_FEE = 0.004 ether;
    uint256 private constant USER_ZERO = 0;

    // create a fake user
    address USER = makeAddr("user");

    address[] userAddresses;

    // struct instances
    Post post;
    User user;
    Comment comment;

    // Events
    event UserRegistered(uint256 indexed id, address indexed userAddress, string name);
    event PostCreated(uint256 postId, string authorName);
    event PostEdited(uint256 postId, string authorName);
    event Upvoted(uint256 postId, string posthAuthorName, string upvoterName);
    event Downvoted(uint256 postId, string posthAuthorName, string downvoterName);
    event CommentCreated(uint256 indexed commentId, string postAuthor, string commentAuthor, uint256 postId);
    

    function setUp() public {
        deployer = new DeployChainSphere();
        (chainSphere, helperConfig) = deployer.run();

        (
            priceFeed,
            interval, 
            vrfCoordinator,
            gasLane,
            subscriptionId,
            callbackGasLimit,
            link,
            ,
            minimumUsd
        
        ) = helperConfig.activeNetworkConfig();
        vm.deal(USER, STARTING_BALANCE);
    }

    /////////////////////////////
    // User Registration Tests //
    /////////////////////////////

    /** Modifier */
    // This Modifier is created since this task will be repeated a couple of times
    modifier registerOneUser() {
        string memory myName = "Nengak Goltong";
        string memory myNickName = "Spo";
        string memory myBio = "I love to code";
        string memory myImgHash = "";
        
        vm.prank(USER);
        chainSphere.registerUser(myName, myNickName);
        _;
    }

    modifier skipFork(){
        if(block.chainid != 31337){
            return;
        }
        _;
    }

    /** Test Passes as expected */
    function testUserCanRegister() public registerOneUser {
        string memory myName = "Nengak Goltong";
        string memory myNickName = "Spo";
        string memory expectedName;
        string memory expectedNickName;
        
        // get name of user from the Blockchain
        expectedNickName = chainSphere.getUserById(0).nickName;
        console.log("Registered User Name: %s", expectedNickName);

        expectedName = chainSphere.getUserById(0).fullNameOfUser;
        console.log("Registered User Bio: %s", expectedName);
        assertEq(
            keccak256(abi.encodePacked(myName)), 
            keccak256(abi.encodePacked(expectedName))
        );
        assertEq(
            keccak256(abi.encodePacked(myNickName)), 
            keccak256(abi.encodePacked(expectedNickName))
        );
    }

    // Test reverts as expected. Test passes
    function testUserCantRegisterIfUsernameAlreadyExists() public registerOneUser{
        string memory myName = "Nengak Goltong";
        string memory myNickName = "Spo";
        
        // The test is expected to revert with `chainSphere__UsernameAlreadyTaken` message since the username is registered already
        vm.expectRevert(
            CSUserProfile.ChainSphere__UsernameAlreadyTaken.selector
        );
        vm.prank(USER);
        chainSphere.registerUser(myName, myNickName);
    }

    function testEmitsEventAfterUserRegistration() public {
        string memory myName = "Nengak Goltong";
        string memory myNickName = "Spo";
        
        vm.expectEmit(true, false, false, false, address(chainSphere));
        // emit UserRegistered(0, USER, myName);
        emit UserRegistered(0, USER, myNickName);
        vm.prank(USER);
        chainSphere.registerUser(myName, myNickName);
    }

    function testUserCanEditTheirProfile() public registerOneUser {
        string memory myBio = "Cyfin Updraft Fellow";
        string memory myNickName = "Spo";
        string memory expectedBio;
        string memory expectedNickName;
        
        // update user profile
        vm.prank(chainSphere.getUserById(0).userAddress);
        chainSphere.editUserProfile(0, myBio, "", "");
        // get name of user from the Blockchain
        expectedNickName = chainSphere.getUserById(0).nickName;
        console.log("Registered User Name: %s", expectedNickName);

        expectedBio = chainSphere.getUserById(0).bio;
        console.log("Registered User Bio: %s", expectedBio);

        assertEq(
            keccak256(abi.encodePacked(myNickName)), 
            keccak256(abi.encodePacked(expectedNickName))
        );

        assertEq(
            keccak256(abi.encodePacked(myBio)), 
            keccak256(abi.encodePacked(expectedBio))
        );
    }

    //////////////////////////////
    // Change of Username Tests //
    //////////////////////////////

    modifier registerThreeUsers() {
        string[3] memory names = ["Maritji", "Songrit", "Jane"];
        string memory myBio = "I love to code";
        string memory myImgHash = "";
        
        uint256 len = names.length;
        uint256 i;
        // Register the three users using a for loop
        for(i = 0; i <len; ){
            address newUser = makeAddr(string(names[i])); 
            vm.prank(newUser);
            chainSphere.registerUser(names[i], names[i]);
            unchecked {
                i++;
            }
        }
        _;
    }

    function testCantChangeUsernameIfUserDoesNotExist() public registerThreeUsers {
        // Create a random user
        address RAN_USER = makeAddr("ran_user");
        string memory newName = "My New Name";

        // Test is expected to revert since user does not exist on the blockchain
        vm.expectRevert(
            CSUserProfile.ChainSphere__UserDoesNotExist.selector
        );
        vm.prank(RAN_USER);
        chainSphere.changeUsername(USER_ZERO, newName);

    }

    function testCantChangeUsernameToAnExistingUsername() public registerThreeUsers {
        // Create a random user
        address RAN_USER = makeAddr("Maritji");
        string memory newName = "Songrit"; // Note that this name exist already on the Blockchain

        // Test is expected to revert since the new username already exists on the blockchain
        vm.expectRevert(
            CSUserProfile.ChainSphere__UsernameAlreadyTaken.selector
        );
        vm.prank(RAN_USER);
        chainSphere.changeUsername(USER_ZERO, newName);

    }

    function testRegisteredUserCantChangeUsernameIfNotProfileOwner() public registerThreeUsers {
        // We will attempt for a user registered on the blockchain to try changing the username for a profile not theirs
        // The test is expected to revert
        address RAN_USER = makeAddr("Songrit"); // Note that this user is registered on the Blockchain.
        string memory newName = "Fulton"; // Note that this does not exist on the Blockchain

        // Test is expected to revert since the nuser is not the profile owner
        vm.expectRevert(
            CSUserProfile.ChainSphere__NotProfileOwner.selector
        );
        vm.prank(RAN_USER);
        chainSphere.changeUsername(USER_ZERO, newName);

    }

    // Test passed
    function testCanChangeUsernameWhereAllConditionsAreMet() public registerThreeUsers {
        // Use one of the names on the Blockchain to create an address
        address RAN_USER = makeAddr("Maritji");
        string memory newName = "Pauline"; // Note that this name does not exist on the Blockchain
        string memory expectedName;

        // console.log("Initial User name: ", chainSphere.getUserById(0).nickName);
        // console.log(chainSphere.getUser(RAN_USER));
        chainSphere.getUser(RAN_USER);
        // Test is expected to pass
        vm.prank(RAN_USER);
        chainSphere.changeUsername(USER_ZERO, newName);

        // get name of user from the Blockchain
        expectedName = chainSphere.getUserById(0).nickName;
        console.log("User Name: %s", expectedName);

        assertEq(
            keccak256(abi.encodePacked(newName)), 
            keccak256(abi.encodePacked(expectedName))
        );

    }

    ///////////////////////
    // Create Post Tests //
    ///////////////////////

    // Test Passes as expected
    function testUserCantCreatePostIfNotRegistered() public {
        string memory content = "Come and See";
        string memory imgHash = "";

        // Note that USER has not registered and as such, we expect test to revert
        vm.expectRevert(
            CSUserProfile.ChainSphere__UserDoesNotExist.selector
        );
        vm.prank(USER);
        chainSphere.createPost(content, imgHash);
    }

    // Test Passes as expected
    function testRegisteredUserCanCreatePost() public registerOneUser {
        string memory content = "Come and See";
        string memory imgHash = "";

        vm.prank(USER);
        chainSphere.createPost(content, imgHash);
        console.log(chainSphere.getPostById(0).content);
        // retrieve content from the blockchain
        string memory retrievedContent = chainSphere.getPostById(0).content;
        
        assertEq(
            keccak256(abi.encodePacked(retrievedContent)),
            keccak256(abi.encodePacked(content))
        );
    }

    // Test Passes as expected
    function testEventEmitsWhenPostIsCreated() public registerOneUser {
        string memory content = "Come and See";
        string memory imgHash = "";
        string memory myName = chainSphere.getUserNameFromAddress(USER);

        vm.expectEmit(true, false, false, false, address(chainSphere));
        emit PostCreated(0, myName);
        vm.prank(USER);
        chainSphere.createPost(content, imgHash);
        
    }

    /////////////////////
    // Edit Post Tests //
    /////////////////////

    modifier registerThreeUsersAndPost() {
        string[3] memory names = ["Maritji", "Songrit", "Jane"];
        string memory myBio = "I love to code";
        string memory myImgHash = "";
        string memory myContent = "Come and See";
        
        uint256 len = names.length;
        uint256 i;
        // Register the three users using a for loop
        for(i = 0; i <len; ){
            // Create a fake user and assign them a starting balance
            // hoax(address(i), STARTING_BALANCE);
            address newUser = makeAddr(string(names[i])); 
            vm.deal(newUser, STARTING_BALANCE);
            vm.startPrank(newUser);
            // register newUser
            chainSphere.registerUser(names[i], names[i]);
            // newUser makes a post
            chainSphere.createPost(myContent, myImgHash);
            vm.stopPrank();
            unchecked {
                i++;
            }
        }
        _;
    }

    // Test reverts as expected - Test passes
    function testCantEditPostIfNotTheOwner() public registerThreeUsersAndPost {
        // Test is expected to revert because we will prank a user to try editing a post of another user

        // Get the address of the author of the first post 
        address firstUser = chainSphere.getPostById(0).author;
        string memory newContent = "Immaculate Heart of Mary";
        string memory imgHash = "";

        vm.expectRevert(
            CSPosts.ChainSphere__NotPostOwner.selector
        );
        vm.prank(firstUser);
        chainSphere.editPost(1, newContent, imgHash);

    }

    // Test passes
    // function testOwnerCantEditPostWithoutPaying() public registerThreeUsersAndPost {
    //     // Test is expected to revert because a user will try editing their post without making payment

    //     // Get the address of the author of the first post 
    //     address firstUser = chainSphere.getPostById(0).author;
    //     string memory newContent = "Immaculate Heart of Mary";
    //     string memory imgHash = "";

    //     vm.expectRevert(
    //         ChainSphere.ChainSphere__PaymentNotEnough.selector
    //     );
    //     vm.prank(firstUser);
    //     chainSphere.editPost(0, newContent, imgHash);

    // }

    // Test passes
    function testOwnerCanEditPost() public registerThreeUsersAndPost {
        // Test is expected to pass because a user will pay for editing their post

        // Get the address of the author of the first post 
        address firstUser = chainSphere.getPostById(0).author;
        string memory newContent = "Immaculate Heart of Mary";
        string memory imgHash = "";

        vm.prank(firstUser);
        chainSphere.editPost(0, newContent, imgHash);
        
        string memory retrievedContent = chainSphere.getPostById(0).content;
        assertEq(
            keccak256(abi.encodePacked(retrievedContent)),
            keccak256(abi.encodePacked(newContent))
        );

    }

    // Test Passes as expected
    function testEventEmitsWhenPostIsEdited() public registerThreeUsersAndPost {
        address firstUser = chainSphere.getPostById(0).author;
        string memory newContent = "Immaculate Heart of Mary";
        string memory imgHash = "";
        
        string memory myName = chainSphere.getUserNameFromAddress(firstUser);

        vm.expectEmit(true, false, false, false, address(chainSphere));
        emit PostEdited(0, myName);
        vm.prank(firstUser);
        chainSphere.editPost(0, newContent, imgHash);
        
    }

    ///////////////////////
    // Delete Post Tests //
    ///////////////////////

    // Test reverts as expected - Test passes
    function testCantDeletePostIfNotTheOwner() public registerThreeUsersAndPost {
        // Test is expected to revert because we will prank a user to try editing a post of another user

        // Get the address of the author of the first post 
        address firstUser = chainSphere.getPostById(0).author;

        vm.expectRevert(
            CSPosts.ChainSphere__NotPostOwner.selector
        );
        vm.prank(firstUser);
        chainSphere.deletePost(1);

    }

    // Test passes
    function testOwnerCantDeletePostWithoutPaying() public registerThreeUsersAndPost {
        // Test is expected to revert because a user will try editing their post without making payment

        // Get the address of the author of the first post 
        address firstUser = chainSphere.getPostById(0).author;

        vm.expectRevert(
            CSPosts.ChainSphere__PaymentNotEnough.selector
        );
        vm.prank(firstUser);
        chainSphere.deletePost(0);

    }

    // Test passes
    function testOwnerCanDeletePostAfterPaying() public registerThreeUsersAndPost {
        // Test is expected to pass because a user will pay for editing their post

        // Get the address of the author of the first post 
        address firstUser = chainSphere.getPostById(0).author;

        vm.prank(firstUser);
        chainSphere.deletePost{value: EDITING_FEE}(0);
        
        string memory retrievedContent = chainSphere.getPostById(0).content;
        address retrievedAddress = chainSphere.getPostById(0).author;
        assertEq(
            keccak256(abi.encodePacked(retrievedContent)),
            keccak256(abi.encodePacked(""))
        );

        assertEq(retrievedAddress, address(0));
    }

    // Test passes
    function testDeletePostRemovesPostFromUserPosts() public registerThreeUsersAndPost {
        // Test is expected to pass because a user will pay for editing their post

        // Get the address of the author of the first post 
        address firstUser = chainSphere.getPostById(0).author;

        vm.prank(firstUser);
        chainSphere.deletePost{value: EDITING_FEE}(0);
        
        // string memory retrievedContent = chainSphere.getPostById(0).content;
        address retrievedAddress = chainSphere.getUserPosts(firstUser)[0].author;

        assertEq(retrievedAddress, address(0));
    }
    
    // Test passes
    function testContractReceivesPaymentWhenPostIsDeleted() public registerThreeUsersAndPost {
        address firstUser = chainSphere.getPostById(0).author;

        vm.prank(firstUser);
        chainSphere.deletePost{value: EDITING_FEE}(0);
        address owner = chainSphere.getContractOwner();
        vm.prank(owner);
        uint256 contractBalance = chainSphere.getBalance();
        console.log(contractBalance);
        assertEq(contractBalance, EDITING_FEE);
    }

    //////////////////
    // Upvote Tests //
    //////////////////

    function testUserCantUpvotePostIfTheyAreTheOwner() public registerThreeUsersAndPost{
        // Test is expected to revert since no one can upvote their post
        address firstUser = chainSphere.getPostById(0).author;

        vm.expectRevert(
            CSPosts.ChainSphere__OwnerCannotVote.selector
        );
        vm.prank(firstUser);
        chainSphere.upvote(0);
    }

    function testUserCanUpvotePostIfTheyAreNotTheOwner() public registerThreeUsersAndPost{
        address firstUser = chainSphere.getPostById(0).author;

        vm.prank(firstUser);
        chainSphere.upvote(1);
        uint256 numUpvotes = chainSphere.getPostById(1).upvotes;
        uint256 expectedUpvotes = 1;
        assertEq(numUpvotes, expectedUpvotes);
    }

    function testUserCantUpvoteSamePostMoreThanOnce() public registerThreeUsersAndPost{
        // Test is expected to revert since no one can upvote their post
        address firstUser = chainSphere.getPostById(0).author;

        vm.prank(firstUser);
        chainSphere.upvote(1); //cast upvote first time
        vm.expectRevert(
            CSPosts.ChainSphere__AlreadyVoted.selector
        );
        vm.prank(firstUser);
        chainSphere.upvote(1); // cast upvote for the second time on the same post
    }

    // Test passed
    function testUserCanUpvoteMultiplePostsIfTheyAreNotTheOwner() public registerThreeUsersAndPost{
        address firstUser = chainSphere.getPostById(0).author;

        vm.startPrank(firstUser);
        chainSphere.upvote(1);
        chainSphere.upvote(2);
        vm.stopPrank();

        uint256 num1Upvotes = chainSphere.getPostById(1).upvotes;
        uint256 num2Upvotes = chainSphere.getPostById(2).upvotes;
        uint256 expectedUpvotes = 1;
        assertEq(num1Upvotes, expectedUpvotes);
        assertEq(num2Upvotes, expectedUpvotes);
    }

    // Test passes
    function testEmitsEventWhenPostGetsAnUpvote() public registerThreeUsersAndPost{
        address upvoter = chainSphere.getPostById(0).author;
        address postAuthor = chainSphere.getPostById(1).author;

        string memory voterName = chainSphere.getUserNameFromAddress(upvoter);
        string memory postAuthorName = chainSphere.getUserNameFromAddress(postAuthor);

        vm.expectEmit(true, false, false, false, address(chainSphere));
        emit Upvoted(1, postAuthorName, voterName);
        
        vm.startPrank(upvoter);
        chainSphere.upvote(1);
        vm.stopPrank();
        
    }

    ////////////////////
    // Downvote Tests //
    ////////////////////

    function testUserCantDownvotePostIfTheyAreTheOwner() public registerThreeUsersAndPost{
        // Test is expected to revert since no one can upvote their post
        address firstUser = chainSphere.getPostById(0).author;

        vm.expectRevert(
            CSPosts.ChainSphere__OwnerCannotVote.selector
        );
        vm.prank(firstUser);
        chainSphere.downvote(0);
    }

    // Test passes
    function testUserCanDownvotePostIfTheyAreNotTheOwner() public registerThreeUsersAndPost{
        address firstUser = chainSphere.getPostById(0).author;

        vm.prank(firstUser);
        chainSphere.downvote(1);
        uint256 numDownvotes = chainSphere.getPostById(1).downvotes;
        uint256 expectedDownvotes = 1;
        assertEq(numDownvotes, expectedDownvotes);
    }

    function testUserCantDownvoteSamePostMoreThanOnce() public registerThreeUsersAndPost{
        // Test is expected to revert since no one can upvote their post
        address firstUser = chainSphere.getPostById(0).author;

        vm.prank(firstUser);
        chainSphere.downvote(1); //cast downvote first time
        vm.expectRevert(
            CSPosts.ChainSphere__AlreadyVoted.selector
        );
        vm.prank(firstUser);
        chainSphere.downvote(1); // cast downvote for the second time on the same post
    }

    // Test passed
    function testUserCanDownvoteMultiplePostsIfTheyAreNotTheOwner() public registerThreeUsersAndPost{
        address firstUser = chainSphere.getPostById(0).author;

        vm.startPrank(firstUser);
        chainSphere.downvote(1);
        chainSphere.downvote(2);
        vm.stopPrank();

        uint256 num1Downvotes = chainSphere.getPostById(1).downvotes;
        uint256 num2Downvotes = chainSphere.getPostById(2).downvotes;
        uint256 expectedDownvotes = 1;
        assertEq(num1Downvotes, expectedDownvotes);
        assertEq(num2Downvotes, expectedDownvotes);
    }

    // Test passes
    function testEmitsEventWhenPostGetsAnDownvote() public registerThreeUsersAndPost{
        address downvoter = chainSphere.getPostById(0).author;
        address postAuthor = chainSphere.getPostById(1).author;

        string memory voterName = chainSphere.getUserNameFromAddress(downvoter);
        string memory postAuthorName = chainSphere.getUserNameFromAddress(postAuthor);

        vm.expectEmit(true, false, false, false, address(chainSphere));
        emit Downvoted(1, postAuthorName, voterName);
        
        vm.startPrank(downvoter);
        chainSphere.downvote(1);
        vm.stopPrank();
        
    }

    /////////////////////////////
    // Upvote & Downvote Tests //
    /////////////////////////////

    // Test passes
    function testUserCantUpvoteAndDownvoteSamePost() public registerThreeUsersAndPost{
        // Test is expected to revert 
        address firstUser = chainSphere.getPostById(0).author;

        vm.prank(firstUser);
        chainSphere.upvote(1); // user 0 gives an upvote to post of user 1
        vm.expectRevert(
            CSPosts.ChainSphere__AlreadyVoted.selector
        );
        vm.prank(firstUser);
        chainSphere.downvote(1); // user 0 gives a downvote to post of user 1
    }

    // Test passes
    function testUserCantDownvoteAndUpvoteSamePost() public registerThreeUsersAndPost{
        // Test is expected to revert
        address firstUser = chainSphere.getPostById(0).author;

        vm.prank(firstUser);
        chainSphere.downvote(1); // user 0 gives an downvote to post of user 1
        vm.expectRevert(
            CSPosts.ChainSphere__AlreadyVoted.selector
        );
        vm.prank(firstUser);
        chainSphere.upvote(1); // user 0 gives a upvote to post of user 1
    }

    //////////////////////////
    // Create Comment Tests //
    //////////////////////////

    // Test Passes as expected
    function testUserCantCreateCommentIfNotRegistered() public registerThreeUsersAndPost{
        string memory content = "Praise God";

        // Note that USER has not registered and as such, we expect test to revert
        vm.expectRevert(
            CSUserProfile.ChainSphere__UserDoesNotExist.selector
        );
        vm.prank(USER);
        chainSphere.createComment(0, content);
    }

    // Test Passes as expected
    function testRegisteredUserCanCreateComment() public registerThreeUsersAndPost{
        address firstUser = chainSphere.getPostById(0).author;
        address secondUser = chainSphere.getPostById(1).author;
        string memory content1 = "Praise God";
        string memory content2 = "God's Amazing Grace";

        vm.startPrank(firstUser);
        chainSphere.createComment(0, content1); // comment 0 on post 0
        chainSphere.createComment(0, content1); // comment 1 on post 0
        chainSphere.createComment(0, content1); // comment 2 on post 0
        chainSphere.createComment(1, content1); // comment 0 on post 1
        chainSphere.createComment(1, content1); // comment 1 on post 1
        chainSphere.createComment(1, content1); // comment 2 on post 1
        chainSphere.createComment(2, content1); // comment 0 on post 2
        chainSphere.createComment(2, content1); // comment 1 on post 2
        chainSphere.createComment(2, content1); // comment 2 on post 2
        vm.stopPrank();

        vm.startPrank(secondUser);
        chainSphere.createComment(0, content2); // comment 3 on post 0
        chainSphere.createComment(0, content2); // comment 4 on post 0
        chainSphere.createComment(0, content2); // comment 5 on post 0
        chainSphere.createComment(1, content2); // comment 3 on post 1
        chainSphere.createComment(1, content2); // comment 4 on post 1
        chainSphere.createComment(1, content2); // comment 5 on post 1
        chainSphere.createComment(2, content2); // comment 3 on post 2
        chainSphere.createComment(2, content2); // comment 4 on post 2
        chainSphere.createComment(2, content2); // comment 5 on post 2
        vm.stopPrank();

        // retrieve comment from the blockchain
        string memory expectedContent00 = chainSphere.getCommentsByPostId(0)[0].content; // the first comment on the first post
        string memory expectedContent02 = chainSphere.getCommentsByPostId(0)[2].content; // the third comment on the first post
        string memory expectedContent14 = chainSphere.getCommentsByPostId(1)[4].content; // the fifth comment on the first post
        string memory expectedContent25 = chainSphere.getCommentsByPostId(2)[5].content; // the sixth comment on the second post
        console.log(expectedContent00);
        console.log(expectedContent02);
        console.log(expectedContent14);
        console.log(expectedContent25);
    
        assertEq(
            keccak256(abi.encodePacked(expectedContent00)),
            keccak256(abi.encodePacked(content1))
        );

        assertEq(
            keccak256(abi.encodePacked(expectedContent02)),
            keccak256(abi.encodePacked(content1))
        );

        assertEq(
            keccak256(abi.encodePacked(expectedContent14)),
            keccak256(abi.encodePacked(content2))
        );

        assertEq(
            keccak256(abi.encodePacked(expectedContent25)),
            keccak256(abi.encodePacked(content2))
        );
    }

    // Test Passes as expected
    // function testEventEmitsWhenCommentIsCreated() public registerThreeUsersAndPost{
    //     address firstUser = chainSphere.getPostById(0).author;
    //     address author = chainSphere.getPostById(1).author;
    //     string memory content = "Praise God";
    //     string memory commentAuthor = chainSphere.getUserNameFromAddress(firstUser);
    //     string memory postAuthor = chainSphere.getUserNameFromAddress(author);

    //     vm.expectEmit(true, false, false, false, address(chainSphere));
    //     emit CommentCreated(0, postAuthor, commentAuthor, 0);
    //     vm.prank(firstUser);
    //     chainSphere.createComment(1, content);
    // }   

    ////////////////////////
    // Edit Comment Tests //
    ////////////////////////

    
    // Test reverts as expected - Test passes
    function testCantEditCommentIfNotTheOwner() public registerThreeUsersAndPost {
        // Test is expected to revert because we will prank a user to try editing a comment of another user

        // Get the address of the author of the first post 
        address firstUser = chainSphere.getPostById(0).author;
        string memory content = "Praise God";
        string memory newContent = "For He is good";

        vm.prank(firstUser);
        chainSphere.createComment(0, content); // user 0 comments on their post 

        vm.expectRevert(
            CSComments.ChainSphere__NotCommentOwner.selector
        );
        vm.prank(USER);
        chainSphere.editComment(0, 0, newContent);

    }

    
    // Test passes
    function testOwnerCanEditComment() public registerThreeUsersAndPost {
        // Test is expected to pass because a user will pay for editing their post

        // Get the address of the author of the first post 
        address firstUser = chainSphere.getPostById(0).author;
        string memory content = "Praise God";
        string memory newContent = "For He is good";

        vm.startPrank(firstUser);
        chainSphere.createComment(0, content); // user 0 comments on their post 
        // chainSphere.editComment{value: EDITING_FEE}(0, 0, newContent);
        chainSphere.editComment(0, 0, newContent);
        vm.stopPrank();

        string memory retrievedComment = chainSphere.getCommentsByPostId(0)[0].content;
        assertEq(
            keccak256(abi.encodePacked(retrievedComment)),
            keccak256(abi.encodePacked(newContent))
        );

    }

    //////////////////////////
    // Delete Comment Tests //
    //////////////////////////

    
    // Test reverts as expected - Test passes
    function testCantDeleteCommentIfNotTheOwner() public registerThreeUsersAndPost {
        // Test is expected to revert because we will prank a user to try deleting a comment of another user

        // Get the address of the author of the first post 
        address firstUser = chainSphere.getPostById(0).author;
        string memory content = "Praise God";

        vm.prank(firstUser);
        chainSphere.createComment(0, content); // user 0 comments on their post 

        vm.expectRevert(
            CSComments.ChainSphere__NotCommentOwner.selector
        );
        vm.prank(USER);
        chainSphere.deleteComment{value: EDITING_FEE}(0, 0);

    }

    // Test passes
    function testOwnerCantDeleteCommentWithoutPaying() public registerThreeUsersAndPost {
        // Test is expected to revert because a user will try deleting their comment without making payment

        // Get the address of the author of the first post 
        address firstUser = chainSphere.getPostById(0).author;
        string memory content = "Praise God";

        vm.prank(firstUser);
        chainSphere.createComment(0, content); // user 0 comments on their post 

        vm.expectRevert(
            CSPosts.ChainSphere__PaymentNotEnough.selector
        );
        vm.prank(firstUser);
        chainSphere.deleteComment(0, 0);
    }

    // Test passes
    function testOwnerCanDeleteCommentAfterPaying() public registerThreeUsersAndPost {
        // Test is expected to pass because a user will pay for deleting their post

        // Get the address of the author of the first post 
        address firstUser = chainSphere.getPostById(0).author;
        string memory content = "Praise God";

        vm.startPrank(firstUser);
        chainSphere.createComment(0, content); // user 0 comments on their post 
        chainSphere.deleteComment{value: EDITING_FEE}(0, 0);
        vm.stopPrank();

        string memory retrievedComment = chainSphere.getCommentsByPostId(0)[0].content; // retrieve comment after deleting to verify that comment is actually deleted
        address retrievedAddress = chainSphere.getCommentsByPostId(0)[0].author;

        // assert that comment is now empty i.e. comment is deleted
        assertEq(
            keccak256(abi.encodePacked(retrievedComment)),
            keccak256(abi.encodePacked(""))
        );

        // assert that commenter is now the zero address i.e. commenter address is deleted
        assertEq(retrievedAddress, address(0));
    }

    ////////////////////////
    // Like Comment Tests //
    ////////////////////////

    // Test reverts as expected - Test passes
    function testCantLikeCommentIfNotARegisteredUser() public registerThreeUsersAndPost {
        // Test is expected to revert because we will prank a user who has not registered to attempt to like a comment of another user

        // Get the address of the author of the first post 
        address firstUser = chainSphere.getPostById(0).author;
        string memory content = "Praise God";

        vm.prank(firstUser);
        chainSphere.createComment(0, content); // user 0 comments on their post 

        vm.expectRevert(
            CSUserProfile.ChainSphere__UserDoesNotExist.selector
        );
        vm.prank(USER);
        chainSphere.likeComment(0, 0);

    }

    // Test passes
    function testRegisteredUserCanLikeComment() public registerThreeUsersAndPost {
        // Test is expected to pass because a user will pay for deleting their post

        // Get the address of the author of the first post 
        address firstUser = chainSphere.getPostById(0).author;
        address secondUser = chainSphere.getPostById(1).author;
        string memory content = "Praise God";

        vm.prank(firstUser);
        chainSphere.createComment(0, content); // user 0 comments on their post 
        vm.prank(secondUser);
        chainSphere.likeComment(0, 0);
        vm.stopPrank();

        uint256 retrievedLikes = chainSphere.getCommentsByPostId(0)[0].likesCount; // retrieve the number of likes of comment
        address retrievedAddress = chainSphere.getCommentLikersByPostIdAndCommentId(0, 0)[0];

        // assert that comment was liked i.e. likes = 1
        assertEq(
            retrievedLikes, 1
        );

        // assert that the comment was liked by secondUser
        assertEq(retrievedAddress, secondUser);
    }

    ///////////////////////
    ///  checkUpkeep    ///
    ///////////////////////

    modifier timePassed(){
        vm.warp(block.timestamp + interval + 2);
        vm.roll(block.number + 2);
        _;
    }

    modifier registerTenUsersWhoPostAndCastVotes() {
        string[10] memory fullNames = [
            "Maritji", "Songrit", "Jane", "Tanaan", "John",
            "Spytex", "Afan", "Nenpan", "Smith", "Rose"
        ];
        string[10] memory nickNames = [
            "Maritji", "Songrit", "Jane", "Tanaan", "John",
            "Spytex", "Afan", "Nenpan", "Smith", "Rose"
        ];
        // string memory myBio = "I love to code";
        string memory myImgHash = "";
        string memory myContent = "Come and See";
        string memory newContent = "Praise God";
        
        uint256 len = fullNames.length;
        uint256 i;
        uint256 j;
        
        // Register the users using a for loop
        for(i = 0; i <len; ){
            // Create a fake user and assign them a starting balance
            
            address newUser = makeAddr(string(fullNames[i])); 
            vm.deal(newUser, STARTING_BALANCE);
            vm.startPrank(newUser);
            // register newUser
            chainSphere.registerUser(fullNames[i], nickNames[i]);
            // newUser makes a post
            chainSphere.createPost(myContent, myImgHash);
            vm.stopPrank();

            userAddresses.push(newUser); // add user to an array of users

            unchecked {
                i++;
            }
        }
        
        // cast upvotes to the posts
        for(i = 0; i <len; ){
            address currentUser = userAddresses[i];
            vm.startPrank(currentUser);
            chainSphere.editPost(i, newContent, myImgHash); // edit post
            vm.stopPrank();

            for(j = ++i; j < len; ){
                vm.startPrank(currentUser);
                chainSphere.upvote(j); // cast upvote on another's post
                vm.stopPrank();

                unchecked {
                    j++;
                }
            }
            
            unchecked {
                i++;
            }
        }
        _;
    }

    function testCheckUpkeepReturnsFalseIfContractHasNoBalance() public timePassed {
        
        (bool upkeepNeeded, ) = chainSphere.CheckUpkeep(" ");
        assert(!upkeepNeeded);
    }

    function testCheckUpkeepReturnsFalseIfEnoughTimeHasNotPassed() public registerTenUsersWhoPostAndCastVotes {
        
        (bool upkeepNeeded, ) = chainSphere.CheckUpkeep(" ");
        assert(!upkeepNeeded);
    }

    // test passes
    function testCheckUpkeepReturnsTrueWhenParametersAreGood() public registerTenUsersWhoPostAndCastVotes timePassed {
        
        vm.deal(address(chainSphere), STARTING_BALANCE); // assign some balance to the contract
        (bool upkeepNeeded, ) = chainSphere.CheckUpkeep(" ");
        assert(upkeepNeeded);
    }

    // test
    function testCheckUpkeepUpdatesArrayOfEligiblePosts() public registerTenUsersWhoPostAndCastVotes timePassed {
        
        vm.deal(address(chainSphere), STARTING_BALANCE); // assign some balance to the contract
        uint256 recentPosts = chainSphere.getIdsOfRecentPosts().length;
        uint256 initialLength = chainSphere.getIdsOfEligiblePosts().length;
        chainSphere.CheckUpkeep(" "); // call the CheckUpkeep function
        uint256 finalLength = chainSphere.getIdsOfEligiblePosts().length;

        console.log(recentPosts);
        console.log(initialLength);
        console.log(finalLength);
        assert(finalLength > initialLength);
        
    }

    ///////////////////////
    ///  performUpkeep  ///
    //////////////////////
    function testPerformUpkeepCanOnlyRunIfCheckUpkeepIsTrue() public registerTenUsersWhoPostAndCastVotes timePassed skipFork{
        bytes memory myData = abi.encodePacked("0x0");
        vm.deal(address(chainSphere), STARTING_BALANCE);
        // chainSphere.performUpkeep(" ");
        chainSphere.performUpkeep(myData);

    }

    function testPerformUpkeepRevertsIfCheckUpkeepIsFalse() public {
        vm.prank(chainSphere.getContractOwner());
        uint256 currentBalance = chainSphere.getBalance();
        uint256 eligiblePosts = chainSphere.getIdsOfEligiblePosts().length;
        vm.expectRevert(
            abi.encodeWithSelector(
                CSPosts.ChainSphere__UpkeepNotNeeded.selector,
                currentBalance,
                eligiblePosts
            )
        );
        chainSphere.performUpkeep(" ");

    }

    function testPerformUpkeepEmitsRequestId() 
        public registerTenUsersWhoPostAndCastVotes timePassed skipFork {
        vm.recordLogs(); // saves all output logs
        vm.deal(address(chainSphere), STARTING_BALANCE);
        chainSphere.performUpkeep(" "); // emits requestId
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 requestId = entries[0].topics[1];

        assert(uint256(requestId) > 0);
    }


    ////////////////////////
    ///fulfilRandomWords ///
    //////////////////////
    function testFulfilRandomWordsCanOnlyBeCalledAfterPerformUpkeep(
        uint256 randomRequestId
    ) 
    public registerTenUsersWhoPostAndCastVotes timePassed skipFork {
        vm.expectRevert("nonexistent request");
        VRFCoordinatorV2Mock(vrfCoordinator).fulfillRandomWords(
            randomRequestId, 
            address(chainSphere)
        );
    }
    
    function testFulfilRandomWordsPicksAWinnerResetsAndSendsMoney() 
        public registerTenUsersWhoPostAndCastVotes timePassed skipFork {
        
        uint256 WINNING_REWARD = 0.01 ether;

        vm.recordLogs(); // saves all output logs
        vm.deal(address(chainSphere), STARTING_BALANCE);
        chainSphere.performUpkeep(" "); // emits requestId
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 requestId = entries[0].topics[2];

        VRFCoordinatorV2Mock(vrfCoordinator).fulfillRandomWords(
            uint256(requestId), 
            address(chainSphere)
        );

        address winnerAddress = chainSphere.getPostById(
            chainSphere.getIdsOfRecentWinningPosts()[0]
        ).author;
        console.log(winnerAddress.balance);
        console.log(STARTING_BALANCE + WINNING_REWARD - EDITING_FEE);
        assert(chainSphere.getIdsOfRecentWinningPosts().length == 1); // Only one winner was picked
        assert(winnerAddress.balance > STARTING_BALANCE);
    }

    ///////////////////////////
    // Price Converter Tests //
    ///////////////////////////
    
    function testCanGetPriceFromPriceFeedAndReturnValueInUsd() public view skipFork {
        uint256 ethAmount = 0.5 ether;
        uint256 actualValue = 1000e18; // i.e. $1_000 recall the price of 1 ETH in our Anvil chain is $2_000
        uint256 expectedValue = chainSphere.getUsdValueOfEthAmount(ethAmount);
        assertEq(actualValue, expectedValue);
    }

    ///////////////////////////
    //Getter Functions Tests //
    ///////////////////////////

    // test passes
    function testCanGetUsernameOfRecentWinners() public registerTenUsersWhoPostAndCastVotes timePassed skipFork {
        uint256 WINNING_REWARD = 0.01 ether;

        vm.recordLogs(); // saves all output logs
        vm.deal(address(chainSphere), STARTING_BALANCE);
        chainSphere.performUpkeep(" "); // emits requestId
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 requestId = entries[0].topics[2];

        VRFCoordinatorV2Mock(vrfCoordinator).fulfillRandomWords(
            uint256(requestId), 
            address(chainSphere)
        );

        address winnerAddress = chainSphere.getPostById(
            chainSphere.getIdsOfRecentWinningPosts()[0]
        ).author;
        console.log(winnerAddress.balance);
        console.log(STARTING_BALANCE + WINNING_REWARD - EDITING_FEE);
        
        string[] memory winnerName = chainSphere.getUsernameOfRecentWinners();
        // console.log("Name of Winner: ", winnerName);
        assert(
            keccak256(abi.encode(winnerName)) != keccak256(abi.encode(""))
        );
    }

    // test passes
    function testCanGetRecentWinningPosts() public registerTenUsersWhoPostAndCastVotes timePassed skipFork {
        // uint256 WINNING_REWARD = 0.01 ether;

        vm.recordLogs(); // saves all output logs
        vm.deal(address(chainSphere), STARTING_BALANCE);
        chainSphere.performUpkeep(" "); // emits requestId
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 requestId = entries[0].topics[2];

        VRFCoordinatorV2Mock(vrfCoordinator).fulfillRandomWords(
            uint256(requestId), 
            address(chainSphere)
        );
        
        assert(chainSphere.getRecentWinningPosts().length > 0);
    }

    function testCanGetRecentTrendingPosts() public registerTenUsersWhoPostAndCastVotes timePassed skipFork {
        // uint256 WINNING_REWARD = 0.01 ether;

        vm.recordLogs(); // saves all output logs
        vm.deal(address(chainSphere), STARTING_BALANCE);
        uint256 recentPosts = chainSphere.getIdsOfRecentPosts().length;
        chainSphere.performUpkeep(" "); // emits requestId
        uint256 eligiblePosts = chainSphere.getIdsOfEligiblePosts().length;
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 requestId = entries[0].topics[2];

        VRFCoordinatorV2Mock(vrfCoordinator).fulfillRandomWords(
            uint256(requestId), 
            address(chainSphere)
        );
        
        console.log(recentPosts);
        console.log(eligiblePosts);
        console.log(chainSphere.getIdsOfEligiblePosts().length);
        assert(chainSphere.getRecentTrendingPosts().length > 0);
    }
}