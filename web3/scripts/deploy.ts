import { ethers } from "hardhat";

async function main() {
    // Get the contract to deploy
    const AGDAO = await ethers.getContractFactory("AgDAOCoin");

    // Deploy the contract
    const agdao = await AGDAO.deploy();

    // Wait for deployment to finish
    await agdao.deployed();

    console.log("AGDAO_coin deployed to:", agdao.address);
}

// Execute the main function and handle errors
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });