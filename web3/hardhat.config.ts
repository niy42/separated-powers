import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomiclabs/hardhat-ethers";
import * as dotenv from "dotenv";

dotenv.config();

const {
  ETHERSCAN_API_KEY,
  ALCHEMY_API_KEY,
  INFURA_PROJECT_ID,
  PRIVATE_KEY
} = process.env;

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.27",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  defaultNetwork: "sepolia",
  networks: {
    hardhat: {
      chainId: 1337, // Default Hardhat network ID
    },
    goerli: {
      url: `https://goerli.infura.io/v3/${INFURA_PROJECT_ID}`, // Goerli Testnet URL
      accounts: [`0x${PRIVATE_KEY}`], // Your wallet's private key
    },
    sepolia: {
      url: `https://eth-sepolia.g.alchemy.com/v2/${ALCHEMY_API_KEY}`, // Sepolia Testnet URL
      accounts: [`0x${PRIVATE_KEY}`], // Your wallet's private key
      chainId: 11155111,
    },
    mainnet: {
      url: `https://mainnet.infura.io/v3/${INFURA_PROJECT_ID}`, // Ethereum Mainnet URL
      accounts: [`0x${PRIVATE_KEY}`], // Your wallet's private key
    },
    // Add more networks as needed
  },
  etherscan: {
    apiKey: ETHERSCAN_API_KEY
  }
};

export default config;
