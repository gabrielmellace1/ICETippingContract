const { ethers } = require("hardhat");
const hre = require("hardhat");

async function main() {
  // Compile the contracts
  await hre.run("compile");

  // Deploy the contract
  const Tips = await ethers.getContractFactory("Tips");



  const tips = await Tips.deploy();

  await tips.deployed();
  console.log("Tips deployed to:", tips.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
