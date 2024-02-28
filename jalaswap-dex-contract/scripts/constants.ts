import hardhatConfig from "../hardhat.config"; // Adjust the path according to your project structure

export const wethAddresses: Record<string, string> = {
  [hardhatConfig.networks.chiliz.chainId]: "0x677F7e16C7Dd57be1D4C8aD1244883214953DC47",
  [hardhatConfig.networks.spicy.chainId]: "0x678c34581db0a7808d0aC669d7025f1408C9a3C6",
  [hardhatConfig.networks.neon.chainId]: "0x202c35e517fa803b537565c40f0a6965d7204609",
  [hardhatConfig.networks.neon_devnet.chainId]: "0x11adc2d986e334137b9ad0a0f290771f31e9517f",
};
