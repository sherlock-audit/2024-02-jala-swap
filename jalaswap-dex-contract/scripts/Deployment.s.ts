import "@nomiclabs/hardhat-ethers";

import { ethers } from "hardhat";
import { wethAddresses } from "./constants";

async function main() {
  const [deployer] = await ethers.getSigners();
  const network = await ethers.provider.getNetwork();
  const chainId = network.chainId;
  console.log(`Deployer: ${deployer.address} (${ethers.utils.formatEther(await deployer.getBalance())} ETH)`);

  // Deploy CAPOFactory with the address of the CAPO token
  const feeSetter = deployer.address;
  const capoFactoryFactory = await ethers.getContractFactory("CAPOFactory");
  const capoFactory = await capoFactoryFactory.deploy(feeSetter);
  await capoFactory.deployed();
  console.log(`CAPO Factory deployed to: ${capoFactory.address}`);

  // Deploy CAPORouter02 with the address of the CAPO factory and WETH token
  const WETH = wethAddresses[chainId];
  const CAPORouter02 = await ethers.getContractFactory("CAPORouter02");
  const capoRouter = await CAPORouter02.deploy(capoFactory.address, WETH);
  await capoRouter.deployed();
  console.log(`CAPO Router deployed to: ${capoRouter.address}`);
}

main()
  .then(() => {
    console.log("Deployment completed successfully!");
  })
  .catch((error) => {
    console.error(error);
    throw new Error(error);
  });
