import { ethers } from "hardhat"; // Use ES module syntax
import hre from 'hardhat'; // Import hardhat runtime environment

const main = async () => {
    try {
        const [deployer] = await ethers.getSigners(); // Gets signers for signing deployed contracts

        console.log("Verifying contract...");

        const contractAddress = "0x86D50D642e15CAA3C7C11806adad4fA17c53Ba55";

        await hre.run("verify:verify", {
            address: contractAddress,
            constructorArguments: [],
        });

        console.log("agDAO Contract verified!");

    } catch (error) {
        console.error("Verification error: ", error);
    }
};

const runMain = async () => {
    try {
        await main();
        process.exit(0);
    } catch (error) {
        console.error("Error: ", error);
        process.exit(1);
    }
};

runMain();
// agDAO: 0x0438Cd38B03C5Bd0fd8091eF8e608A26707C93AF
// agDAOCOin: 0x86D50D642e15CAA3C7C11806adad4fA17c53Ba55