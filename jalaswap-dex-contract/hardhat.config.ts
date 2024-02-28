import "@nomiclabs/hardhat-waffle";
import "@nomiclabs/hardhat-etherscan";
import "dotenv/config";
import "hardhat-contract-sizer";

export default {
  solidity: {
    compilers: [
      {
        version: "0.8.20",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.8.9",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.5.16",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.6.6",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  networks: {
    spicy: {
      allowUnlimitedContractSize: true,
      url: "https://spicy-rpc.chiliz.com/",
      chainId: 88882,
      accounts: [process.env.TESTNET_KEY],
      gas: "auto",
      gasPrice: "auto",
      runs: 0,
    },
    chiliz: {
      allowUnlimitedContractSize: true,
      url: "https://chiliz.publicnode.com/",
      chainId: 88888,
      accounts: [process.env.MAINNET_KEY],
      gas: 20e6,
      gasPrice: 20e9,
      runs: 0,
    },
    neon: {
      allowUnlimitedContractSize: true,
      url: "https://neon-mainnet.everstake.one",
      chainId: 245022934,
      accounts: [process.env.MAINNET_KEY],
      gas: "auto",
      gasPrice: "auto",
      runs: 0,
    },
    neon_devnet: {
      allowUnlimitedContractSize: true,
      url: "https://devnet.neonevm.org",
      chainId: 245022926,
      accounts: [process.env.TESTNET_KEY],
      gas: "auto",
      gasPrice: "auto",
      runs: 0,
    },
  },
  mocha: {
    timeout: 400000000,
  },
};
