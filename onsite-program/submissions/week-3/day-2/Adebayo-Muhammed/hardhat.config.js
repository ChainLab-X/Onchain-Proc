require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

const { WALLET_KEY, LISK_API_KEY, LISK_URL_KEY } = process.env;

const config = {
  solidity: "0.8.23", // Matches Storage.sol pragma
  networks: {
    "lisk-sepolia": {
      url: LISK_URL_KEY, // https://rpc.sepolia-api.lisk.com
      accounts: WALLET_KEY ? [`0x${WALLET_KEY}`] : [], // Add 0x prefix to private key
      gasPrice: 1000000000, // As per Lisk documentation
      chainId: 4202, // Lisk Sepolia testnet chain ID
    },
  },
  etherscan: {
    apiKey: {
      "lisk-sepolia": LISK_API_KEY, // Blockscout API key for Lisk Sepolia
    },
    customChains: [
      {
        network: "lisk-sepolia",
        chainId: 4202,
        urls: {
          apiURL: "https://sepolia-blockscout.lisk.com/api", // Lisk Sepolia Blockscout API
          browserURL: "https://sepolia-blockscout.lisk.com", // Lisk Sepolia Blockscout URL
        },
      },
    ],
  },
  ignition: {
    strategy: "basic", // Support for Hardhat Ignition
  },
};

module.exports = config;