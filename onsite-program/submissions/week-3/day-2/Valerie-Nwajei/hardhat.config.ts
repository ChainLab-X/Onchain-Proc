

import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import * as dotenv from "dotenv";

dotenv.config();

const { PRIVATE_KEY, LISK_URL_KEY } = process.env;


const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.28",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    hardhat: {
      chainId: 1337,
    },
    liskSepolia: {
      url: "https://rpc.sepolia-api.lisk.com",
      accounts: [`0x${PRIVATE_KEY}`],
      chainId: 4202,
    },
  },
};
export default config;