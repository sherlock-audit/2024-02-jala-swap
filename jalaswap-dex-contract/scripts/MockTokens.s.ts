import "@nomiclabs/hardhat-ethers";

import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(`Deployer: ${deployer.address} (${ethers.utils.formatEther(await deployer.getBalance())} ETH)`);

  // Deploy CAPOFactory with the address of the CAPO token
  const erc20MintableFactory = await ethers.getContractFactory("ERC20Mintable");

  const TKNAAddress = "";
  const TKNBAddress = "";
  const TKNCAddress = "";

  let erc20MintableA;
  let erc20MintableB;
  let erc20MintableC;

  if (TKNAAddress === "" && TKNBAddress === "" && TKNCAddress === "") {
    erc20MintableA = await erc20MintableFactory.deploy("TOKEN A", "TKNA");
    await erc20MintableA.deployed();
    console.log(`TKNA deployed to: ${erc20MintableA.address}`);

    erc20MintableB = await erc20MintableFactory.deploy("TOKEN B", "TKNB");
    await erc20MintableB.deployed();
    console.log(`TKNB deployed to: ${erc20MintableB.address}`);

    erc20MintableC = await erc20MintableFactory.deploy("TOKEN C", "TKNC");
    await erc20MintableC.deployed();
    console.log(`TKNC deployed to: ${erc20MintableC.address}`);
  } else {
    erc20MintableA = erc20MintableFactory.attach(TKNAAddress);
    console.log(`TKNA attached to: ${erc20MintableA.address}`);

    erc20MintableB = erc20MintableFactory.attach(TKNBAddress);
    console.log(`TKNB attached to: ${erc20MintableB.address}`);

    erc20MintableC = erc20MintableFactory.attach(TKNCAddress);
    console.log(`TKNC attached to: ${erc20MintableC.address}`);
  }

  // Mint new tokens
  const mintAmount = ethers.utils.parseUnits("100000", 18); // Example: 100,000 tokens with 18 decimal places

  await erc20MintableA.mint(mintAmount, deployer.address);
  console.log(`Minted ${mintAmount} TKNA to: ${deployer.address}`);

  await erc20MintableB.mint(mintAmount, deployer.address);
  console.log(`Minted ${mintAmount} TKNB to: ${deployer.address}`);

  await erc20MintableC.mint(mintAmount, deployer.address);
  console.log(`Minted ${mintAmount} TKNC to: ${deployer.address}`);
}

main()
  .then(() => {
    console.log("Tokens minted successfully!");
  })
  .catch((error) => {
    console.error(error);
    throw new Error(error);
  });
