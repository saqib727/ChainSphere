const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  const VRFv2Consumer = await hre.ethers.getContractFactory("VRFv2Consumer");
  const subscriptionId = "YOUR_SUBSCRIPTION_ID"; // Replace with your actual subscription ID
  const vrfConsumer = await VRFv2Consumer.deploy(subscriptionId);

  await vrfConsumer.deployed();

  console.log("VRFv2Consumer deployed to:", vrfConsumer.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
