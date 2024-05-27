import { useEffect, useState } from "react";
import Image1 from "../assets/Rectangle 41.png";
import { useRef } from "react";
import { contractABI, contractAddress } from '../contractDetails';
import Web3 from "web3";

import {useNavigate, useLocation} from 'react-router-dom';

export default function Sidebar() {
    const [modalOpen, setModalOpen] = useState(false);
    const mediaRef = useRef(null);
    const [account, setAccount] = useState('');
    const [contract, setContract] = useState(null);
    const [web3, setWeb3] = useState(null);
    const [content, setContent] = useState('');
    const [image, setImage] = useState(null);
    const [loading, setLoading] = useState(false);
  

    const navigate = useNavigate();
    const { pathname } = useLocation();

  
    const handleModalOpen = () => {
      setModalOpen(true);
      };

      useEffect(() => {
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

      // const uploadImageToPinata = async (file) => {
      //   const url = https://api.pinata.cloud/pinning/pinFileToIPFS;
      //   let data = new FormData();
      //   data.append('file', file);
    
      //   const response = await axios.post(url, data, {
      //     headers: {
      //       'pinata_api_key': pinataApiKey,
      //       'pinata_secret_api_key': pinataSecretApiKey,
      //       'Content-Type': 'multipart/form-data'
      //     }
      //   });
      //   return response.data.IpfsHash;
      // };

      
  const createPost = async (e) => {
    e.preventDefault();
    setLoading(true)
    if (!contract) {
      alert('Contract not loaded');
      return;
    }
    // if (!image) {
    //   alert('Please select an image');
    //   return;
    // }

    try {
      // Upload image to Pinata
      // const imgHash = await uploadImageToPinata(image);

      // Create post on blockchain
      await contract.methods.createPost(content, "imgHash").send({ from: account });
      setModalOpen(false)
      setContent('');
      setImage(null);
    } catch (error) {
      console.error('Error creating post:', error);
      alert('Failed to create post');
    }
    setLoading(false)

  };

    return (
        <div className="sidebar">
          <div className="sidebar__inner">
            <div className="sidebar__inner__logo">
              <div>Logo</div>
            </div>

            <div className={pathname.includes("feed") ? "sidebar__inner__group sidebar__inner__group-active" : "sidebar__inner__group"}
            onClick={() => navigate("/feed")}
            >
              <svg
                viewBox="0 0 24 24"
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
                    d="M2.5192 7.82274C2 8.77128 2 9.91549 2 12.2039V13.725C2 17.6258 2 19.5763 3.17157 20.7881C4.34315 22 6.22876 22 10 22H14C17.7712 22 19.6569 22 20.8284 20.7881C22 19.5763 22 17.6258 22 13.725V12.2039C22 9.91549 22 8.77128 21.4808 7.82274C20.9616 6.87421 20.0131 6.28551 18.116 5.10812L16.116 3.86687C14.1106 2.62229 13.1079 2 12 2C10.8921 2 9.88939 2.62229 7.88403 3.86687L5.88403 5.10813C3.98695 6.28551 3.0384 6.87421 2.5192 7.82274ZM11.25 18C11.25 18.4142 11.5858 18.75 12 18.75C12.4142 18.75 12.75 18.4142 12.75 18V15C12.75 14.5858 12.4142 14.25 12 14.25C11.5858 14.25 11.25 14.5858 11.25 15V18Z"
                    fill="#FFF"
                  ></path>{" "}
                </g>
              </svg>
              Home
            </div>
            <div className={pathname.includes("profile") ? "sidebar__inner__group sidebar__inner__group-active" : "sidebar__inner__group"}
            onClick={() => navigate("/profile")}
            >
              <svg
                className="sidebar__inner__group__profile-svg"
                viewBox="0 0 20 20"
                version="1.1"
                xmlns="http://www.w3.org/2000/svg"
                xmlnsXlink="http://www.w3.org/1999/xlink"
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
                  <title>profile_round [#1342]</title>{" "}
                  <desc>Created with Sketch.</desc> <defs> </defs>{" "}
                  <g
                    id="Page-1"
                    stroke="none"
                    stroke-width="1"
                    fill="none"
                    fill-rule="evenodd"
                  >
                    {" "}
                    <g
                      id="Dribbble-Light-Preview"
                      transform="translate(-140.000000, -2159.000000)"
                      fill="#FFF"
                    >
                      {" "}
                      <g
                        id="icons"
                        transform="translate(56.000000, 160.000000)"
                      >
                        {" "}
                        <path
                          d="M100.562548,2016.99998 L87.4381713,2016.99998 C86.7317804,2016.99998 86.2101535,2016.30298 86.4765813,2015.66198 C87.7127655,2012.69798 90.6169306,2010.99998 93.9998492,2010.99998 C97.3837885,2010.99998 100.287954,2012.69798 101.524138,2015.66198 C101.790566,2016.30298 101.268939,2016.99998 100.562548,2016.99998 M89.9166645,2004.99998 C89.9166645,2002.79398 91.7489936,2000.99998 93.9998492,2000.99998 C96.2517256,2000.99998 98.0830339,2002.79398 98.0830339,2004.99998 C98.0830339,2007.20598 96.2517256,2008.99998 93.9998492,2008.99998 C91.7489936,2008.99998 89.9166645,2007.20598 89.9166645,2004.99998 M103.955674,2016.63598 C103.213556,2013.27698 100.892265,2010.79798 97.837022,2009.67298 C99.4560048,2008.39598 100.400241,2006.33098 100.053171,2004.06998 C99.6509769,2001.44698 97.4235996,1999.34798 94.7348224,1999.04198 C91.0232075,1998.61898 87.8750721,2001.44898 87.8750721,2004.99998 C87.8750721,2006.88998 88.7692896,2008.57398 90.1636971,2009.67298 C87.1074334,2010.79798 84.7871636,2013.27698 84.044024,2016.63598 C83.7745338,2017.85698 84.7789973,2018.99998 86.0539717,2018.99998 L101.945727,2018.99998 C103.221722,2018.99998 104.226185,2017.85698 103.955674,2016.63598"
                          id="profile_round-[#1342]"
                        >
                          {" "}
                        </path>{" "}
                      </g>{" "}
                    </g>{" "}
                  </g>{" "}
                </g>
              </svg>
              Profile
            </div>
          </div>

          <button className="sidebar__button" onClick={handleModalOpen}>
            {" "}
            <svg
              viewBox="0 0 24 24"
              xmlns="http://www.w3.org/2000/svg"
              id="create-note"
              class="icon glyph"
              fill="#FFF"
              stroke="#FFF"
            >
              <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
              <g
                id="SVGRepo_tracerCarrier"
                stroke-linecap="round"
                stroke-linejoin="round"
              ></g>
              <g id="SVGRepo_iconCarrier">
                <path d="M20.71,3.29a2.91,2.91,0,0,0-2.2-.84,3.25,3.25,0,0,0-2.17,1L9.46,10.29s0,0,0,0a.62.62,0,0,0-.11.17,1,1,0,0,0-.1.18l0,0L8,14.72A1,1,0,0,0,9,16a.9.9,0,0,0,.28,0l4-1.17,0,0,.18-.1a.62.62,0,0,0,.17-.11l0,0,6.87-6.88a3.25,3.25,0,0,0,1-2.17A2.91,2.91,0,0,0,20.71,3.29Z"></path>
                <path
                  d="M20,22H4a2,2,0,0,1-2-2V4A2,2,0,0,1,4,2h8a1,1,0,0,1,0,2H4V20H20V12a1,1,0,0,1,2,0v8A2,2,0,0,1,20,22Z"
                  style={{ fill: "#FFF" }}
                ></path>
              </g>
            </svg>{" "}
            Create Post
          </button>

          {modalOpen && (
          <div className="sidebar__modal">
            <div className="sidebar__modal__inner">
              <div className="sidebar__modal__inner__grid">
                <img
                  className="sidebar__modal__inner__grid__img"
                  src={Image1}
                  alt=""
                />
                <form className="sidebar__modal__inner__grid__form" onSubmit={createPost}>
                  <textarea
                    name=""
                    id=""
                    className="sidebar__modal__inner__grid__form__input"
                    placeholder="What's happening?"
                    maxLength={200}
                    value={content}
                    onChange={(e) => setContent(e.target.value)}
                    required
                  ></textarea>
                 {image && <div className="sidebar__modal__inner__grid__form__img">
                 <svg
                    onClick={() => setImage(null)}
                    width="24"
                    height="24"
                    viewBox="0 0 24 24"
                    fill="none"
                    xmlns="http://www.w3.org/2000/svg"
                  >
                    <path
                      d="M16.19 2H7.81C4.17 2 2 4.17 2 7.81V16.18C2 19.83 4.17 22 7.81 22H16.18C19.82 22 21.99 19.83 21.99 16.19V7.81C22 4.17 19.83 2 16.19 2ZM15.36 14.3C15.65 14.59 15.65 15.07 15.36 15.36C15.21 15.51 15.02 15.58 14.83 15.58C14.64 15.58 14.45 15.51 14.3 15.36L12 13.06L9.7 15.36C9.55 15.51 9.36 15.58 9.17 15.58C8.98 15.58 8.79 15.51 8.64 15.36C8.35 15.07 8.35 14.59 8.64 14.3L10.94 12L8.64 9.7C8.35 9.41 8.35 8.93 8.64 8.64C8.93 8.35 9.41 8.35 9.7 8.64L12 10.94L14.3 8.64C14.59 8.35 15.07 8.35 15.36 8.64C15.65 8.93 15.65 9.41 15.36 9.7L13.06 12L15.36 14.3Z"
                      fill="red"
                    />
                  </svg>
                 <img
                      src={Image1}
                      alt=""
                      className=""
                    />
                 </div>}
                    
                  <div className="sidebar__modal__inner__grid__form__flex">
                    <label className="pointer">
                      <input
                        type="file"
                        name=""
                        id=""
                        hidden
                        ref={mediaRef}
                        accept="image/*"

                        onChange={(e) => setImage(e.target.value)}
                      />
                      {!image && <svg
                        width="20"
                        height="20"
                        viewBox="0 0 24 24"
                        fill="none"
                        xmlns="http://www.w3.org/2000/svg"
                      >
                        <path
                          d="M20.97 1H18.03C17.16 1 16.52 1.36 16.23 2C16.07 2.29 16 2.63 16 3.03V5.97C16 7.24 16.76 8 18.03 8H20.97C21.37 8 21.71 7.93 22 7.77C22.64 7.48 23 6.84 23 5.97V3.03C23 1.76 22.24 1 20.97 1ZM21.91 4.93C21.81 5.03 21.66 5.1 21.5 5.11H20.09V5.62L20.1 6.5C20.09 6.67 20.03 6.81 19.91 6.93C19.81 7.03 19.66 7.1 19.5 7.1C19.17 7.1 18.9 6.83 18.9 6.5V5.1L17.5 5.11C17.17 5.11 16.9 4.83 16.9 4.5C16.9 4.17 17.17 3.9 17.5 3.9L18.38 3.91H18.9V2.51C18.9 2.18 19.17 1.9 19.5 1.9C19.83 1.9 20.1 2.18 20.1 2.51L20.09 3.22V3.9H21.5C21.83 3.9 22.1 4.17 22.1 4.5C22.09 4.67 22.02 4.81 21.91 4.93Z"
                          fill="#FFF"
                        />
                        <path
                          d="M9.00012 10.3801C10.3146 10.3801 11.3801 9.31456 11.3801 8.00012C11.3801 6.68568 10.3146 5.62012 9.00012 5.62012C7.68568 5.62012 6.62012 6.68568 6.62012 8.00012C6.62012 9.31456 7.68568 10.3801 9.00012 10.3801Z"
                          fill="#FFF"
                        />
                        <path
                          d="M20.97 8H20.5V12.61L20.37 12.5C19.59 11.83 18.33 11.83 17.55 12.5L13.39 16.07C12.61 16.74 11.35 16.74 10.57 16.07L10.23 15.79C9.52 15.17 8.39 15.11 7.59 15.65L3.85 18.16C3.63 17.6 3.5 16.95 3.5 16.19V7.81C3.5 4.99 4.99 3.5 7.81 3.5H16V3.03C16 2.63 16.07 2.29 16.23 2H7.81C4.17 2 2 4.17 2 7.81V16.19C2 17.28 2.19 18.23 2.56 19.03C3.42 20.93 5.26 22 7.81 22H16.19C19.83 22 22 19.83 22 16.19V7.77C21.71 7.93 21.37 8 20.97 8Z"
                          fill="#FFF"
                        />
                      </svg>}
                    </label>
                    <div className="sidebar__modal__inner__grid__form__flex__button-group">
                      <button onClick={() => setModalOpen(false)}>
                        Cancel
                      </button>
                      <button type="submit" disabled={loading}>{loading ? "Loading..." : "Post"}</button>
                    </div>
                  </div>
                </form>
              </div>
            </div>
          </div>
        )}
        </div>
    )
}