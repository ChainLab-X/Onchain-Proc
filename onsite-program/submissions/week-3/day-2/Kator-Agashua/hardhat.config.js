require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config(); // Loads your PRIVATE_KEY from .env
const { ETHERSCAN_API_KEY, LISK_PRIVATE_KEY } = process.env;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.28", // Match your contract version
  networks: {
    // Lisk Sepolia Testnet
    "lisk-sepolia": {
      url: "https://rpc.sepolia-api.lisk.com",
      accounts: [`0x${LISK_PRIVATE_KEY}`],
      gasPrice: 1000000000, // 1 Gwei
    },
  },
  etherscan: {
    apiKey: ETHERSCAN_API_KEY, // Etherscan API key for verification},
  },
};

