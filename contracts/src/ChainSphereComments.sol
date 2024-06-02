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

import { ChainSpherePosts as CSPosts}  from "./ChainSpherePosts.sol";

contract ChainSphereComments is CSPosts {

    //////////////
    /// Errors ///
    //////////////
    
    error ChainSphere__NotCommentOwner();
    

    ///////////////////////////////////
    /// Type Declarations (Structs) ///
    ///////////////////////////////////

    
    /**
    * @dev the comment struct uniquely saves all the relevant information about a comment
    * @param commentId is the id of the comment. The commentId is only unique with respect to each post. This number is generated serially as each comment is created on a post
    * @param author is the address of the user who commented on the post. This is useful to track for issuing of rewards for authors whose posts are adjuged as eligible for rewards.
    * @param postId is the id of the post. The postId is unique and is used to uniquely identify a post. This number is generated serially as each post is created
    * @param content is the content of the comment
    * @param timestamp is the time the comment was created.
    * @param likesCount is the number of likes acrued by the comment. This indicates how useful other users perceive the comment to be. 
    * @param authorNickName is the username (nick name) of the creator (author) of the comment.
    * @param authorFullName is the full name of the creator (author) of the comment.
    * @param authorProfileImgHash is the hash of profile picture of the creator (author) of the comment.
     */
    struct Comment {
        uint256 commentId;
        address author;
        uint256 postId;
        string content;
        uint256 timestamp;
        uint256 likesCount;
        string authorNickName;
        string authorFullName;
        string authorProfileImgHash;
    }

    ///////////////////////
    /// State Variables ///
    ///////////////////////

    /* For gas efficiency, we declare variables as private and define getter functions for them where necessary */

    // Constants
    uint256 private immutable i_minimumUsd;

    // Mappings

    /** Variables Relating to Comment */

    mapping(uint256 postId => Comment[]) private s_postIdToComments; // gets array of comments on a post using the postId
    mapping(uint256 postId => mapping(uint256 commentId => address))
        private s_postAndCommentIdToAddress; // gets comment author using the postId and commentId

    mapping(address => Comment[]) private s_userComments; // gets an array of comments by a user using user address
    mapping(uint256 postId => mapping(uint256 commentId => mapping(address liker => bool)))
        private s_likedComment; // indicates whether a comment is liked by a user using postId and commentId and userAddress
    mapping(uint256 postId => mapping(uint256 commentId => address[])) private s_likersOfComment; // gets an array of likers of a comment using the postId and commentId
    Comment[] private s_comments;
    mapping(uint256 postId => uint256[] commentsId) private s_postIdToCommentsId; // gets array of comment ids on a post using the postId
    uint256 private s_commentsId;
    mapping(uint256 postId => uint256 nextCommentId) private s_postIdToNextCommentId;

    //////////////
    /// Events ///
    //////////////

    event CommentCreated(
        uint256 indexed commentId,
        string postAuthor,
        string commentAuthor,
        uint256 postId
    );
    
    /////////////////
    /// Modifiers ///
    /////////////////

    modifier _onlyCommentOwner(uint256 _postId, uint256 _commentId) {
        if (msg.sender != _getCommentsByPostId(_postId)[_commentId].author) {
            revert ChainSphere__NotCommentOwner();
        }
        _;
    }

    modifier _postExists(uint256 _postId) {
        if(_getPostById(_postId).author == address(0) || _postId >= _getAllPosts().length){
            revert ChainSphere__PostDoesNotExist();
        }
        _;
    }

    ///////////////////
    /// Constructor ///
    ///////////////////

    constructor(address _priceFeed, uint256 _minimumUsd) CSPosts(_priceFeed, _minimumUsd){
        i_minimumUsd = _minimumUsd;
    }

    /////////////////
    /// Functions ///
    /////////////////

    
    /**
     * @dev createComment enables registered users to comment on any post
     * @notice Since the postId is unique and can be mapped to author of the post, we only need the postId to uniquely reference any post in order to comment on it
     * Because in any social media platform there are so much more comments than posts, we allow the commentId not to be unique in general. However, comment ids are unique relative to any given post. Our thought is that this will prevent overflow
     */
    function _createComment(uint256 _postId, string memory _content)
        internal
        _checkUserExists(msg.sender) _postExists(_postId)
    {
        
        uint256 _commentId = s_postIdToNextCommentId[_postId]++; // get the next commentId for the post
        
        Comment memory newComment = Comment({
            commentId: _commentId,
            author: msg.sender,
            postId: _postId,
            content: _content,
            timestamp: block.timestamp,
            likesCount: 0,
            authorNickName: _getUser(msg.sender).nickName,
            authorFullName: _getUser(msg.sender).fullNameOfUser,
            authorProfileImgHash: _getUser(msg.sender).profileImageHash
        }); // create a new comment

        s_postAndCommentIdToAddress[_postId][_commentId] = msg.sender; // update the mappings array with the new comment
        s_postIdToComments[_postId].push(newComment); // add comment to post comments
        s_userComments[msg.sender].push(newComment);

        
        // emit CommentCreated(_commentId, postAuthor, commenter, _postId);
        
    }

    /**
     * @dev This function allows only the user who created a comment to edit it.
     * @param _postId is the id of the post which was commented
     * @param _commentId is the id of the comment of interest
     * @param _content is the new content of the comment
     */
    function _editComment(
        uint256 _postId,
        uint256 _commentId,
        string memory _content
    ) public _onlyCommentOwner(_postId, _commentId) {
        // get the comment from the Blockchain (call by reference) and update it
        s_postIdToComments[_postId][_commentId].content = _content;
    }


    /**
     * @dev This function allows only the user who created a comment to delete it. 
     * @param _postId is the id of the post which was commented
     * @param _commentId is the id of the comment of interest
     * @notice the function checks if the caller is the owner of the comment and has paid the fee for deleting comment
     */
    function _deleteComment(uint256 _postId, uint256 _commentId) internal _onlyCommentOwner(_postId, _commentId) {
        // get the comment from the Blockchain (call by reference) and update it
        s_postIdToComments[_postId][_commentId].content = ""; // delete content
        s_postIdToComments[_postId][_commentId].author = address(0); // delete address of comment author
        s_postIdToComments[_postId][_commentId].authorNickName = "";
        s_postIdToComments[_postId][_commentId].authorFullName = "";
        s_postIdToComments[_postId][_commentId].authorProfileImgHash = "";
    }

    /**
    * @dev this function allows a registered user to like any comment
    * @param _postId is the id of the post which was commented
    * @param _commentId is the id of the comment in question
    * @notice the function increments the number of likes on the comment by 1 and adds user to an array of likers
     */
    function _likeComment(uint256 _postId, uint256 _commentId)
        internal
        _checkUserExists(msg.sender)
    {
        if(s_likedComment[_postId][_commentId][msg.sender] == false){
            // There is need to note the users that like a comment
            s_likedComment[_postId][_commentId][msg.sender] = true;
            // retrieve the comment from the Blockchain in increment number of likes
            s_postIdToComments[_postId][_commentId].likesCount++;
            // Add liker to an array of users that liked the comment
            s_likersOfComment[_postId][_commentId].push(msg.sender);
        }
        
    }

    
    //////////////////////
    // Getter Functions //
    //////////////////////

    /**
    * @dev function retrieves all information about a comment on a post given the postId and the commentId
    * @param _commentId is the id of the comment. 
    * @return function returns the comment corresponding to that postId and commentId
     */
    function _getCommentByCommentId(uint256 _commentId)
        internal
        view
        returns (Comment memory)
    {
        return s_comments[_commentId];
    }

    /**
    * @dev function retrieves all users that liked a comment on a post given the postId and the commentId
    * @param _commentId is the id of the comment. 
    * @return function returns an array of userAddresses that liked the  comment
     */
    function _getCommentLikersByPostIdAndCommentId(
        uint256 _postId,
        uint256 _commentId
    ) internal view returns (address[] memory) {
        return s_likersOfComment[_postId][_commentId];
    }

    /**
    * @dev function retrieves all comments by a user given the userAddress
    * @param _userAddress is the wallet address of user
    * @return function returns an arry of all comments by the user
     */
    function _getUserComments(address _userAddress)
        internal
        view
        returns (Comment[] memory)
    {
        // Implementation to retrieve all comments by a user
        return s_userComments[_userAddress];
    }

    /**
    * @dev function retrieves all comments on a given post
    * @param _postId is the id of the post we want to retrieve its comments
    * @return function returns an arry of all comments on the post
     */
    function _getCommentsByPostId(uint256 _postId) internal view returns(Comment[] memory) {
        if(_postId >= _getAllPosts().length){
            revert ChainSphere__PostDoesNotExist();
        }

        return s_postIdToComments[_postId];
        
    }

}
