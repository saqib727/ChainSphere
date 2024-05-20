require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */

module.exports = {
  solidity: {

    version: "0.8.18", // Ensure this matches the version used by Foundry
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
    // networks: {
    //   sepolia: {
    //     url: "https://ethereum-sepolia-rpc.publicnode.com",
    //     accounts:"PRIVATE_KEY" // Optional, specify accounts if deploying from a specific account
    //   },
    //   polygon: {
    //     url: "https://rpc-mainnet.matic.network", // Use the Polygon RPC endpoint
    //     accounts: [PRIVATE_KEY] // Optional, specify accounts if deploying from a specific account
    //   },
    //   mumbai: {
    //     url: "https://rpc-mumbai.matic.today", // Polygon testnet
    //     accounts: ["YOUR_PRIVATE_KEY"] // Replace with your private key
    //   }
    // }
  },
  paths: {
    sources: "./src", // Source directory where your Foundry contracts are located
  },
};