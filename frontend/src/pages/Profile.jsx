import { useEffect, useRef, useState } from "react";
import Image1 from "../assets/Rectangle 41.png";

import PostCard from "../components/PostCard";
import Sidebar from "../components/Sidebar";
import Links from "../components/Links";
import { useDispatch, useSelector } from "react-redux";
import { useNavigate } from "react-router-dom";
import Web3 from 'web3';
import { contractABI, contractAddress } from "../contractDetails";
import axios from 'axios';
import jwt from "jsonwebtoken";



export default function Profile() {

  const JWT = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySW5mb3JtYXRpb24iOnsiaWQiOiJlZTI4ZjFjNi05YzVkLTQ2OTUtOTA5ZC1kMDVkYTE1MTZhNTMiLCJlbWFpbCI6InNhbGVlbWppYnJpbDVAZ21haWwuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsInBpbl9wb2xpY3kiOnsicmVnaW9ucyI6W3siaWQiOiJGUkExIiwiZGVzaXJlZFJlcGxpY2F0aW9uQ291bnQiOjF9LHsiaWQiOiJOWUMxIiwiZGVzaXJlZFJlcGxpY2F0aW9uQ291bnQiOjF9XSwidmVyc2lvbiI6MX0sIm1mYV9lbmFibGVkIjpmYWxzZSwic3RhdHVzIjoiQUNUSVZFIn0sImF1dGhlbnRpY2F0aW9uVHlwZSI6InNjb3BlZEtleSIsInNjb3BlZEtleUtleSI6IjhmYTZmMmU5NTNkNjk5OTIyMjIyIiwic2NvcGVkS2V5U2VjcmV0IjoiMWRkMzViMzcwZDQ4NGVkY2E2MDNlZGY0OTZhMTg2NGRhODNlYjk5MTIxNDQwMmZlNWFmZmI3OTQ5NjY2NWY0NyIsImlhdCI6MTcxNjk3NTQ3OX0.O81OxR4z2tEuWUK3xIbnDT4Zm2PjYKtJckyWKUsPjJc"

  const auth = useSelector((state) => state.auth);
  const [loading, setLoading] = useState(false);
  const [account, setAccount] = useState('');
  const [contract, setContract] = useState(null);
  const [web3, setWeb3] = useState(null);
  const [posts, setPosts] = useState([]);
  const [name, setName] = useState(auth?.userInfo?.name);
  const [username, setUserName] = useState(auth?.userInfo?.username);
  const [address, setAddress] = useState(auth?.userInfo?.address);
  const [bio, setBio] = useState(auth?.userInfo?.bio);
  const [userId, setUserId] = useState("");
  const [image, setImage] = useState(null);
  const [uploadedImage, setUploadedImage] = useState(null);
  const mediaRef = useRef(null);



  const dispatch = useDispatch();
  const navigate = useNavigate();


  const [tab, setTab] = useState("posts");


  const handleLogout = () => {
    dispatch({
      type: "LOGOUT_SUCCESS",
    });
    localStorage.removeItem("token");
    navigate("/login");
    window.scrollTo(0, 0);
  };

  const fetchUserPosts = async (contract, account) => {
    try {
      const posts = await contract.methods.getUserPosts(account).call();
      console.log('posts', posts);
      setPosts(posts);
    } catch (error) {
      console.error('Error fetching posts:', error);
      alert(`Failed to fetch posts ${error?.message || error?.toString()}`);
    }
  };

  const initFetchUserPosts = () => {
    if (window.ethereum) {
      const web3Instance = new Web3(window.ethereum);
      window.ethereum.enable().then(accounts => {
        setWeb3(web3Instance);
        setAccount(accounts[0]);
        const myContract = new web3Instance.eth.Contract(contractABI, contractAddress);
        setContract(myContract);
        fetchUserPosts(myContract, accounts[0]);
      }).catch(error => {
        console.error("User denied account access");
        alert("User denied account access");
      });
    } else {
      alert('MetaMask not detected. Please install MetaMask to use this feature.');
    }
  }

  useEffect(() => {
    initFetchUserPosts();
  }, []);

  const getUserInfo = async () => {
    setLoading(true)
    if (!contract) {
      // alert('Contract not loaded');
      return;
    }
    try {
      console.log('here');
      const userData = await contract.methods.getUser(account).call();
      if (userData.userAddress === '0x0000000000000000000000000000000000000000') {
        alert('User not registered');
      } else {
        console.log('userData getUserprofile', userData);
        setName(userData?.fullNameOfUser)
        setUserName(userData?.nickName)
        setAddress(userData?.userAddress)
        setBio(userData?.bio)
        setUserId(Number(userData?.id))
        setImage(userData?.profileImageHash)
      }
    } catch (error) {
      console.error('Error logging in:', error);
      alert(`Failed to get user info ${error?.message || error?.toString()}`);

    }
    setLoading(false)
  };

  useEffect(() => {
    getUserInfo();
  }, [contract]);



  const pinFileToIPFS = async (file) => {
    if (file) {
      const formData = new FormData();
      formData.append('file', file);

      console.log('deyyah!');
  
      const pinataMetadata = JSON.stringify({
        name: file.name,
      });
      formData.append('pinataMetadata', pinataMetadata);
  
      const pinataOptions = JSON.stringify({
        cidVersion: 0,
      });
      formData.append('pinataOptions', pinataOptions);
  
      try {
        const res = await axios.post("https://api.pinata.cloud/pinning/pinFileToIPFS", formData, {
          maxBodyLength: "Infinity",
          headers: {
            'Content-Type': `multipart/form-data; boundary=${formData._boundary}`,
            'Authorization': `Bearer ${JWT}`
          }
        });
        return res.data;
      } catch (error) {
        console.log(error);
        alert(`Failed to upload image ${error?.message || error?.toString()}`);

      }
    }
}

  const editProfile = async (e) => {
    e.preventDefault();
    if(!image && !uploadedImage) {
      alert("please upload profile image")
      return;
    }
    setLoading(true)
    try {
      let imgHash;
      
      // Call the editUserProfile function on the smart contract
      // await contract.editUserProfile(userId, bio, "profileImageHash", name);
      if(!!uploadedImage) {
        imgHash = await pinFileToIPFS(uploadedImage);
      }
console.log('pinata!', imgHash);
      await contract.methods.editUserProfile(userId, bio, imgHash?.IpfsHash || image, name).send({ from: account });

      // Reset form fields after successful submission
      // setUserId('');
      // setBio('');
      // setProfileImageHash('');
      // setNewName('');
      alert('Profile updated successfully!');

      const userData = await contract.methods.getUser(account).call();
      if (userData.userAddress === '0x0000000000000000000000000000000000000000') {
        alert('User not registered');
      } else {
        console.log('userData', userData);
        // setUser(userData);
        console.log("REACT_APP_JWT_SECRET", process.env.REACT_APP_JWT_SECRET, "REACT_APP_JWT_EXPIRES_IN", process.env.REACT_APP_JWT_EXPIRES_IN);

        const signToken = () => {
          return  jwt.sign(
            {
              name: userData?.fullNameOfUser,
              username: userData?.nickName,
             address: userData?.userAddress,
              profilePic: userData?.profileImageHash,
              bio: userData?.bio
            },
            process.env.REACT_APP_JWT_SECRET,
            {
              expiresIn: process.env.REACT_APP_JWT_EXPIRES_IN,
            }
          );
        }
        const token = signToken()
        console.log('jwt.sign', token)
        localStorage.setItem("token", token);
        dispatch({
          type: "USER_LOGIN_SUCCESS",
          payload: {
            token,
          },
        });
        // navigate("/feed")
      }
    } catch (error) {
      console.error('Error updating profile:', error);
      alert(`Failed to update profile ${error?.message || error?.toString()}`);
    }
    setLoading(false)

  };
console.log('image', image);
  return (
    // THings to add
    <div className="profile">
      <main className="profile__main">
        <Sidebar />
        <div className="profile__main__timeline">
          <div className="profile__main__timeline__nav">
            <h1
              className={tab === "posts" && "profile__main__timeline__nav__active"}
              onClick={() => setTab("posts")}
            >
              Postsfd
            </h1>
            <h1
              className={
                tab === "profile" && "profile__main__timeline__nav__active"
              }
              onClick={() => setTab("profile")}
            >
              Profile details
            </h1>
          </div>
         {tab === "posts" && <div className="profile__main__timeline__cards">
         {posts?.map((post) => post?.author !== "0x0000000000000000000000000000000000000000" && <PostCard getUsersPosts={initFetchUserPosts} post = {post} />)}

          </div>}

         {tab === "profile" && 
         <form className="profile__main__timeline__form" onSubmit={editProfile}>
            <div className="profile__main__timeline__form__img">
           {image || uploadedImage ? <svg
                    onClick={() => {
                      setImage(null)
                      setUploadedImage(null)
                    }}
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
                  </svg> : ""}
                  <label>
                  {!image && !uploadedImage ?  <div className="profile__main__timeline__form__img__upload">
                  <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><g id="SVGRepo_bgCarrier" stroke-width="0"></g><g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g><g id="SVGRepo_iconCarrier"> <path d="M15 13H9" stroke="#15202B" stroke-width="1.5" stroke-linecap="round"></path> <path d="M12 10L12 16" stroke="#15202B" stroke-width="1.5" stroke-linecap="round"></path> <path d="M9.77778 21H14.2222C17.3433 21 18.9038 21 20.0248 20.2646C20.51 19.9462 20.9267 19.5371 21.251 19.0607C22 17.9601 22 16.4279 22 13.3636C22 10.2994 22 8.76721 21.251 7.6666C20.9267 7.19014 20.51 6.78104 20.0248 6.46268C19.3044 5.99013 18.4027 5.82123 17.022 5.76086C16.3631 5.76086 15.7959 5.27068 15.6667 4.63636C15.4728 3.68489 14.6219 3 13.6337 3H10.3663C9.37805 3 8.52715 3.68489 8.33333 4.63636C8.20412 5.27068 7.63685 5.76086 6.978 5.76086C5.59733 5.82123 4.69555 5.99013 3.97524 6.46268C3.48995 6.78104 3.07328 7.19014 2.74902 7.6666C2 8.76721 2 10.2994 2 13.3636C2 16.4279 2 17.9601 2.74902 19.0607C3.07328 19.5371 3.48995 19.9462 3.97524 20.2646C5.09624 21 6.65675 21 9.77778 21Z" stroke="#15202B" stroke-width="1.5"></path> <path d="M19 10H18" stroke="#15202B" stroke-width="1.5" stroke-linecap="round"></path> </g></svg>
                    </div> : ""}

                  <input
                        type="file"
                        name=""
                        id=""
                        hidden
                        ref={mediaRef}
                        accept="image/*"

                        onChange={e => setUploadedImage(e.target.files[0])}
                      />
                  </label>

            {uploadedImage || image ?
             <img className="" src={uploadedImage ? URL.createObjectURL(uploadedImage) : `https://gateway.pinata.cloud/ipfs/${image}`} alt="" /> : ""
             }
            </div>
            <input className="profile__main__timeline__form__input" type="text" value={name} onChange={(e) => setName(e.target.value)} required />
            <input className="profile__main__timeline__form__input" type="text" value={username} required disabled />
            <input className="profile__main__timeline__form__input" type="text" value={address} required disabled />
            <textarea className="profile__main__timeline__form__input profile__main__timeline__form__textarea" type="text" value={bio}
             onChange={(e) => setBio(e.target.value)} 
             required
              />

            <button className="profile__main__timeline__form__button" type="submit">{loading ? "Loading..." : "Update"}</button>
            <button className="profile__main__timeline__form__button profile__main__timeline__form__logout" onClick={handleLogout}>Logout</button>
          </form>}
        </div>
        <Links />
       
      </main>
    </div>
  );
}
