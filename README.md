## About
This Project called `ChainSphere` uses Chainlink Price Feed, Chainlink Verifiable Random Function (VRF) and Chainlink Automation to build a Decentralized Social Media Platform where users have control of their data and community beneficial contents are encouraged via periodic issuance of rewards to authors of posts picked randomly using VRF from a set of eligible posts.

## Frontend
The frontend of `ChainSphere` is built using react, with a user-centric UI design that gives the users seemless experience on the platform.

From the frontend, a user can register on the platform simply by connecting their wallet, entering their full name and a unique username or nickname, change their username and edit their profile. Users can also create post, view posts by other users, edit their post, delete their post (after paying some fee), cast votes on a post (either an `upvote` or a `downvote`) once, comment on posts,like comments, edit comments and also delete comments (this also attracts a fee).

The platform also has a `trending posts` section where users can see the recent trending posts. Trending posts are those posts that were judged as eligible for reward in the period before the current period.

Pictures uploaded by users on the platform are saved on Interplanatary File System (IPFS) and the image hash is stored on the Smart contract.

The Code base for frontend development of `ChainSphere` can be found in `/frontend` repository.

## Smart Contracts
The `ChainSphere` Decentralized Social Media Application is coordinated by four Contracts (i.e. `ChainSphere.sol`, `ChainSphereUserProfile.sol`, `ChainSpherePosts` and `ChainSphereComments.sol`) and one library (`PriceConverter.sol`) all written in `Solidity` and deployed on the `Polygon Amoy` test net.

The frontend interacts directly with the `ChainSphere.sol` contract which in turn delegates all user registration activities to the `ChainSphereUserProfile.sol` contract, all posts related activities to the `ChainSpherePosts` contract and all comments related activities to the `ChainSphereComments.sol` contract. Also, the Code base uses the `PriceConverter` library to get prices from Chainlink oracles using the Chainlink Price Feed Services.

A more detailed explanation on the Smart Contract Code base is contained in the `README.md` file in the `/contracts` folder where the entire Smart Conract Code base lie.

### The Selection of Authors for Reward
As a way of promoting valuable content by users of the platform, `ChainSphere` has devised a means of rewarding users who create valuable content(s) on the platform that is practically infeasible to rig. The selection of authors with valuable contents for reward is carriedo out in the following steps:
1. Each time a post is created, its `postId` is added to an array of recent posts. Note that each post has a unique id and each post can be fetched using its id.
2. Using `Chainlink Automation`, at regular intervals, the `Chainlink oracles` check to see if 
       
       i. the Contract has a non-zero balance,
       ii. has at least one eligible post for reward and
       iii. enough time has passed
3. If all the three conditions above are met, the Smart Contract requests for `random numbers (random words)` from the `Chainlink oracles` using a `vrfCoordinator` because only a vrfCoordinator can request random numbers from Chainlink oracles. `If there are 20 or fewer eligible posts` on the platform in the given period, one random number is requested. Otherwise, no more than 10% of the number of eligible posts is requested as random numbers.
4. The `Chainlink oracles` then generate the random numbers using a `Verifiable Random Function (VRF)` and send to the Smart Contract.
5. The Smart Contract uses the `modulo` operator to convert the random number(s) received from Chainlink to a number(s) that lie within the range of the indices of eligible posts on the platform in that period. For instance, if there are `10 eligible posts`, the `random number` from `Chainlink VRF` is converted to a number between `0` and `9`.
6. If the converted number(s) correspond(s) to the index or indices of a `postId` or `postIds`, those posts are selected as winning posts and 20% of the Contract balance is shared equally to the winners through their wallet addresses.
7. A user can only get multiple rewards in a period if some or all of their multiple valuable posts qualify as eligible posts and more than one happen to be picked at random.
8. A single post cannot be selected more than once either in a period or across periods.
9. Suppose a user rallies thier friends arround to cast upvotes on their post(s) in order to get reward, there are still chances they won't be picked by the algorithm even if they have majority of posts in the array of eligible posts. This principle will discourage unnecessary campaigns among acquintances since there is no guarantee of getting reward through this process as winners are picked at random.

## Deployment
The `ChainSphere` Smart Contract is deployed on `Polygon Amoy` test net. We initially wanted to deploy the Contract on `Polygon zkm Cardona` test net but discovered that Chainlink doesn't provide any services for the network and also confirmed this from `Chainlink Labs`. `Chainlink Labs` suggested it was ok to deploy our Contract on the `Polygon Amoy` test net though it is not a DeFi project since Chainlink provides services for it. Hence our reason for deploying on `Polygon Amoy`

## License
This project is licensed under the MIT License