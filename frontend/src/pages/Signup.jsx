import {useNavigate} from 'react-router-dom';
import Web3 from "web3";

import { useEffect, useState } from "react";
import { contractABI, contractAddress } from '../contractDetails';


export default function Signup() {
  const [account, setAccount] = useState('');
  const [username, setUserName] = useState('');
  const [contract, setContract] = useState(null);
  const [web3, setWeb3] = useState(null);
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

 
  

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


  const registerUser = async (e) => {
    setLoading(true)
    e.preventDefault();
    if (!contract) {
      alert('Contract not loaded');
      return;
    }
    try {
      await contract.methods.registerUser(username, "bio", "profileImageHash").send({ from: account });
      alert('User registered successfully');
      navigate("/login")
    } catch (error) {
      console.error('Error registering user:', error);
      alert('Failed to register user');
    }
    setLoading(false)
  };


   
    return (
      <main className="auth">
        <div className="auth__card1">
          <div className="auth__card1__logo">
            Chainsphere Logo
          </div>
  
          <h1 className="auth__card1__title">Let’s sign you up!</h1>
  
          <form className="auth__card1__form" onSubmit={registerUser}>
            {/* <input
              type="text"
              className="auth__card1__form__input"
              placeholder="Enter Full Name"
            />
            <input
              type="email"
              className="auth__card1__form__input"
              placeholder="Email"
            /> */}
            <input
              type="text"
              className="auth__card1__form__input"
              placeholder="username"
              required
              value={username}
              onChange={(e) => setUserName(e.target.value)}
            />

{/* <div className="auth__card1__form__input-group">
  <input type="text" className="auth__card1__form__input-group__input" />
  <button className="auth__card1__form__input-group__button"

  >Connect wallet</button>
  </div>             */}
            {/* <input
              type="text"
              className="auth__card1__form__input"
              placeholder="Password"
            />
            <input
              type="text"
              className="auth__card1__form__input"
              placeholder="Confirm Password"
            /> */}
  
           
  
            <button className="auth__card1__form__button" type='submit' disabled={loading}>{loading ? "Loading..." : "Sign up"}</button>
  
            <h3 className="auth__card1__form__login">
            Already have an account? <span className="pointer" onClick={() => navigate("/login")}>Login</span>
            </h3>
          </form>
        </div>
        <div className="auth__card2">
        <div className="auth__card2__carousel">
        <h2 className="auth__card2__carousel__title">
        Experiencing the World of Decentralized social media with <br /> <span>Chainsphere</span>
          </h2>
      
  
  </div>
        </div>
      </main>
    );
  }
  