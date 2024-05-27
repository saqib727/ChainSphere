import { ethers } from "ethers";
import chainspere from "../ABI/chainspere.json";
import { NETWORKS } from "./config.ts";

// dotenv.config();

// const { PRIVATE_KEY, POLYGON_AMOY } = process.env;
const chainID: number = 80002;

const network = NETWORKS[chainID];

async function getContract(): Promise<{ socialMediaInstance: ethers.Contract }> {
  // if (!PRIVATE_KEY) {
  //   throw new Error("DEPLOYER_PRIVATE_KEY is undefined");
  // }
  // Get signer
  // const deployer = new ethers.Wallet(PRIVATE_KEY);
  // const provider = new ethers.providers.JsonRpcProvider(POLYGON_AMOY);
  // const signer = deployer.connect(provider);

  // Get contract instances
  const socialMediaInstance = new ethers.Contract(
    network.SOCIAL_MEDIA,
    [
      {
        "inputs": [
          { "internalType": "address", "name": "priceFeed", "type": "address" },
          { "internalType": "uint256", "name": "interval", "type": "uint256" },
          {
            "internalType": "address",
            "name": "vrfCoordinator",
            "type": "address"
          },
          { "internalType": "bytes32", "name": "gasLane", "type": "bytes32" },
          { "internalType": "uint64", "name": "subscriptionId", "type": "uint64" },
          {
            "internalType": "uint32",
            "name": "callbackGasLimit",
            "type": "uint32"
          },
          { "internalType": "address", "name": "link", "type": "address" },
          { "internalType": "uint256", "name": "deployerKey", "type": "uint256" }
        ],
        "stateMutability": "nonpayable",
        "type": "constructor"
      },
      {
        "inputs": [
          { "internalType": "address", "name": "have", "type": "address" },
          { "internalType": "address", "name": "want", "type": "address" }
        ],
        "name": "OnlyCoordinatorCanFulfill",
        "type": "error"
      },
      { "inputs": [], "name": "SocialMedia__AlreadyVoted", "type": "error" },
      {
        "inputs": [
          { "internalType": "address", "name": "winner", "type": "address" }
        ],
        "name": "SocialMedia__BatchTransferFailed",
        "type": "error"
      },
      { "inputs": [], "name": "SocialMedia__NotCommentOwner", "type": "error" },
      { "inputs": [], "name": "SocialMedia__NotOwner", "type": "error" },
      { "inputs": [], "name": "SocialMedia__NotPostOwner", "type": "error" },
      { "inputs": [], "name": "SocialMedia__OwnerCannotVote", "type": "error" },
      { "inputs": [], "name": "SocialMedia__PaymentNotEnough", "type": "error" },
      { "inputs": [], "name": "SocialMedia__TransferFailed", "type": "error" },
      {
        "inputs": [
          { "internalType": "uint256", "name": "balance", "type": "uint256" },
          {
            "internalType": "uint256",
            "name": "numOfEligibleAuthors",
            "type": "uint256"
          }
        ],
        "name": "SocialMedia__UpkeepNotNeeded",
        "type": "error"
      },
      { "inputs": [], "name": "SocialMedia__UserDoesNotExist", "type": "error" },
      {
        "inputs": [],
        "name": "SocialMedia__UsernameAlreadyTaken",
        "type": "error"
      },
      {
        "anonymous": false,
        "inputs": [
          {
            "indexed": true,
            "internalType": "uint256",
            "name": "commentId",
            "type": "uint256"
          },
          {
            "indexed": false,
            "internalType": "string",
            "name": "postAuthor",
            "type": "string"
          },
          {
            "indexed": false,
            "internalType": "string",
            "name": "commentAuthor",
            "type": "string"
          },
          {
            "indexed": false,
            "internalType": "uint256",
            "name": "postId",
            "type": "uint256"
          }
        ],
        "name": "CommentCreated",
        "type": "event"
      },
      {
        "anonymous": false,
        "inputs": [
          {
            "indexed": false,
            "internalType": "uint256",
            "name": "postId",
            "type": "uint256"
          },
          {
            "indexed": false,
            "internalType": "string",
            "name": "posthAuthorName",
            "type": "string"
          },
          {
            "indexed": false,
            "internalType": "string",
            "name": "downvoterName",
            "type": "string"
          }
        ],
        "name": "Downvoted",
        "type": "event"
      },
      {
        "anonymous": false,
        "inputs": [
          {
            "indexed": false,
            "internalType": "address",
            "name": "winner",
            "type": "address"
          }
        ],
        "name": "PickedWinner",
        "type": "event"
      },
      {
        "anonymous": false,
        "inputs": [
          {
            "indexed": false,
            "internalType": "uint256",
            "name": "postId",
            "type": "uint256"
          },
          {
            "indexed": false,
            "internalType": "string",
            "name": "authorName",
            "type": "string"
          }
        ],
        "name": "PostCreated",
        "type": "event"
      },
      {
        "anonymous": false,
        "inputs": [
          {
            "indexed": false,
            "internalType": "uint256",
            "name": "postId",
            "type": "uint256"
          },
          {
            "indexed": false,
            "internalType": "string",
            "name": "authorName",
            "type": "string"
          }
        ],
        "name": "PostEdited",
        "type": "event"
      },
      {
        "anonymous": false,
        "inputs": [
          {
            "indexed": true,
            "internalType": "uint256",
            "name": "postId",
            "type": "uint256"
          },
          {
            "indexed": true,
            "internalType": "address",
            "name": "postAuthor",
            "type": "address"
          },
          {
            "indexed": true,
            "internalType": "address",
            "name": "liker",
            "type": "address"
          }
        ],
        "name": "PostLiked",
        "type": "event"
      },
      {
        "anonymous": false,
        "inputs": [
          {
            "indexed": false,
            "internalType": "uint256",
            "name": "requestId",
            "type": "uint256"
          }
        ],
        "name": "RequestWinningAuthor",
        "type": "event"
      },
      {
        "anonymous": false,
        "inputs": [
          {
            "indexed": true,
            "internalType": "address",
            "name": "user",
            "type": "address"
          },
          {
            "indexed": false,
            "internalType": "uint256",
            "name": "amount",
            "type": "uint256"
          }
        ],
        "name": "RewardSent",
        "type": "event"
      },
      {
        "anonymous": false,
        "inputs": [
          {
            "indexed": false,
            "internalType": "uint256",
            "name": "postId",
            "type": "uint256"
          },
          {
            "indexed": false,
            "internalType": "string",
            "name": "posthAuthorName",
            "type": "string"
          },
          {
            "indexed": false,
            "internalType": "string",
            "name": "upvoterName",
            "type": "string"
          }
        ],
        "name": "Upvoted",
        "type": "event"
      },
      {
        "anonymous": false,
        "inputs": [
          {
            "indexed": true,
            "internalType": "uint256",
            "name": "id",
            "type": "uint256"
          },
          {
            "indexed": true,
            "internalType": "address",
            "name": "userAddress",
            "type": "address"
          },
          {
            "indexed": true,
            "internalType": "string",
            "name": "name",
            "type": "string"
          }
        ],
        "name": "UserRegistered",
        "type": "event"
      },
      {
        "inputs": [{ "internalType": "bytes", "name": "", "type": "bytes" }],
        "name": "CheckUpkeep",
        "outputs": [
          { "internalType": "bool", "name": "upkeepNeeded", "type": "bool" },
          { "internalType": "bytes", "name": "", "type": "bytes" }
        ],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [
          { "internalType": "address", "name": "_newOwner", "type": "address" }
        ],
        "name": "changeOwner",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [
          { "internalType": "string", "name": "_newName", "type": "string" }
        ],
        "name": "changeUsername",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [
          { "internalType": "uint256", "name": "_postId", "type": "uint256" },
          { "internalType": "string", "name": "_content", "type": "string" }
        ],
        "name": "createComment",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [
          { "internalType": "string", "name": "_content", "type": "string" },
          { "internalType": "string", "name": "_imgHash", "type": "string" }
        ],
        "name": "createPost",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [
          { "internalType": "uint256", "name": "_postId", "type": "uint256" },
          { "internalType": "uint256", "name": "_commentId", "type": "uint256" }
        ],
        "name": "deleteComment",
        "outputs": [],
        "stateMutability": "payable",
        "type": "function"
      },
      {
        "inputs": [
          { "internalType": "uint256", "name": "_postId", "type": "uint256" }
        ],
        "name": "deletePost",
        "outputs": [],
        "stateMutability": "payable",
        "type": "function"
      },
      {
        "inputs": [
          { "internalType": "uint256", "name": "_postId", "type": "uint256" }
        ],
        "name": "downvote",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [
          { "internalType": "uint256", "name": "_postId", "type": "uint256" },
          { "internalType": "uint256", "name": "_commentId", "type": "uint256" },
          { "internalType": "string", "name": "_content", "type": "string" }
        ],
        "name": "editComment",
        "outputs": [],
        "stateMutability": "payable",
        "type": "function"
      },
      {
        "inputs": [
          { "internalType": "uint256", "name": "_postId", "type": "uint256" },
          { "internalType": "string", "name": "_content", "type": "string" },
          { "internalType": "string", "name": "_imgHash", "type": "string" }
        ],
        "name": "editPost",
        "outputs": [],
        "stateMutability": "payable",
        "type": "function"
      },
      {
        "inputs": [],
        "name": "getBalance",
        "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [
          { "internalType": "uint256", "name": "_postId", "type": "uint256" },
          { "internalType": "uint256", "name": "_commentId", "type": "uint256" }
        ],
        "name": "getCommentByPostIdAndCommentId",
        "outputs": [
          {
            "components": [
              { "internalType": "uint256", "name": "commentId", "type": "uint256" },
              { "internalType": "address", "name": "author", "type": "address" },
              { "internalType": "uint256", "name": "postId", "type": "uint256" },
              { "internalType": "string", "name": "content", "type": "string" },
              { "internalType": "uint256", "name": "timestamp", "type": "uint256" },
              { "internalType": "uint256", "name": "likesCount", "type": "uint256" }
            ],
            "internalType": "struct SocialMedia.Comment",
            "name": "",
            "type": "tuple"
          }
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [
          { "internalType": "uint256", "name": "_postId", "type": "uint256" },
          { "internalType": "uint256", "name": "_commentId", "type": "uint256" }
        ],
        "name": "getCommentLikersByPostIdAndCommentId",
        "outputs": [
          { "internalType": "address[]", "name": "", "type": "address[]" }
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [],
        "name": "getContractOwner",
        "outputs": [{ "internalType": "address", "name": "", "type": "address" }],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [],
        "name": "getIdsOfEligiblePosts",
        "outputs": [
          { "internalType": "uint256[]", "name": "", "type": "uint256[]" }
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [],
        "name": "getIdsOfRecentPosts",
        "outputs": [
          { "internalType": "uint256[]", "name": "", "type": "uint256[]" }
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [
          { "internalType": "uint256", "name": "_postId", "type": "uint256" }
        ],
        "name": "getPostById",
        "outputs": [
          {
            "components": [
              { "internalType": "uint256", "name": "postId", "type": "uint256" },
              { "internalType": "string", "name": "content", "type": "string" },
              { "internalType": "string", "name": "imgHash", "type": "string" },
              { "internalType": "uint256", "name": "timestamp", "type": "uint256" },
              { "internalType": "uint256", "name": "upvotes", "type": "uint256" },
              { "internalType": "uint256", "name": "downvotes", "type": "uint256" },
              { "internalType": "address", "name": "author", "type": "address" }
            ],
            "internalType": "struct SocialMedia.Post",
            "name": "",
            "type": "tuple"
          }
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [],
        "name": "getRecentWinners",
        "outputs": [
          { "internalType": "uint256[]", "name": "", "type": "uint256[]" }
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [
          { "internalType": "uint256", "name": "_ethAmount", "type": "uint256" }
        ],
        "name": "getUsdValueOfEthAmount",
        "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [
          { "internalType": "address", "name": "_userAddress", "type": "address" }
        ],
        "name": "getUser",
        "outputs": [
          {
            "components": [
              { "internalType": "uint256", "name": "id", "type": "uint256" },
              {
                "internalType": "address",
                "name": "userAddress",
                "type": "address"
              },
              { "internalType": "string", "name": "name", "type": "string" },
              { "internalType": "string", "name": "bio", "type": "string" },
              {
                "internalType": "string",
                "name": "profileImageHash",
                "type": "string"
              }
            ],
            "internalType": "struct SocialMedia.User",
            "name": "",
            "type": "tuple"
          }
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [
          { "internalType": "uint256", "name": "_userId", "type": "uint256" }
        ],
        "name": "getUserById",
        "outputs": [
          {
            "components": [
              { "internalType": "uint256", "name": "id", "type": "uint256" },
              {
                "internalType": "address",
                "name": "userAddress",
                "type": "address"
              },
              { "internalType": "string", "name": "name", "type": "string" },
              { "internalType": "string", "name": "bio", "type": "string" },
              {
                "internalType": "string",
                "name": "profileImageHash",
                "type": "string"
              }
            ],
            "internalType": "struct SocialMedia.User",
            "name": "",
            "type": "tuple"
          }
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [
          { "internalType": "address", "name": "_userAddress", "type": "address" }
        ],
        "name": "getUserComments",
        "outputs": [
          {
            "components": [
              { "internalType": "uint256", "name": "commentId", "type": "uint256" },
              { "internalType": "address", "name": "author", "type": "address" },
              { "internalType": "uint256", "name": "postId", "type": "uint256" },
              { "internalType": "string", "name": "content", "type": "string" },
              { "internalType": "uint256", "name": "timestamp", "type": "uint256" },
              { "internalType": "uint256", "name": "likesCount", "type": "uint256" }
            ],
            "internalType": "struct SocialMedia.Comment[]",
            "name": "",
            "type": "tuple[]"
          }
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [
          { "internalType": "address", "name": "_userAddress", "type": "address" }
        ],
        "name": "getUserNameFromAddress",
        "outputs": [
          { "internalType": "string", "name": "nameOfUser", "type": "string" }
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [
          { "internalType": "address", "name": "_userAddress", "type": "address" }
        ],
        "name": "getUserPosts",
        "outputs": [
          {
            "components": [
              { "internalType": "uint256", "name": "postId", "type": "uint256" },
              { "internalType": "string", "name": "content", "type": "string" },
              { "internalType": "string", "name": "imgHash", "type": "string" },
              { "internalType": "uint256", "name": "timestamp", "type": "uint256" },
              { "internalType": "uint256", "name": "upvotes", "type": "uint256" },
              { "internalType": "uint256", "name": "downvotes", "type": "uint256" },
              { "internalType": "address", "name": "author", "type": "address" }
            ],
            "internalType": "struct SocialMedia.Post[]",
            "name": "",
            "type": "tuple[]"
          }
        ],
        "stateMutability": "view",
        "type": "function"
      },
      {
        "inputs": [
          { "internalType": "uint256", "name": "_postId", "type": "uint256" },
          { "internalType": "uint256", "name": "_commentId", "type": "uint256" }
        ],
        "name": "likeComment",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [{ "internalType": "bytes", "name": "", "type": "bytes" }],
        "name": "performUpkeep",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [
          { "internalType": "uint256", "name": "requestId", "type": "uint256" },
          {
            "internalType": "uint256[]",
            "name": "randomWords",
            "type": "uint256[]"
          }
        ],
        "name": "rawFulfillRandomWords",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [
          { "internalType": "string", "name": "_name", "type": "string" },
          { "internalType": "string", "name": "_bio", "type": "string" },
          {
            "internalType": "string",
            "name": "_profileImageHash",
            "type": "string"
          }
        ],
        "name": "registerUser",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [
          { "internalType": "address payable", "name": "_to", "type": "address" }
        ],
        "name": "transferContractBalance",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      {
        "inputs": [
          { "internalType": "uint256", "name": "_postId", "type": "uint256" }
        ],
        "name": "upvote",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      },
      { "stateMutability": "payable", "type": "receive" }
    ]
    ,
    // signer
  );
  
  return {
    // signer,
    socialMediaInstance,
  };
}

export { getContract };
