import { ethers } from "ethers";
// import axios from "axios";
// import dotenv from "dotenv";
// import pinataSDK from "@pinata/sdk";
// import fs from "fs";
import { getContract } from "../Utils/getContract";
// import { formatUnits, parseEther } from "ethers/lib/utils";
// import pinJSONToIPFS from "@pinata/sdk/types/commands/pinning/pinJSONToIPFS";

  async function registerUser(
        name: string,
        bio: string,
        profileImageHash: string
    ) {
        const { signer, socialMediaInstance } = await getContract();
    
        const tx = await socialMediaInstance
        .connect(signer)
        .registerUser(name, bio, profileImageHash);
        return {
        tx,
        };
  }

  async function createPost(
    content: string,
    imgHash: string,
) {
    const { signer, socialMediaInstance } = await getContract();

    const tx = await socialMediaInstance
    .connect(signer)
    .createPost(content, imgHash);
    return {
    tx,
    };
}

async function upvotePost(
    postID: number,
) {
    const { signer, socialMediaInstance } = await getContract();

    const tx = await socialMediaInstance
    .connect(signer)
    .upvotePost(postID);
    return {
    tx,
    };
}

async function createComment(
    postId: number, content: string
) {
    const { signer, socialMediaInstance } = await getContract();

    const tx = await socialMediaInstance
    .connect(signer)
    .createComment(postId, content);
    return {
    tx,
    };
}

async function getUserPosts(
    userAddress: string
) {
    const { signer, socialMediaInstance } = await getContract();

    const tx = await socialMediaInstance
    .connect(signer)
    .getUserPosts(userAddress);
    return {
    tx,
    };
}

async function getPostDetails(
    postId: number
) {
    const { signer, socialMediaInstance } = await getContract();

    const tx = await socialMediaInstance
    .connect(signer)
    .getPostDetails(postId);
    return {
    tx,
    };
}

async function getUserDetails(
    userAddress: string
) {
    const { signer, socialMediaInstance } = await getContract();

    const tx = await socialMediaInstance
    .connect(signer)
    .getUserDetails(userAddress);
    return {
    tx,
    };
}

export {
    registerUser,
    createPost,
    upvotePost,
    createComment,
    getUserPosts,
    getPostDetails,
    getUserDetails,
}








