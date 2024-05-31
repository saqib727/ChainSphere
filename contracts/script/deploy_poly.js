const hre = require("hardhat");

async function main() {
  // Get the contract factories
  const SocialMedia = await hre.ethers.getContractFactory("SocialMedia");

  // Deploy the contract to the Polygon network
  console.log("Deploying SocialMedia contract to Polygon...");
  const socialMedia = await SocialMedia.deploy(
    "VRF_CONSUMER_ADDRESS_ON_POLYGON",
    "PRICE_FEED_ADDRESS_ON_POLYGON"
  );

  // Wait for the contract to be deployed
  await socialMedia.deployed();

  // Log the deployed contract address
  console.log("SocialMedia contract deployed to:", socialMedia.address);
}

// Execute the deployment function
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
