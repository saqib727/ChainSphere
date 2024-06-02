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

contract ChainSphereUserProfile {
    
    //////////////
    /// Errors ///
    //////////////
    
    error ChainSphere__UsernameAlreadyTaken();
    error ChainSphere__UserDoesNotExist();
    error ChainSphere__NotProfileOwner();
    
    ///////////////////////////////////
    /// Type Declarations (Structs) ///
    ///////////////////////////////////

    /**
    * @dev This struct stores user information or profile
    * @param id is uniquely generating id for each user. It can be used to uniquely identify a user
    * @param userAddress is the wallet address of user. This is the address of the wallet the user used to sign up on the platform
    * @param nickName is also known as the username of the user. This nickName (username) is unique such that it can be used to uniquely identify a user. This is supplied by the user during registration (sign up).
    * @param fullNameOfUser is the full name of the user. This does not need to be unique, is supplied by the user during registration (sign up).
    * @param bio is a short self introduction of the user. This can be used to know who the user is and what their aspirations are.
    * @param profileImageHash is the hash of the profile image of the user
     */
    struct User {
        uint256 id;
        address userAddress;
        string nickName; // must be unique
        string fullNameOfUser;
        string bio;
        string profileImageHash;
    }

    /**
    * @dev the post struct uniquely saves all the relevant information about a post
    * @param postId is the id of the post. The postId is unique and is used to uniquely identify a post. This number is generated serially as each post is created
    * @param content is the content of the post
    * @param imgHash is the hash of the image that may be associated with a post. This is not mandatory as a user may decide to create a post without uploading any image
    * @param timestamp is the time the post is created.
    * @param upvotes is the number of upvotes acrued by the post. This indicates how useful other users perceive the post to be. A user cannot vote their own post, a user cannot cast more than one vote on a particular post
    * @param downvotes is the number of downvotes acrued by the post. This indicates how not useful other users perceive the post to be. A user cannot vote their own post, a user cannot cast more than one vote on a particular post
    * @param author is the address of the creator (author) of the post. This is useful to track for issuing of rewards for authors whose posts are adjuged as eligible for rewards.
    * @param authorNickName is the username (nick name) of the creator (author) of the post.
    * @param authorFullName is the full name of the creator (author) of the post.
    * @param authorProfileImgHash is the hash of profile picture of the creator (author) of the post.
     */
    struct Post {
        uint256 postId;
        string content;
        string imgHash;
        uint256 timestamp;
        uint256 upvotes;
        uint256 downvotes;
        address author;
        string authorNickName;
        string authorFullName;
        string authorProfileImgHash;
    }

    ///////////////////////
    /// State Variables ///
    ///////////////////////

    /* For gas efficiency, we declare variables as private and define getter functions for them where necessary */

    
    // Mappings

    /** Variables Relating to User */
    User[] s_users; // array of users
    mapping(address => User) private s_addressToUserProfile;
    uint256 private userId;
    mapping(address => uint256) private s_userAddressToId; // gets userId using address of user
    // mapping(address => string) private s_userAddressToUsername; // gets username (i.e. nickname) using address of user
    mapping(string username => address userAddress) private s_usernameToAddress;
    string[] s_userNamesOfRecentWinners;

    
    //////////////
    /// Events ///
    //////////////

    event UserRegistered(
        uint256 indexed id,
        address indexed userAddress,
        string username
    );
    

    /////////////////
    /// Modifiers ///
    /////////////////

    modifier usernameTaken(string memory _username) {
        if (_getAddressFromUsername(_username) != address(0)) {
            revert ChainSphere__UsernameAlreadyTaken();
        }
        _;
    }

    modifier checkUserExists(address _userAddress) {
        if (_getUser(_userAddress).userAddress == address(0)) {
            revert ChainSphere__UserDoesNotExist();
        }
        _;
    }

    modifier onlyProfileOwner(uint256 _userId) {
        // check if msg.sender is the profile owner
        if (msg.sender != _getUserById(_userId).userAddress) {
            revert ChainSphere__NotProfileOwner();
        }
        _;
    }


    //////////////////////////
    /// Internal Functions ///
    //////////////////////////


    /**
    * @dev This function enables a user to be registered on ChainSphere
    * @param _fullNameOfUser is the full name of the User
    * @param _username is the user's nick name which must be unique. No two accounts are allowed to have the same nick name
     */
    function _registerUser(string memory _fullNameOfUser, string memory _username)
        internal
        usernameTaken(_username)
    {
        uint256 id = userId++;
        // For now, this is the way to create a post with empty comments
        User memory newUser = User({
            id: id,
            userAddress: msg.sender,
            nickName: _username,
            fullNameOfUser: _fullNameOfUser,
            bio: "",
            profileImageHash: ""
        });

        s_addressToUserProfile[msg.sender] = newUser;
        s_userAddressToId[msg.sender] = id;

        s_usernameToAddress[_username] = msg.sender;

        // Add user to list of users
        s_users.push(newUser);
        emit UserRegistered(id, msg.sender, _username);
    }

    /**
    * @dev this function allows a user to change thier nick name
    * @param _userId is the id of the user which is a unique number
    * @param _newNickName is the new nick name the user wishes to change to
    * @notice the function checks if the caller is the owner of the profile and if _newNickName is not registered on the platform yet
     */
    function _changeUsername(uint256 _userId, string memory _newNickName)
        internal
        checkUserExists(msg.sender)
        onlyProfileOwner(_userId)
        usernameTaken(_newNickName)
    {
        // change user name using their id
        s_users[_userId].nickName = _newNickName;
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
    function _editUserProfile(
        uint256 _userId,
        string memory _bio,
        string memory _profileImageHash,
        string memory _newName
    ) internal checkUserExists(msg.sender) onlyProfileOwner(_userId) {

        if(keccak256(abi.encode(_bio)) != keccak256(abi.encode(""))){
            s_users[_userId].bio = _bio; // bio is only updated if supplied by user
            s_addressToUserProfile[msg.sender].bio = _bio;
        }

        if(keccak256(abi.encode(_profileImageHash)) != keccak256(abi.encode(""))){
            s_users[_userId].profileImageHash = _profileImageHash; // profileImageHash is only updated if supplied by user
            s_addressToUserProfile[msg.sender].profileImageHash = _profileImageHash;
        }
        
        if(keccak256(abi.encode(_profileImageHash)) != keccak256(abi.encode(""))){
            s_users[_userId].fullNameOfUser = _newName; // fullNameOfUser is only updated if supplied by user
            s_addressToUserProfile[msg.sender].fullNameOfUser = _newName;
        }
    }

    
    //////////////////////
    // Getter Functions //
    //////////////////////

    /**
    * @dev function retrieves userAddress given username(i.e. nickname) of user
    * @param _username is the username or nick name of user
    * @notice function returns wallet address of the user
     */
    function _getAddressFromUsername(string memory _username) internal view returns(address) {
        return s_usernameToAddress[_username];
    }
    
    /**
    * @dev function retrieves username(i.e. nickname) of user given the userAddress
    * @param _userAddress is the wallet address of user
    * @notice function returns username(i.e. nickname) of the user
     */
    function _getUserNameFromAddress(address _userAddress)
        internal
        view
        returns (string memory nickNameOfUser)
    {
        nickNameOfUser = s_addressToUserProfile[_userAddress].nickName;
    }

    /**
    * @dev function retrieves user profile given the userAddress
    * @param _userAddress is the wallet address of user
    * @return function returns the profile of the user
     */
    function _getUser(address _userAddress) internal view returns (User memory) {
        return s_addressToUserProfile[_userAddress];
    }

    /**
    * @dev function retrieves user profile given the userId
    * @param _userId is the id of user. userId is unique
    * @return function returns the profile of the user
     */
    function _getUserById(uint256 _userId) internal view returns (User memory) {
        return s_users[_userId];
    }

}
