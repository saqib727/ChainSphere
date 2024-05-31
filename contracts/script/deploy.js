const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  const SocialMedia = await hre.ethers.getContractFactory("SocialMedia");

  // Replace with actual deployed addresses
  const vrfConsumerAddress = "DEPLOYED_VRF_CONSUMER_ADDRESS";
  const priceFeedAddress = "CHAINLINK_PRICE_FEED_ADDRESS";

  const socialMedia = await SocialMedia.deploy(vrfConsumerAddress, priceFeedAddress);

  await socialMedia.deployed();

  console.log("SocialMedia deployed to:", socialMedia.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });


//   Chainlink VRF Coordinator for Polygon Mainnet: 0xAE975071Be8F8eE67addBC1A82488F1C24858067
// Chainlink VRF Coordinator for Mumbai Testnet: 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625