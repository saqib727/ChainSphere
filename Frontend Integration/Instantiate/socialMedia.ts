import { ethers } from "ethers";
import { getContract } from "../Utils/getContract";

// Function to register a new user
async function registerUser(name: string, bio: string, profileImageHash: string): Promise<ethers.ContractTransaction> {
    const { signer, socialMediaInstance } = await getContract();

    // Call the registerUser function of the contract with provided parameters
    const tx = await socialMediaInstance
        .connect(signer)
        .registerUser(name, bio, profileImageHash);
    
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
