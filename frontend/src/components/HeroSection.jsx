import video1 from "../assets/video1.mp4";
import video2 from "../assets/video2.mp4";
import {useNavigate} from 'react-router-dom';

const HeroSection = () => {
  const navigate = useNavigate();

  return (
    <div className="flex flex-col items-center mt-6 lg:mt-20">
      <h1 className="text-4xl sm:text-6xl lg:text-9xl text-center tracking-wide">
        Welcome to Chain Sphere –
        <span className="bg-gradient-to-r from-orange-500 to-red-800 text-transparent bg-clip-text">
          {" "}
          Decentralized Social Media for the Modern Age
        </span>
      </h1>
      <p className="mt-10 lg:text-3xl text-center text-neutral-500 max-w-7xl">
        Unleash the Power of Decentralization! Connect Freely, Securely,
        Decentralized. Your Data, Your Control, Your Network. Revolutionizing
        Connections, One Node at a Time. Decentralized Connectivity for a
        Decentralized World.
      </p>
      <div className="flex justify-center my-10">
        <a
        onClick={() => navigate('/signup')}
          className="bg-gradient-to-r from-orange-500 to-orange-800 py-3 px-4 mx-3 rounded-md"
        >
          Start for free
        </a>
        <a href="#" className="py-3 px-4 mx-3 rounded-md border">
          Documentation
        </a>
      </div>
      <div className="flex mt-10 justify-center">
        <video
          autoPlay
          loop
          muted
          className="rounded-lg w-1/2 border border-orange-700 shadow-sm shadow-orange-400 mx-2 my-4"
        >
          <source src={video1} type="video/mp4" />
          Your browser does not support the video tag.
        </video>
        <video
          autoPlay
          loop
          muted
          className="rounded-lg w-1/2 border border-orange-700 shadow-sm shadow-orange-400 mx-2 my-4"
        >
          <source src={video2} type="video/mp4" />
          Your browser does not support the video tag.
        </video>
      </div>
    </div>
  );
};

export default HeroSection;
