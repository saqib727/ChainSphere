const { ethers } = require("ethers");
const chainspere = require("../ABI/chainspere.json");
const { NETWORKS } = require("./config");

// dotenv.config();

// const { PRIVATE_KEY, POLYGON_AMOY } = process.env;
const chainID = 80002;

const network = NETWORKS[chainID];

async function getContract() {
  // if (!PRIVATE_KEY) {
  //   throw new Error("DEPLOYER_PRIVATE_KEY is undefined");
  // }
  // Get signer
  // const deployer = new ethers.Wallet(PRIVATE_KEY);
  // const provider = new ethers.providers.JsonRpcProvider(POLYGON_AMOY);
  // const signer = deployer.connect(provider);

  // Get contract instances
  const socialMediaInstance = new ethers.Contract(
    network.SOCIAL_MEDIA,
    chainspere.abi,
    // signer
  );
  

  return {
    // signer,
    socialMediaInstance,
  };
}

module.exports = { getContract };
