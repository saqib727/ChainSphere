import { ethers } from "ethers";
import { getContract } from "../Utils/getContract.ts";

// Function to register a new user
async function registerUser(name: string, bio: string, profileImageHash: string, address: string): Promise<ethers.ContractTransaction> {
    const { socialMediaInstance } = await getContract();

    const tx = await socialMediaInstance.registerUser(name, bio, profileImageHash).send({from: address})
        

    // Return the transaction object
    return tx;
}



// Function to create a new post
async function createPost(content: string, imgHash: string): Promise<ethers.ContractTransaction> {
    const { signer, socialMediaInstance } = await getContract();

    // Call the createPost function of the contract with provided parameters
    const tx = await socialMediaInstance
        .connect(signer)
        .createPost(content, imgHash);

    // Return the transaction object
    return tx;
}

// Function to upvote a post
async function upvotePost(postID: number): Promise<ethers.ContractTransaction> {
    const { signer, socialMediaInstance } = await getContract();

    // Check if the user has already upvoted the post
    const hasUpvoted = await socialMediaInstance.hasUpvoted(signer.address, postID);
    if (hasUpvoted) {
        throw new Error("You have already upvoted this post");
    }

    // Call the upvote function of the contract with provided parameters
    const tx = await socialMediaInstance
        .connect(signer)
        .upvote(postID);

    // Return the transaction object
    return tx;
}

// Function to create a comment on a post
async function createComment(postId: number, content: string): Promise<ethers.ContractTransaction> {
    const { signer, socialMediaInstance } = await getContract();

    // Call the createComment function of the contract with provided parameters
    const tx = await socialMediaInstance
        .connect(signer)
        .createComment(postId, content);

    // Return the transaction object
    return tx;
}

// Function to delete a post
async function deletePost(postId: number): Promise<ethers.ContractTransaction> {
    const { signer, socialMediaInstance } = await getContract();

    // Check if the user is the original creator of the post
    const originalCreator = await socialMediaInstance.getPostCreator(postId);
    if (originalCreator !== signer.address) {
        throw new Error("You are not authorized to delete this post");
    }

    // Call the deletePost function of the contract with provided parameters
    const tx = await socialMediaInstance
        .connect(signer)
        .deletePost(postId);

    // Return the transaction object
    return tx;
}

// Function to delete a comment
async function deleteComment(postId: number, commentId: number): Promise<ethers.ContractTransaction> {
    const { signer, socialMediaInstance } = await getContract();

    // Check if the user is the original creator of the comment
    const originalCreator = await socialMediaInstance.getCommentCreator(postId, commentId);
    if (originalCreator !== signer.address) {
        throw new Error("You are not authorized to delete this comment");
    }

    // Call the deleteComment function of the contract with provided parameters
    const tx = await socialMediaInstance
        .connect(signer)
        .deleteComment(postId, commentId);

    // Return the transaction object
    return tx;
}

// Function to edit a post
async function editPost(postId: number, content: string, imgHash: string): Promise<ethers.ContractTransaction> {
    const { signer, socialMediaInstance } = await getContract();

    // Check if the user is the original creator of the post
    const originalCreator = await socialMediaInstance.getPostCreator(postId);
    if (originalCreator !== signer.address) {
        throw new Error("You are not authorized to edit this post");
    }

    // Call the editPost function of the contract with provided parameters
    const tx = await socialMediaInstance
        .connect(signer)
        .editPost(postId, content, imgHash);

    // Return the transaction object
    return tx;
}

// Function to edit a comment
async function editComment(postId: number, commentId: number, content: string): Promise<ethers.ContractTransaction> {
    const { signer, socialMediaInstance } = await getContract();

    // Check if the user is the original creator of the comment
    const originalCreator = await socialMediaInstance.getCommentCreator(postId, commentId);
    if (originalCreator !== signer.address) {
        throw new Error("You are not authorized to edit this comment");
    }

    // Call the editComment function of the contract with provided parameters
    const tx = await socialMediaInstance
        .connect(signer)
        .editComment(postId, commentId, content);

    // Return the transaction object
    return tx;
}

// Function to downvote a post
async function downvote(postId: number): Promise<ethers.ContractTransaction> {
    const { signer, socialMediaInstance } = await getContract();

    // Check if the user has already downvoted the post
    const hasDownvoted = await socialMediaInstance.hasDownvoted(signer.address, postId);
    if (hasDownvoted) {
        throw new Error("You have already downvoted this post");
    }

    // Call the downvote function of the contract with provided parameters
    const tx = await socialMediaInstance
        .connect(signer)
        .downvote(postId);

    // Return the transaction object
    return tx;
}

// Function to like a comment
async function likeComment(postId: number, commentId: number): Promise<ethers.ContractTransaction> {
    const { signer, socialMediaInstance } = await getContract();

    // Check if the user has already liked the comment
    const hasLiked = await socialMediaInstance.hasLiked(signer.address, postId, commentId);
    if (hasLiked) {
        throw new Error("You have already liked this comment");
    }

    // Call the likeComment function of the contract with provided parameters
    const tx = await socialMediaInstance
        .connect(signer)
        .likeComment(postId, commentId);

    // Return the transaction object
    return tx;
}

// Function to transfer the contract balance to another address
async function transferContractBalance(to: string): Promise<ethers.ContractTransaction> {
    const { signer, socialMediaInstance } = await getContract();

    // Check if the signer has the authority to transfer the contract balance
    const hasAuthority = await socialMediaInstance.hasAuthority(signer.address);
    if (!hasAuthority) {
        throw new Error("You don't have the authority to transfer the contract balance");
    }

    // Call the transferContractBalance function of the contract with provided parameters
    const tx = await socialMediaInstance
        .connect(signer)
        .transferContractBalance(to);

    // Return the transaction object
    return tx;
}

// Function to get the list of posts by a user
async function getUserPosts(userId: number): Promise<any> {
    const { signer, socialMediaInstance } = await getContract();

    // Call the getUserPosts function of the contract with provided parameters
    const userPosts = await socialMediaInstance.getUserPosts(userId);

    // Return the list of posts by the user
    return userPosts;
}

// Function to get the list of upvotes for a post
async function getUpvotes(postId: number): Promise<any> {
    const { signer, socialMediaInstance } = await getContract();

    // Call the getUpvotes function of the contract with provided parameters
    const upvotes = await socialMediaInstance.getUpvotes(postId);

    // Return the list of upvotes for the post
    return upvotes;
}

// Function to get the list of downvotes for a post
async function getDownvotes(postId: number): Promise<any> {
    const { signer, socialMediaInstance } = await getContract();

    // Call the getDownvotes function of the contract with provided parameters
    const downvotes = await socialMediaInstance.getDownvotes(postId);

    // Return the list of downvotes for the post
    return downvotes;
}

// Function to get the list of likes for a comment
async function getLikes(postId: number, commentId: number): Promise<any> {
    const { signer, socialMediaInstance } = await getContract();

    // Call the getLikes function of the contract with provided parameters
    const likes = await socialMediaInstance.getLikes(postId, commentId);

    // Return the list of likes for the comment
    return likes;
}

// Function to follow a user
async function followUser(userId: number): Promise<ethers.ContractTransaction> {
    const { signer, socialMediaInstance } = await getContract();

    // Check if the user is trying to follow themselves
    if (userId === signer.address) {
        throw new Error("You cannot follow yourself");
    }

    // Call the followUser function of the contract with provided parameters
    const tx = await socialMediaInstance
        .connect(signer)
        .followUser(userId);

    // Return the transaction object
    return tx;
}

// Function to unfollow a user
async function unfollowUser(userId: number): Promise<ethers.ContractTransaction> {
    const { signer, socialMediaInstance } = await getContract();

    // Call the unfollowUser function of the contract with provided parameters
    const tx = await socialMediaInstance
        .connect(signer)
        .unfollowUser(userId);

    // Return the transaction object
    return tx;
}

export {
    registerUser,
    createPost,
    upvotePost,
    createComment,
    deletePost,
    deleteComment,
    editPost,
    editComment,
    downvote,
    likeComment,
    transferContractBalance,
    getUserPosts,
    getUpvotes,
    getDownvotes,
    getLikes,
    followUser,
    unfollowUser,
};
