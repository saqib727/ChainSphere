import { useEffect, useRef, useState } from "react";
import Image1 from "../assets/Rectangle 41.png";
import Image2 from "../assets/Rectangle 640.png";
import Menu from "@mui/material/Menu";
import MenuItem from "@mui/material/MenuItem";
import { Box } from "@mui/material";
import PostCard from "../components/PostCard";
import Sidebar from "../components/Sidebar";
import { useParams } from "react-router-dom";
import Links from "../components/Links";
import { contractABI, contractAddress } from "../contractDetails";
import Web3 from 'web3';
import { ethers } from "ethers";
import {useSelector } from "react-redux";

export default function Post() {
  const auth = useSelector((state) => state.auth);

  const [tab, setTab] = useState("home");
  const [web3, setWeb3] = useState(null);
  const [account, setAccount] = useState('');
  const [contract, setContract] = useState(null);
  const [post, setPost] = useState(null);
  const [comments, setComments] = useState(null);

  const pathname = useParams();

  

  
  const getPost = async (contract, account) => {
    console.log('i dey here mehn');
    try {
      const post = await contract.methods.getPostById(Number(pathname?.id)).call();
      const postComments = await contract.methods.getCommentsByPostId(Number(pathname?.id)).call();
      console.log('single post', post);
      console.log('postComments', postComments);
      setPost(post);
      setComments(postComments.reverse())
    } catch (error) {
      console.error('Error fetching posts:', error);
      alert(`Failed to fetch post ${error?.message || error?.toString()}`);

    }
  };

  const getUsersPosts = async () => {
    if (window.ethereum) {
      const web3Instance = new Web3(window.ethereum);
      window.ethereum.enable().then(accounts => {
        setWeb3(web3Instance);
        setAccount(accounts[0]);
        const myContract = new web3Instance.eth.Contract(contractABI, contractAddress);
        setContract(myContract);
        getPost(myContract, accounts[0]);
      }).catch(error => {
        console.error("User denied account access");
      });
    } else {
      alert('MetaMask not detected. Please install MetaMask to use this feature.');
    }
  }


  useEffect(() => {
    getUsersPosts();
  }, [pathname])

 
  return (
    // THings to add
    <div className="feed">
      <main className="feed__main">
      <Sidebar />
        <div className="feed__main__timeline">
          <div className="feed__main__timeline__cards">
            <PostCard post={post} comments={comments} reloadPost={getUsersPosts}/>
          </div>
        </div>
        <Links />
       
      </main>
    </div>
  );
}
