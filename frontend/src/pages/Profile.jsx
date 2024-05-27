import { useEffect, useState } from "react";
import Image1 from "../assets/Rectangle 41.png";

import PostCard from "../components/PostCard";
import Sidebar from "../components/Sidebar";
import Links from "../components/Links";
import { useDispatch, useSelector } from "react-redux";
import { useNavigate } from "react-router-dom";
import Web3 from 'web3';
import { contractABI, contractAddress } from "../contractDetails";


export default function Profile() {
  const auth = useSelector((state) => state.auth);
  const [bio, setBio] = useState(auth?.userInfo?.bio);
  const [account, setAccount] = useState('');
  const [contract, setContract] = useState(null);
  const [web3, setWeb3] = useState(null);
  const [posts, setPosts] = useState([]);

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
    }
  };

  useEffect(() => {
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
      });
    } else {
      alert('MetaMask not detected. Please install MetaMask to use this feature.');
    }
  }, []);

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
              Posts
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
         {posts?.map((post) => <PostCard post = {post} />)}

          </div>}

         {tab === "profile" && <div className="profile__main__timeline__form">
            <div className="profile__main__timeline__form__img">
            <svg
                    // onClick={() => setImage(null)}
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
            <img className="" src={Image1} alt="" />
            </div>
            <input className="profile__main__timeline__form__input" type="text" value="Saleem Jibril"  />
            <input className="profile__main__timeline__form__input" type="text" value={auth?.userInfo?.name} disabled />
            <input className="profile__main__timeline__form__input" type="text" value={auth?.userInfo?.address} disabled 
            
            />
            <textarea className="profile__main__timeline__form__input profile__main__timeline__form__textarea" type="text" value={bio}
             onChange={(e) => setBio(e.target.value)} 
             disabled 
              />

            <button className="profile__main__timeline__form__button">Update</button>
            <button className="profile__main__timeline__form__button profile__main__timeline__form__logout" onClick={handleLogout}>Logout</button>
          </div>}
        </div>
        <Links />
       
      </main>
    </div>
  );
}
