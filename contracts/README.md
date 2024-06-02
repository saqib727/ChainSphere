## About
This Project called `ChainSphere` uses Chainlink Price Feed, Chainlink Verifiable Random Function (VRF) and Chainlink Automation to build a Decentralized Social Media Platform where users have control of their data and community beneficial contents are encouraged via periodic issuance of rewards to authors of posts picked randomly using VRF from a set of eligible posts.

## Setting Up
If you are looking for a quick way to replicate this repository, you can easily clone it using the below command

```javascript
git clone https://github.com/Ksc55/ChainSphere
```

To setup the project from scratch, you can follow the below steps:

1. Create a new repository and give it a name of your choosing
    ```javascript
    mkdir <name-of-repo>
    ```
    In our case we replaced the `<name-of-repo>` with `ChainSphere` i.e.
    ```javascript
    mkdir ChainSphere
    cd ChainSphere
    ```
2. Initialize the directory as a foundry project using
   ```javascript
   forge init
   ```
   If you don't have foundry installed, you can checkup the installation guide on 
   ```javascript
   https://book.getfoundry.sh/
   ```
Other dependency files can be installed by following the bellow instructions

### 1. Importing the VRFv2 from Chainlink

To import VRFv2 from Chainlink for use in our Contract, we use this command
```javascript
forge install smartcontractkit/chainlink-brownie-contracts@0.6.1 --no-commit
```
**Note:** in our project, we later modified the VRFv2 files to conform with VRFv2.5 as used in the project.

Next, we go to our `foundry.toml` file and use `remappings` to redirect our imports to the location of the relevant file imports on our local machine. This is because sometimes, when we download dependencies on our local machine, the file path may vary from what is obtainable on the github repo. We remap in `foundry.toml` using the following command
```javascript
remappings = ["@chainlink/contracts/src/v0.8/vrf=lib/chainlink-brownie-contracts/contracts/src/v0.8"]
```

### 2. Link Tokens for Chainlink Subscription
The `LinkToken.sol` file in `test/mocks` directory was created to enable us fund our subscription for testing locally on `Anvil`. `Anvil` is a local Blockchain in `Foundry` for testing during development. Use the following command to download dependency files for the `LinkToken.sol`
```javascript
forge install transmissions11/solmate --no-commit
```

We then edit `remappings` in our `foundry.toml` file to enable us pick the dependency on our local machine without changing the file path on our `LinkToken.sol` file. Our `remappings` now become

```javascript
remappings = ["@chainlink/contracts/src/v0.8/vrf=lib/chainlink-brownie-contracts/contracts/src/v0.8", "@solmate=lib/solmate/src"]
```

### 3. Install Foundry DevOps

The foundry devOps repo enables us to get the most recent deployment from a given environment in foundry. This way, we can do scripting of previous deployments in solidity.
```javascript
forge install Cyfrin/foundry-devops --no-commit
```
Update your `foundry.toml` to have read permissions on the broadcast folder.
```javascript
fs_permissions = [{ access = "read", path = "./broadcast" }]
```

## Smart Contracts
In order to make our Code base modular, we split the Smart Contracts into four seperate but interconnected Smart Contracts. This way, the Code base becomes easy to read, debug or refactor.

### ChainSphere.sol Contract
The `ChainSphere.sol` Contract is the main Contract that coordinates the transactions on the Dapp. It is the the Contract that uses interact directly with, and the Contract in turn delegates the task to the Contract responsible for execution.

The `ChainSphere.sol` Contract consists of the following components:

**1. Imports:** The Contract has some Contracts for which it inherits from. We use named imports this way, we are specific about the Contract we are importing from a Script. This becomes useful in situations where a Script contains multiple Contracts where only some of the Contracts are needed. By using named imports, we reduce the deployment cost of our Contract. Imported Contracts are as follows
```javascript
import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import { ChainSphereUserProfile as CSUserProfile}  from "./ChainSphereUserProfile.sol";
import { ChainSpherePosts as CSPosts}  from "./ChainSpherePosts.sol";
import { ChainSphereComments as CSComments}  from "./ChainSphereComments.sol";
```
The above imports consist of Chainlink contracts that will enable us use the following Chainlink services: Verifiable Random Function (VRF), Price Feed and Automation. These services enable the Smart to pick eligible users randomly for reward automatically at regular time intervals whenever all conditions are met.

Also, the Contract imports the `ChainSphereUserProfile` which handles tasks related to user registration and user profile editing, `ChainSpherePosts` which handles tasks related to posts and `ChainSphereComments` which handles tasks related to comments.

The Contract inherits the functionalities of four Contracts by using the `as` keyword in the Contract definition as shown below:
```javascript
contract ChainSphere is VRFConsumerBaseV2, CSUserProfile, CSPosts, CSComments {
```


**2. Custom Errors and Variables:** The function has one Custom Error and several variables. The Custom Error is used to specifiy the reason for reverting a transaction in a more gas efficient way.
```javascript
//////////////
/// Errors ///
//////////////
error ChainSphere__NotOwner();
```
The Contract also have `immutable` variables. These are variables whose values are set at compilation time and cannot be changed again. These variables are not kept in storage but form part of the Contract bytecode making the Contract more gas efficient.
```javascript
uint256 private immutable i_interval; // Period that must pass before a set of posts can be adjudged eligible for reward based on their postScore
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    uint256 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
```
There are constant variables also which form part of the Contract bytecode since they do not change during Contract execution.
```javascript
// VRF2 Constants
uint16 private constant REQUEST_CONFIRMATIONS = 3;
uint8 private constant TEN = 10; // Maximum percentage of winners to be picked out of an array of eligible authors
uint8 private constant TWENTY = 20; // Number of eligible authors beyond which a maximum of 10% will be picked for award
uint8 private constant HUNDRED = 100;
```

We use the `i_` and `s_` prefixes and `upper case` for `immutable`, `storage` and `constant` variables respectively in our variables naming convention for easy reading of the Code base.

Lastly, all variables are declared `private` since they are more gas efficient than `public` variables.

**3. Modifiers:** The Contract has two modifiers which are used to carry out checks before any task is executed during function calls where necessary
```javascript
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
```

**Note:** The `ChainSphere__NotPostOwner();` custom error is not explicitly defined in this Contract because it is inherited from the `ChainSpherePosts.sol` Contract.

**4. Constructor Function:** The Contract has a Constructor Function. A Constructor function defines any parameters that must be supplied before an instance of that Contract is created.
```javascript
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
```

The Constructor Function receives seven parameters, passes one parameter to the `VRFConsumerBaseV2` Contract and two parameters to the `CSComments` Contract as required. The Constructor then sets the values of the `immutable` variables at compile time, forming part of the Contract byte code.

**5. Receive and Fallback Functions:** The Contract has a `receive` and a `fallback` function. 
```javascript
//////////////////////////////////////////
/// The Receive and Fallback Functions ///
//////////////////////////////////////////

/**
 * @dev this function enables the Smart Contract to receive payment
 * @notice this function allows the Contract to receive ETH as value sent through a function call in the Smart Contract
 */
receive() external payable {}

/**
 * @dev this function enables the Smart Contract to receive payment
 * @notice this function allows the Contract to receive ETH even without a function call in the Smart Contract e.g. by just sending ETH using the Contract Address
 */
fallback() external payable {}
```

The `receive` function allows the Contract to receive ETH as value sent through a function call in the Smart Contract while the `fallback` function allows the Contract to receive ETH without calling any of the functions in the Smart Contract.

**6. Public Functions:** These are functions that can be called by anyone or Contract that is interacting with the ChainSphere contract. These functions include:

   **i. The `registerUser` function:** This function enables user registration on the ChainSphere platform. This function receives `_fullNameOfUser` and `_username` as arguments and calls the `ChainSphereUserProfile::_registerUser` function, passing the parameters to it for execution.
   ```javascript
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
   ```
   **Note:** in the notation `<contract-name>::<method-or-attribute-name>`, `<contract-name>` refers to the contract name while `<method-or-attribute-name>` refers to either a method (function) or attribute (variable) of the Contract. For example, in `ChainSphereUserProfile::_registerUser`, `ChainSphereUserProfile` refers to the contract name while `_registerUser` refers to function name.

   **ii. The `changeUsername` function:** This function enables a user to change their username. The function receives `_userId` and `_newNickName` as arguments and calls the `ChainSphereUserProfile::_changeUsername` function, passing the parameters to it for execution.
   ```javascript
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
   ```

   **iii. The `editUserProfile` function:** This function enables a user to edit their profile. The function receives `_userId`, `_bio`, `_profileImageHash` and `_newName` as arguments and calls the `ChainSphereUserProfile::_editUserProfile` function, passing the parameters to it for execution.
   ```javascript
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
   ```

   **iv. The `createPost` function:** This function enables a user to create a post. The function receives `_content` and `_imgHash` as arguments and calls the `ChainSpherePosts::_createPost` function, passing the parameters to it for execution.
   ```javascript
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
   ```

   **v. The `editPost` function:** This function enables a user to edit their post. The function receives `_postId`, `_content` and `_imgHash` as arguments and calls the `ChainSpherePosts::_editPost` function, passing the parameters to it for execution.
   ```javascript
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
   ```

   **vi. The `deletePost` function:** This function enables a user to delete their post. The function receives `_postId` as argument and calls the `ChainSpherePosts::_deletePost` function, passing the parameters to it for execution.
   ```javascript
   /**
     * @dev A user should pay to delete post. The rationale is, to ensure users go through their content before posting since deleting of content is not free
     * @param _postId is the id of the post to be deleted
     * @notice The function checks if the user has paid the required fee for deleting post before proceeding with the action. To effect the payment functionality, we include a receive function to enable the smart contract receive ether. Also, we use Chainlink pricefeed to ensure ether is amount has the required usd equivalent
     */
    function deletePost(uint256 _postId) public payable onlyPostOwner(_postId) _hasPaid {
        _deletePost(_postId);
    }
   ```
   The function is tagged `payable` because the user is expected to pay to delete a post. Marking the function as `payable` allows the Smart Contract to receive ETH when the function is called. The `onlyPostOwner` modifier ensures that the caller of the function is the owner of the post while the `_hasPaid` modifier ensures that owner sends some ETH as required fee during the function call. If any of these conditions does not hold true, the transaction is reverted.

   **vii. The `upvote` function:** This function enables a user to cast an upvote on a post they find useful or has positive impact. The function receives `_postId` as argument and calls the `ChainSpherePosts::_upvote` function, passing the parameters to it for execution.
   ```javascript
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
   ```

   **viii. The `downvote` function:** This function enables a user to cast a downvote on a post they judge as having negative impact. The function receives `_postId` as argument and calls the `ChainSpherePosts::_downvote` function, passing the parameters to it for execution.
   ```javascript
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
   ```

   **ix. The `createComment` function:** This function enables a user to comment on any post on the ChainSphere platform. The function receives `_postId` and `_content` as arguments and calls the `ChainSphereComments::_createComment` function, passing the parameters to it for execution.
   ```javascript
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
   ```

   **x. The `editComment` function:** This function enables a user to edit their comment on any post on the ChainSphere platform. The function receives `_postId`, `_commentId` and `_content` as arguments and calls the `ChainSphereComments::_editComment` function, passing the parameters to it for execution.
   ```javascript
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
   ```

   **xi. The `deleteComment` function:** This function enables a user to delete their comment on any post on the ChainSphere platform. The function receives `_postId` and `_commentId` as arguments and calls the `ChainSphereComments::_deleteComment` function, passing the parameters to it for execution.
   ```javascript
   /**
     * @dev This function allows only the user who created a comment to delete it. 
     * @param _postId is the id of the post on which the comment was made
     * @param _commentId is the id of the comment of interest
     * @notice the function checks if the caller is the owner of the comment and has paid the fee for deleting comment
     */
    function deleteComment(uint256 _postId, uint256 _commentId) public payable _hasPaid {
        _deleteComment(_postId, _commentId); 
    }
   ```

   **xii. The `likeComment` function:** This function enables a user to like any comment on any post on the ChainSphere platform. The function receives `_postId` and `_commentId` as arguments and calls the `ChainSphereComments::_likeComment` function, passing the parameters to it for execution.
   ```javascript
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
   ```

**7. Chainlink Functions:** These functions enable the Smart Contract to use the Chainlink Services integrated into the it. These functions include

**i. The `CheckUpkeep` function:** This function resets the `ChainSpherePosts::s_idsOfEligiblePosts` array, calls the `ChainSpherePosts::_pickIdsOfEligiblePosts` function to pick eligible posts from the `ChainSpherePosts::s_idsOfRecentPosts` array and then checks if the necessary conditions for selecting a winner or winner(s) are met and returns a `bool` describing the state of the Contract. The conditions for selecting winner(s) are: the time period has passed, there are at least one eligible post, and the Contract has a non-zero balance - all conditions must hold true.
```javascript
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
```

**ii. The `performUpkeep` function:** This function calls the `CheckUpkeep` function to check if the necessary conditions for selecting a winner or winner(s) are met. If the `CheckUpkeep` function returns `false`, the `performUpkeep` function reverts else, the `performUpkeep` function requests random words (random numbers) from the Chainlink oracles via the `vrfCoordinator` which will then be used to select the winner(s). Note that only the `vrfCoordinator` can request random words from the Chainlink oracles.

The number of words to request depends on the number of eligible posts on the platform during the current period. If there are 20 or fewer eligible posts, this function will request 1 random word from the Chainlink oracles else, the function will request no more than 10% of the number of eligible posts as random words.
```javascript
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
```

**iii. The `fulfillRandomWords` function:** This function receives as argument the array of random words generated by the Chainlink oracles, resets the `ChainSpherePosts::s_idsOfRecentPosts` array, sets the present time as the `s_lastTimeStamp` and resets the `ChainSpherePosts::s_idsOfRecentWinningPosts` array. The function then uses the modulo operator to convert the random words generated by the Chainlink oracles to numbers that lie between the index of numbers in the `ChainSpherePosts::s_idsOfEligiblePosts` array. The function then picks the posts whose id's lie in the selected indices. This way, the winners are selected randomly.

The function then divides 20% of the Contract balance among the seleceted winners, adds the id of each selected post into the `ChainSpherePosts::s_idsOfRecentWinningPosts` array, and pays each winner their reward.
```javascript
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
```

**8. Private Functions:** These are functions that can only be called by the `ChainSphere` Contract. Since there is no reason for any one or any other contract to call these functions, they are marked as private for gas optimization. These functions include:

**i. The `resetIdsOfEligiblePosts` function:** This function calls the `ChainSpherePosts::_resetIdsOfEligiblePosts` function which in turn resets the `ChainSpherePosts::_idsOfEligiblePosts` array.
```javascript
/**
* @dev this function resets the array containing the ids of posts eligible for reward. This function is called when the process for selecting the next winner is initiated
* @notice only this contract should be able to call this function.
    */
function resetIdsOfEligiblePosts() private {
    _resetIdsOfEligiblePosts();
}
```

**ii. The `resetIdsOfRecentWinningPosts` function:** This function calls the `ChainSpherePosts::_resetIdsOfRecentWinningPosts` function which in turn resets the `ChainSpherePosts::_idsOfRecentWinningPosts` array.
```javascript
/**
* @dev this function resets the array containing the ids of recent winning post(s). This function is called when the next winner is just about to be selected
* @notice only this contract should be able to call this function.
    */
function resetIdsOfRecentWinningPosts() private {
    _resetIdsOfRecentWinningPosts();
}
```

**iii. The `addIdToIdsOfRecentWinningPosts` function:** This function receives the `_idOfWinningPost` as argument and calls the `ChainSpherePosts::_addIdToIdsOfRecentWinningPosts` function which in turn adds the `_idOfWinningPost` to the `ChainSpherePosts::_idsOfRecentWinningPosts` array.
```javascript
/**
* @dev this function adds a postId to the array containing the ids of winning post(s). This function is called whenever a winner is selected
* @param _idOfWinningPost is the postId to be added to the s_idsOfRecentWinningPosts
* @notice only this contract should be able to call this function.
    */
function addIdToIdsOfRecentWinningPosts(uint256 _idOfWinningPost) private {
    _addIdToIdsOfRecentWinningPosts(_idOfWinningPost);
}
```

**iv. The `resetIdsOfRecentPosts` function:** This function calls the `ChainSpherePosts::_resetIdsOfRecentPosts` function which in turn resets the `ChainSpherePosts::_idsOfRecentPosts` array.
```javascript
/**
* @dev this function resets the array containing the ids of recent post(s). This function is called after a winner is selected. The array is reset so that new posts can be saved in the array for the next selection process. This way, an author doesn't get rewarded more than once on the same post
* @notice only this contract should be able to call this function.
*/
function resetIdsOfRecentPosts() private {
    _resetIdsOfRecentPosts();
}
```

**9. Getter Functions:** as the name implies, getter functions enable us to view state variables from the Blockchain. All getter functions have `returns` in their function definition specifying what the function is expected to return. The Smart Contract has numerous getter functions.


### ChainSphereUserProfile.sol Contract
The `ChainSphereUserProfile.sol` Contract handles tasks related to user registration and profile editing.

The `ChainSphereUserProfile.sol` Contract consists of the following components:

**1. Custom Errors and Variables:** The function has `three (3) Custom Errors`, `two (2) structs` and several variables. The Custom Error is used to specifiy the reason for reverting a transaction in a more gas efficient way.
```javascript
//////////////
/// Errors ///
//////////////

error ChainSphere__UsernameAlreadyTaken();
error ChainSphere__UserDoesNotExist();
error ChainSphere__NotProfileOwner();
```

A `struct` is a user defined variable type. A struct groups related variables of different primitive types together.
```javascript
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
```

The Contract also have `storage` variables and one event. 
```javascript
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

```

**2. Modifiers:** The Contract has three modifiers which are used to carry out checks before any task is executed during function calls where necessary
```javascript
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
```

**3. Internal Functions:** These are functions that can only be called by their child Contracts. These functions include:

   **i. The `_registerUser` function:** This function receives `_fullNameOfUser` and `_username` as arguments and carries out the following tasks: checks if `_username` already exists (i.e. if another user has registered on the platform with that usernaem), generates a id for the each user serially, and creates a new user using the `User struct` and adds user to the array of users.
   Note that the contract uses some mappings. Mappings are a more efficient way of checking for conditions or querring a database on the Blockchain instead of using for loops which are more gas intensive in Solidity.
   ```javascript
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
   ```

   **ii. The `_changeUsername` function:** This function receives `_userId` and `_newNickName` as arguments, locates the user whose id is `_userId` and sets their `nickName` as `_newNickName` using the `dot notation` i.e. ` s_users[_userId].nickName = _newNickName;`.
   ```javascript
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
   ```

   **iii. The `_editUserProfile` function:** This function receives `_userId`, `_bio`, `_profileImageHash` and `_newName` as arguments, locates the user whose id is `_userId` and edits only the profile entries that are not empty. This means that if for example the user does not intend to modify their bio, the user should just leave the `_bio` as an empty string.
   ```javascript
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
   ```



**9. Getter Functions:** as the name implies, getter functions enable us to view state variables from the Blockchain. All getter functions have `returns` in their function definition specifying what the function is expected to return. In addition, all the getter functions are marked `internal` so that only inheriting Contracts can call. This makes it possible for the `ChainSphere` contract to view private variables on the `ChainSphereUserProfile` contract. Some of the getter functions include:

**i. The `_getAddressFromUsername` function:** This function receives the `_username` of the user as argument and returns the user address as output.
```javascript
/**
* @dev function retrieves userAddress given username(i.e. nickname) of user
* @param _username is the username or nick name of user
* @notice function returns wallet address of the user
    */
function _getAddressFromUsername(string memory _username) internal view returns(address) {
    return s_usernameToAddress[_username];
}
```

**ii. The `_getUser` function:** This function receives the `_userAddress` of the user as argument and returns the profile of the user as output.
```javascript
/**
* @dev function retrieves user profile given the userAddress
* @param _userAddress is the wallet address of user
* @return function returns the profile of the user
    */
function _getUser(address _userAddress) internal view returns (User memory) {
    return s_addressToUserProfile[_userAddress];
}
```

### ChainSpherePosts.sol Contract
The `ChainSpherePosts.sol` Contract handles all post related tasks.

The `ChainSpherePosts.sol` Contract consists of the following components:

**1. Imports:** The Contract has some Contracts for which it inherits from. We use named imports this way, we are specific about the Contract we are importing from a Script. This becomes useful in situations where a Script contains multiple Contracts where only some of the Contracts are needed. By using named imports, we reduce the deployment cost of our Contract. Imported Contracts are as follows
```javascript
import {PriceConverter} from "./PriceConverter.sol";
import { ChainSphereUserProfile as CSUserProfile} from "./ChainSphereUserProfile.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
```
The above imports consist of Chainlink contracts that will enable us use the Chainlink Price Feed services. This service enable the Smart Contract to check if the amount of ETH sent through a function call has a USD value equal to some specified USD amount.

Also, the Contract imports the `ChainSphereUserProfile` which handles tasks related to user registration and user profile editing, `ChainSpherePosts`.

The Contract inherits the functionalities of the `ChainSphereUserProfile` Contract by using the `as` keyword in the Contract definition as shown below:
```javascript
contract ChainSpherePosts is  CSUserProfile {
    using PriceConverter for uint256;
```
Also, all varibles in the `ChainSpherePosts` Contract of type `uint256` can call methods in the `PriceConverter.sol` library specified because of the following line of code `using PriceConverter for uint256;`.

**2. Custom Errors and Variables:** The function has some Custom Errors and several variables. The Custom Error is used to specifiy the reason for reverting a transaction in a more gas efficient way.

**3. Modifiers:** The Contract has two modifiers which are used to carry out checks before any task is executed during function calls where necessary
```javascript
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
```

**4. Constructor Function:** The Contract has a Constructor Function. A Constructor function defines any parameters that must be supplied before an instance of that Contract is created.
```javascript
///////////////////
/// Constructor ///
///////////////////

constructor(address _priceFeed, uint256 _minimumUsd){
    s_priceFeed = AggregatorV3Interface(_priceFeed);
    i_minimumUsd = _minimumUsd;
}
```

The Constructor Function receives two parameters and sets the values of the `immutable` variables at compile time, forming part of the Contract byte code.


**5. Internal Functions:** These are functions that can only be called by their child Contracts. These functions include:

   **i. The `_createPost` function:** This function receives `_content` and `_imgHash` as arguments, checks if the user is registered on the platform, generates an id for the new post serially and then creates a new post using the `Post struct` which the `ChainSpherePosts` contract inherits from the `ChainSphereUserProfile` contract. Aside from adding the new post to an array of posts in storage, the function also adds the postId to the `s_idsOfRecentPosts` array for possible nomination as an eligible post for reward. It is more gas efficient to store an array of ids than an array of structs.
   ```javascript
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
   ```

   **ii. The `_editPost` function:** This function receives `_postId`, `_content` and `_imgHash` as arguments and edits the post accordingly.
   ```javascript
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
   ```

   **iii. The `_deletePost` function:** This function receives `_postId` as argument and deletes the content of the post. Since deleting is technically not possible on the Ethereum Virtual Machine, we change the various components of the post as follows: sets the `content`, `imgHash`, `authorNickName` and `authorFullName` as `empty string`; sets the  `timestamp`, `upvotes` and `downvotes` to `0`; and resets the `author` to `address(0)`.
   
   ```javascript
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
   ```

   Another option would have been to copy the array of posts (say arrayA) excluding the post we intend to delete into another array of posts in memory (say arrayB) and replace the initial array with the copied array. This way, the array of posts in storage now does not include the deleted post. This however involves a lot of computations and attracks a lot of gas fee and therefore not considered.
   

   **iv. The `_upvote` function:** This function receives `_postId` as argument and performs some checks before carrying out the required task. If the caller of the function is the author of the post, or if the author has cast a vote on the post already, the transaction reverts. Else, the function changes the vote status of the caller for the post as `true`, locates the post whose id is `_postId` and increments number of upvotes by `1`.
   ```javascript
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
   ```

   **v. The `_downvote` function:** This function receives `_postId` as argument and performs some checks before carrying out the required task. If the caller of the function is the author of the post, or if the author has cast a vote on the post already, the transaction reverts. Else, the function changes the vote status of the caller for the post as `true`, locates the post whose id is `_postId` and increments number of downvotes by `1`.
   ```javascript
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
   ```

**vi. The `_pickIdsOfEligiblePosts` function:** This function receives an array of ids `_idsOfRecentPosts`, uses a `for loop` to check if the each post in the array is eligible for reward by calling the `_isPostEligibleForReward` function. If a post is eligible for reward, the `postId` is added to an array of eligible posts `s_idsOfEligiblePosts`.
```javascript
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
```


**6. Private Functions:** These are functions that can only be called by the `ChainSphere` Contract. Since there is no reason for any one or any other contract to call these functions, they are marked as private for gas optimization. These functions include:

**i. The `_isPostEligibleForReward` function:** This function accepts `_postId` as argument. The function obtains the number of upvotes and downvotes and calculates the `postScore` as the difference between the number of upvotes and the number of downvotes. The function uses a tenary operator to pick only positive numbers by setting negative numbers as zero i.e. `uint256 postScore = numOfUpvotes - numOfDownvotes > 0 ? numOfUpvotes - numOfDownvotes : 0;`. The function again uses a tenary operator to check if `postScore` surpases some minimum value and returns a `bool` i.e. `isEligible = postScore >= MIN_POST_SCORE ? true : false;`.
```javascript
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
```

**ii. The `_resetIdsOfEligiblePosts` function:** This function resets the array of ids of eligible posts `s_idsOfEligiblePosts`.
```javascript
/**
* @dev this function resets the array containing the ids of posts eligible for reward. This function is called when the process for selecting the next winner is initiated
    */
function _resetIdsOfEligiblePosts() internal {
    s_idsOfEligiblePosts = new uint256[](0);
}
```

**iii. The `_resetIdsOfRecentWinningPosts` function:** This function resets the array of ids of recent winning posts `s_idsOfRecentWinningPosts`.
```javascript
/**
* @dev this function resets the array containing the ids of recent winning post(s). This function is called when the next winner is just about to be selected
    */
function _resetIdsOfRecentWinningPosts() internal {
    s_idsOfRecentWinningPosts = new uint256[](0);
}
```

**iv. The `_addIdToIdsOfRecentWinningPosts` function:** This function receives the `_idOfWinningPost` as argument and adds it to the array of ids of recent winning posts `s_idsOfRecentWinningPosts`.
```javascript
/**
* @dev this function adds a postId to the array containing the ids of winning post(s). This function is called whenever a winner is selected
* @param _idOfWinningPost is the postId to be added to the s_idsOfRecentWinningPosts
    */
function _addIdToIdsOfRecentWinningPosts(uint256 _idOfWinningPost) internal {
    s_idsOfRecentWinningPosts.push(_idOfWinningPost);
}
```

**v. The `_resetIdsOfRecentPosts` function:** This function resets the array of ids of recent posts `s_idsOfRecentPosts`.
```javascript
/**
* @dev this function resets the array containing the ids of recent post(s). This function is called after a winner is selected. The array is reset so that new posts can be saved in the array for the next selection process. This way, an author doesn't get rewarded more than once on the same post
    */
function _resetIdsOfRecentPosts() internal {
    s_idsOfRecentPosts = new uint256[](0);
}
```

**9. Getter Functions:** as the name implies, getter functions enable us to view state variables from the Blockchain. All getter functions have `returns` in their function definition specifying what the function is expected to return. The Smart Contract has numerous getter functions.


### ChainSphereComments.sol Contract
The `ChainSphereComments.sol` Contract handles all post related tasks.

The `ChainSphereComments.sol` Contract consists of the following components:

**1. Imports:** The Contract has one Contract for which it inherits from. Imported Contract is as follows
```javascript
import { ChainSpherePosts as CSPosts}  from "./ChainSpherePosts.sol";
```

The Contract imports the `ChainSpherePosts` which handles tasks related to posts.


**2. Custom Errors and Variables:** The function has one Custom Error, one struct and several variables. The Custom Error is used to specifiy the reason for reverting a transaction in a more gas efficient way.
```javascript
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
```


**3. Modifiers:** The Contract has two modifiers which are used to carry out checks before any task is executed during function calls where necessary
```javascript
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
```

**4. Constructor Function:** The Contract has a Constructor Function. 
```javascript
///////////////////
/// Constructor ///
///////////////////
constructor(address _priceFeed, uint256 _minimumUsd) CSPosts(_priceFeed, _minimumUsd){
    i_minimumUsd = _minimumUsd;
}
```

The Constructor Function receives two parameters, passes both parameter to the `CPosts` Contract and then sets the values of the `immutable` variable at compile time, forming part of the Contract byte code.


**5. Internal Functions:** These are functions that can only be called by their child Contracts. These functions include:

   **i. The `_createComment` function:** This function receives `_postId` and `_content` as arguments, checks if the caller is registered on the platform and if the post exists. Where these conditions are satisfied, the function generates a `commentId` serially and creates a new comment using the `Comment struct` earlier defined in the contract. Comment ids are only unique relative to the post in question but are not unique in general. Hence to uniquely identify a comment, we use the `postId` and the `commentId` 
   ```javascript
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
   ```

   **ii. The `_editComment` function:** This function receives `_postId`, `_commentId` and `_content` as arguments, checks if the caller is the author of the comment and edits the comment accordingly.
   ```javascript
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
   ```

   **iii. The `_deleteComment` function:** This function receives `_postId` and `_commentId` as argument and deletes the content of the comment. Since deleting is technically not possible on the Ethereum Virtual Machine, we change the various components of the comment as follows: sets the `content`, `imgHash`, `authorNickName` and `authorFullName` as `empty string`; and resets the `author` to `address(0)`.
   ```javascript
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
   ```

   **iv. The `_likeComment` function:** This function receives `_postId` and `_commentId` as arguments; if the caller exists and if the caller has not liked the comment before, the function sets the caller like status to true and locates the comment that corresponds to these respective ids and increments the number of likes by 1.
   ```javascript
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
   ```


**6. Getter Functions:** as the name implies, getter functions enable us to view state variables from the Blockchain. All getter functions have `returns` in their function definition specifying what the function is expected to return. The Smart Contract has numerous getter functions. 

One notation getter function is `_getCommentsByPostId` function which accepts `_postId` as input, checks if the post exist and returns all comments on that post.
```javascript
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
```


### PriceConverter.sol Library
The `PriceConverter.sol` file is a library. A library contains methods that can be called by variables of a specified type in any Contract that imports the library and specifies the variable types to call the methods.

All functions (methods) in a library must be marked as `internal`. A library is declared using the `library` keyword followed by the name of the library i.e. `library PriceConverter {`.

The `PriceConverter` library has two functions: 
1. The `getPrice` function accepts a `priceFeed` as arguments and checks the price from the Chainlink oracles price feed.
   ```javascript
   // Create a function that gets the price of the token
    function getPrice(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        // Get the Address and ABI of the Contract the stores the price of ETH
        // on ChainLink website. From Sepolia TestNet we have
        // Address 0x694AA1769357215DE4FAC081bf1f309aDC325306 
        // ABI 
        // AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        // The 'latestRoundData' method returns five values. 
        // However, we are only interested in 'price'
        (, int256 price, , , ) = priceFeed.latestRoundData();
        // price of ETH in terms of USD
        // We employ a technique call type-casting to change a variable type
        // from int256 to uint256
        return uint256(price * 1e10);
    }
   ```
2. The `getConversionRate` function accepts the token amount and the priceFeed as inputs and returns the quantity of token that equals some value in USD.
   ```javascript
   // Create a function that converts the 'msg.value' base on the price
    function getConversionRate(uint ethAmount, AggregatorV3Interface priceFeed) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed);
        uint256 ethAmountInUsd = (ethAmount * ethPrice)/ 1e18;
        return ethAmountInUsd;

    }
   ```

## Other Scripts
The Smart Contract Code base also contains some other scripts used in the development process.
1. The `HelperConfig.s.sol` Script is used to setup the values of the various variables needed by the Constructor to create an instance of our Smart Contract. This file contains the configurations for several networks we may wish to deploy our contract to. With this file, we don't have to hard-code our Constructor variables.
2. The `DeployChainSphere.s.sol` file is the script that enables us to deploy our smart contract by simply running it.
3. The `Interactions.s.sol` script has three contracts: `CreateSubscription`, `FundSubscription` and `AddConsumer`. This script enables us to progammatically create a Chainlink Subscription using the `CreateSubscription` contract, add some funds (tokens) to our subscription using the `FundSubscription` contract and finally, add our deployed Contract as a consumer to our Chainlink Subscription using the `AddConsumer` contract. The `AddConsumer` contract uses the `Foundry DevOpps Tools` we installed from [Cyfrin](https://github.com/Cyfrin/foundry-devops) to get the most recently deployed contract to add as a consumer to our Subscription. When all this is done, the `Chainlink oracles` can keep watch over our contract thereby requesting `random words` using `Chainlink VRF` at regular time periods using `Chainlink Automation` so that winner(s) can then be picked if all pre-conditions hold true.
4. The `ChainSphereTest.t.sol` file is the test script for our Smart Contract. In this project, for want of time, we were only able to run unit tests for our code base.
5. The `Makefile` allows us to give our commands aliases (usually shorter names) which we can easily call. This is especially useful for frequently used commands for instance, to deploy our Contract on Sepolia test net, the command to run is
   ```javascript
   source .env
   forge script script/DeployChainSphere.s.sol:DeployChainSphere --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvvv
   ```
   But with our `Makefile`, to deploy our Contract on Sepolia test net we run the following command 
   ```javascript
   make deploy-sepolia
   ```
   which is way shorter and easier.
   

### Tests in Foundry
To run a test in foundry, navigate to the root directory of the project and run the following command
```bash
forge test
```
The above command will search for any files in the directory with a `.t.sol` extension and further search for any functions in such files whose names begin with `test` and execute them.

To run a specific test, run the following command instead
```bash
forge test --match-test <name-of-test>
```

To see the test coverage so far, run the following command
```bash
forge coverage
```

To test our code on Anvil using the Makefile, we run the following command
```bash
make test
```

To test our code on the Sepolia testnet using the Makefile, we run the following command
```bash
make test-sepolia
```

## License
This project is licensed under the MIT License