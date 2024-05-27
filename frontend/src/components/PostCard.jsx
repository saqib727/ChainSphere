import { useEffect, useState } from "react";
import Image1 from "../assets/Rectangle 41.png";
import Image2 from "../assets/Rectangle 640.png";
import Menu from "@mui/material/Menu";
import MenuItem from "@mui/material/MenuItem";
import { Box } from "@mui/material";
import {useNavigate, useLocation} from 'react-router-dom';
import { contractABI, contractAddress } from '../contractDetails';
import Web3 from "web3";
import { ethers } from "ethers";
import { useDispatch, useSelector } from "react-redux";




export default function PostCard({post}) {
  const auth = useSelector((state) => state.auth);

  const [imageModal, setImageModal] = useState(false);
  const [anchorEl, setAnchorEl] = useState(null);
  const navigate = useNavigate();
  const [account, setAccount] = useState('');
    const [contract, setContract] = useState(null);
    const [web3, setWeb3] = useState(null);

  const open = Boolean(anchorEl);
  const { pathname } = useLocation();

  const handleClose = () => {
    setAnchorEl(null);
  };
  const handleClick = (event) => {
    setAnchorEl(event.currentTarget);
  };


  useEffect
  (() => {
    if (window.ethereum) {
      const web3Instance = new Web3(window.ethereum);
      window.ethereum.enable().then(accounts => {
        setWeb3(web3Instance);
        setAccount(accounts[0]);
        const myContract = new web3Instance.eth.Contract(contractABI, contractAddress);
        setContract(myContract);
      }).catch(error => {
        console.error("User denied account access");
      });
    } else {
      alert('MetaMask not detected. Please install MetaMask to use this feature.');
    }
  }, []);

  const handleUpVote = async (e) => {
    e.preventDefault();
    // setLoading(true)
    if (!contract) {
      alert('Contract not loaded');
      return;
    }
    if (post?.author === auth?.userInfo?.address) {
      alert("You can't vote on your own post");
      return;
    }

    try {
      const postIdInt = Number(post?.postId);

      await contract.methods.upvote(postIdInt).send({ from: account });
      alert("Success")
      // setModalOpen(false)
    } catch (error) {
      console.error('Error creating post:', error);
      alert('Failed to create post');
    }
    // setLoading(false)

  };

  const handleDownVote = async (e) => {
    e.preventDefault();
    // setLoading(true)
    if (!contract) {
      alert('Contract not loaded');
      return;
    }
    if (post?.author === auth?.userInfo?.address) {
      alert("You can't vote on your own post");
      return;
    }

    try {
      const postIdInt = Number(post?.postId);

      await contract.methods.downvote(postIdInt).send({ from: account });
      alert("Success")
      // setModalOpen(false)
    } catch (error) {
      console.error('Error creating post:', error);
      alert('Failed to create post');
    }
    // setLoading(false)

  };

  // console.log('posty', post?.postId?.toString());
  

  return (
    <div>
      <div className="post-card"
      // onClick={() => navigate("/post/99")}
      >
        <img className="post-card__img" src={Image1} alt="" />
        <div className="post-card__content">
          <div className="post-card__content__title">
            <div>
              <div>Saleem Jibril</div>
              <div>@saleem · 1h</div>
            </div>

            <svg
              viewBox="0 0 24 24"
              fill="none"
              xmlns="http://www.w3.org/2000/svg"
              onClick={handleClick}
              className="pointer"
            >
              <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
              <g
                id="SVGRepo_tracerCarrier"
                stroke-linecap="round"
                stroke-linejoin="round"
              ></g>
              <g id="SVGRepo_iconCarrier">
                {" "}
                <path
                  d="M5 10C6.10457 10 7 10.8954 7 12C7 13.1046 6.10457 14 5 14C3.89543 14 3 13.1046 3 12C3 10.8954 3.89543 10 5 10Z"
                  fill="#FFF"
                ></path>{" "}
                <path
                  d="M12 10C13.1046 10 14 10.8954 14 12C14 13.1046 13.1046 14 12 14C10.8954 14 10 13.1046 10 12C10 10.8954 10.8954 10 12 10Z"
                  fill="#FFF"
                ></path>{" "}
                <path
                  d="M21 12C21 10.8954 20.1046 10 19 10C17.8954 10 17 10.8954 17 12C17 13.1046 17.8954 14 19 14C20.1046 14 21 13.1046 21 12Z"
                  fill="#FFF"
                ></path>{" "}
              </g>
            </svg>

            <Menu
              id="basic-menu"
              anchorEl={anchorEl}
              open={open}
              onClose={handleClose}
              //   MenuListProps={{
              //     "aria-labelledby": "basic-button",
              //   }}
            >
              <MenuItem
                sx={{
                  width: "150px",
                  fontSize: "14px",
                  fontFamily: "Inter",
                  fontWeight: "500",
                  "&:hover": {
                    backgroundColor: "#302c3057",
                  },
                }}
                className="subMenu"
              >
                Edit post
              </MenuItem>
              <MenuItem
                sx={{
                  width: "150px",
                  fontSize: "14px",
                  fontFamily: "Inter",
                  fontWeight: "500",
                  "&:hover": {
                    backgroundColor: "#302c3057",
                  },
                }}
                className="subMenu"
              >
                Option
              </MenuItem>
              <MenuItem
                sx={{
                  width: "150px",
                  fontSize: "14px",
                  fontFamily: "Inter",
                  fontWeight: "500",
                  "&:hover": {
                    backgroundColor: "#302c3057",
                  },
                }}
                className="subMenu"
              >
                Option
              </MenuItem>
            </Menu>
          </div>
          <div className="post-card__content__post">
            {post?.content}
            <img
              className="post-card__content__post__img pointer"
              src={Image2}
              alt=""
              onClick={() => setImageModal(true)}
            />
          </div>
          <div className="post-card__content__actions">
            <div className="post-card__content__actions__comment">
              <svg
                viewBox="0 0 32 32"
                version="1.1"
                xmlns="http://www.w3.org/2000/svg"
                xmlnsXlink="http://www.w3.org/1999/xlink"
                xmlnsSketch="http://www.bohemiancoding.com/sketch/ns"
                fill="#000000"
              >
                <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
                <g
                  id="SVGRepo_tracerCarrier"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                ></g>
                <g id="SVGRepo_iconCarrier">
                  {" "}
                  <title>comment-1</title>{" "}
                  <desc>Created with Sketch Beta.</desc> <defs> </defs>{" "}
                  <g
                    id="Page-1"
                    stroke="none"
                    stroke-width="1"
                    fill="none"
                    fill-rule="evenodd"
                    sketchType="MSPage"
                  >
                    {" "}
                    <g
                      id="Icon-Set"
                      sketchType="MSLayerGroup"
                      transform="translate(-100.000000, -255.000000)"
                      fill="#FFF"
                    >
                      {" "}
                      <path
                        d="M116,281 C114.832,281 113.704,280.864 112.62,280.633 L107.912,283.463 L107.975,278.824 C104.366,276.654 102,273.066 102,269 C102,262.373 108.268,257 116,257 C123.732,257 130,262.373 130,269 C130,275.628 123.732,281 116,281 L116,281 Z M116,255 C107.164,255 100,261.269 100,269 C100,273.419 102.345,277.354 106,279.919 L106,287 L113.009,282.747 C113.979,282.907 114.977,283 116,283 C124.836,283 132,276.732 132,269 C132,261.269 124.836,255 116,255 L116,255 Z"
                        id="comment-1"
                        sketchType="MSShapeGroup"
                      >
                        {" "}
                      </path>{" "}
                    </g>{" "}
                  </g>{" "}
                </g>
              </svg>
              20
            </div>
            <div className="post-card__content__actions__like"
            onClick={handleUpVote}
            >
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M18.0701 10.3199C17.8801 10.3199 17.6901 10.2499 17.5401 10.0999L12.0001 4.55994L6.46012 10.0999C6.17012 10.3899 5.69012 10.3899 5.40012 10.0999C5.11012 9.80994 5.11012 9.32994 5.40012 9.03994L11.4701 2.96994C11.7601 2.67994 12.2401 2.67994 12.5301 2.96994L18.6001 9.03994C18.8901 9.32994 18.8901 9.80994 18.6001 10.0999C18.4601 10.2499 18.2601 10.3199 18.0701 10.3199Z" fill="#FFF"/>
<path d="M12 21.2499C11.59 21.2499 11.25 20.9099 11.25 20.4999V3.66992C11.25 3.25992 11.59 2.91992 12 2.91992C12.41 2.91992 12.75 3.25992 12.75 3.66992V20.4999C12.75 20.9099 12.41 21.2499 12 21.2499Z" fill="#FFF"/>
</svg>

              16
            </div>
            <div className="post-card__content__actions__like" onClick={handleDownVote}>
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M12.0001 21.2501C11.8101 21.2501 11.6201 21.1801 11.4701 21.0301L5.40012 14.9601C5.11012 14.6701 5.11012 14.1901 5.40012 13.9001C5.69012 13.6101 6.17012 13.6101 6.46012 13.9001L12.0001 19.4401L17.5401 13.9001C17.8301 13.6101 18.3101 13.6101 18.6001 13.9001C18.8901 14.1901 18.8901 14.6701 18.6001 14.9601L12.5301 21.0301C12.3801 21.1801 12.1901 21.2501 12.0001 21.2501Z" fill="#FFF"/>
<path d="M12 21.08C11.59 21.08 11.25 20.74 11.25 20.33V3.5C11.25 3.09 11.59 2.75 12 2.75C12.41 2.75 12.75 3.09 12.75 3.5V20.33C12.75 20.74 12.41 21.08 12 21.08Z" fill="#FFF"/>
</svg>


              16
            </div>
            <div className="post-card__content__actions__share">
              <svg
                viewBox="0 -0.5 25 25"
                fill="none"
                xmlns="http://www.w3.org/2000/svg"
              >
                <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
                <g
                  id="SVGRepo_tracerCarrier"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                ></g>
                <g id="SVGRepo_iconCarrier">
                  {" "}
                  <path
                    fill-rule="evenodd"
                    clip-rule="evenodd"
                    d="M14.734 15.8974L19.22 12.1374C19.3971 11.9927 19.4998 11.7761 19.4998 11.5474C19.4998 11.3187 19.3971 11.1022 19.22 10.9574L14.734 7.19743C14.4947 6.9929 14.1598 6.94275 13.8711 7.06826C13.5824 7.19377 13.3906 7.47295 13.377 7.78743V9.27043C7.079 8.17943 5.5 13.8154 5.5 16.9974C6.961 14.5734 10.747 10.1794 13.377 13.8154V15.3024C13.3888 15.6178 13.5799 15.8987 13.8689 16.0254C14.158 16.1521 14.494 16.1024 14.734 15.8974Z"
                    stroke="#FFF"
                    stroke-width="1"
                    stroke-linecap="round"
                    stroke-linejoin="round"
                  ></path>{" "}
                </g>
              </svg>
              24
            </div>
          </div>
{pathname.includes("post") && <form className="post-card__content__form">
  <img src={Image1} alt="" />
                <input type="text" placeholder="Write a comment" />
</form>}
          {pathname.includes("post") && <div className="post-card__content__comments">
            <div className="post-card__content__comments__card">
            <img className="post-card__content__comments__card__img" src={Image1} alt="" />
<div className="post-card__content__comments__card__content">

              <div className="post-card__content__comments__card__content__title">
                <div>
                  <div>Saleem Jibril</div>
                  <div>@saleem · 1h</div>
                </div>
              </div>

              <div className="post-card__content__comments__card__content__post">
              Comment from me
              </div>
</div>
            </div>
            <div className="post-card__content__comments__card">
            <img className="post-card__content__comments__card__img" src={Image1} alt="" />
<div className="post-card__content__comments__card__content">

              <div className="post-card__content__comments__card__content__title">
                <div>
                  <div>Saleem Jibril</div>
                  <div>@saleem · 1h</div>
                </div>
              </div>

              <div className="post-card__content__comments__card__content__post">
              Comment from me
              </div>
</div>
            </div>
            <div className="post-card__content__comments__card">
            <img className="post-card__content__comments__card__img" src={Image1} alt="" />
<div className="post-card__content__comments__card__content">

              <div className="post-card__content__comments__card__content__title">
                <div>
                  <div>Saleem Jibril</div>
                  <div>@saleem · 1h</div>
                </div>
              </div>

              <div className="post-card__content__comments__card__content__post">
              Comment from me
              </div>
</div>
            </div>
          </div>}
        </div>

        {imageModal && (
          <div className="post-card__modal">
            <svg
              onClick={() => setImageModal(false)}
              width="40"
              height="40"
              viewBox="0 0 24 24"
              fill="none"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path
                d="M16.19 2H7.81C4.17 2 2 4.17 2 7.81V16.18C2 19.83 4.17 22 7.81 22H16.18C19.82 22 21.99 19.83 21.99 16.19V7.81C22 4.17 19.83 2 16.19 2ZM15.36 14.3C15.65 14.59 15.65 15.07 15.36 15.36C15.21 15.51 15.02 15.58 14.83 15.58C14.64 15.58 14.45 15.51 14.3 15.36L12 13.06L9.7 15.36C9.55 15.51 9.36 15.58 9.17 15.58C8.98 15.58 8.79 15.51 8.64 15.36C8.35 15.07 8.35 14.59 8.64 14.3L10.94 12L8.64 9.7C8.35 9.41 8.35 8.93 8.64 8.64C8.93 8.35 9.41 8.35 9.7 8.64L12 10.94L14.3 8.64C14.59 8.35 15.07 8.35 15.36 8.64C15.65 8.93 15.65 9.41 15.36 9.7L13.06 12L15.36 14.3Z"
                fill="#1d9bf0"
              />
            </svg>

            <img src={Image2} alt="" />
          </div>
        )}
      </div>
    </div>
  );
}
