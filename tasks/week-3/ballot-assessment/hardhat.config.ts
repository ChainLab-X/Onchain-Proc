import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";require("dotenv").config();

const {ALCHEMY_AMOY_API_KEY_URL, ACCOUNT_PRIVATE_KEY} = process.env;

const config: HardhatUserConfig = {
  solidity: "0.8.28",

  networks: {
    hardhat: {
    },
    polygoneAmoy: {
      url: ALCHEMY_AMOY_API_KEY_URL,
      accounts: [`0x${ACCOUNT_PRIVATE_KEY}`]
    }
  }
};

export default config;
