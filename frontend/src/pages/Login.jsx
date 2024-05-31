import { useNavigate } from "react-router-dom";
import Web3 from "web3";
import { useEffect, useState } from "react";
import { contractABI, contractAddress } from "../contractDetails";
import jwt from "jsonwebtoken";
import { useDispatch } from "react-redux";



export default function Login() {
  const dispatch = useDispatch();
  const [account, setAccount] = useState('');
  const [name, setName] = useState('');
  const [bio, setBio] = useState('');
  const [profileImageHash, setProfileImageHash] = useState('');
  const [contract, setContract] = useState(null);
  const [web3, setWeb3] = useState(null);
  const navigate = useNavigate();
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(false);



  useEffect(() => {
    if (window.ethereum) {
      console.log('window.ethereum', window.ethereum);
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




  const login = async (e) => {
    setLoading(true)
    e.preventDefault();
    if (!contract) {
      alert('Contract not loaded');
      return;
    }
    try {
      const userData = await contract.methods.getUser(account).call();
      if (userData.userAddress === '0x0000000000000000000000000000000000000000') {
        alert('User not registered');
      } else {
        console.log('userData', userData);
        setUser(userData);
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
        navigate("/feed")
      }
    } catch (error) {
      console.error('Error logging in:', error);
      alert(`Failed to login ${error?.message || error?.toString()}`);

    }
    setLoading(false)
  };



  return (
    <main className='auth'>
      <div className='auth__card1'>
        <div className='auth__card1__logo'>Chainsphere Logo</div>

        <h1 className='auth__card1__title'>Welcome back!</h1>

        <form className='auth__card1__form'>
          {/* <input
            type='text'
            className='auth__card1__form__input'
            placeholder='Enter username'
          />
          <input
            type='password'
            className='auth__card1__form__input'
            placeholder='Password'
          /> */}

          {/* <div className='auth__card1__form__option'>OR</div> */}

          {/* <div className='auth__card1__form__input-group'>
            <input
              type='text'
              className='auth__card1__form__input-group__input'
              value={account}
            />
            <button
              className='auth__card1__form__input-group__button'
              // onClick={() => open()}
            >
              Connect wallet
            </button>
          </div> */}

          <button className='auth__card1__form__button' onClick={login} disabled={loading}>{loading ? "Loading..." : "Login"}</button>

          <h3 className='auth__card1__form__login' >
            Don't have an account?{" "}
            <span className='pointer' onClick={() => navigate("/signup")}>
              Signup
            </span>
          </h3>
        </form>
      </div>
      <div className='auth__card2'>
        <div className='auth__card2__carousel'>
          <h2 className='auth__card2__carousel__title'>
            Experiencing the World of Decentralized social media with <br />{" "}
            <span>Chainsphere</span>
          </h2>
        </div>
      </div>
    </main>
  );
}
