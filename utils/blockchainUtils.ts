import { ethers, Contract } from 'ethers';
import agContract from './agDAOCoinABI.json';

// Define the contract address and ABI
const contractAddress = '0x86D50D642e15CAA3C7C11806adad4fA17c53Ba55'; // Your contract address
const contractABI = agContract.abi; // Your contract ABI

let provider: ethers.providers.Web3Provider | undefined;
export let contract: Contract | undefined;

// Initialize the connection
export const init = async () => {
    try {
        // Check if MetaMask is installed
        if (!window.ethereum) {
            throw new Error('MetaMask is not installed');
        }

        // Request account access if needed
        await window.ethereum.request({ method: 'eth_requestAccounts' });

        // Create a provider and signer
        provider = new ethers.providers.Web3Provider(window.ethereum);
        const signer = provider.getSigner();
        contract = new Contract(contractAddress, contractABI, signer);

        console.log('Available functions:', Object.keys(contract));
        console.log("New contract instance:", contract);
    } catch (error) {
        console.error('Unable to connect:', error);
        throw new Error('Unable to connect');
    }
};

init(); // Call the async function

// Helper function to send transactions
const sendTransaction = async (transactionFunction: (...args: any[]) => Promise<any>, ...args: any[]): Promise<string> => {
    if (!contract) {
        throw new Error('Contract is not initialized');
    }
    try {
        const txResponse = await transactionFunction(...args);
        const receipt = await txResponse.wait();
        return receipt.transactionHash;
    } catch (error) {
        console.error('Transaction error:', error);
        throw error;
    }
};

// Function to get the role of a specific address
export const getRole = async (address: string): Promise<string> => {
    if (!contract) {
        throw new Error('Contract is not initialized');
    }

    try {
        const admin: string = await contract.admin();
        console.log("Admin address:", admin);

        if (admin && admin.toLowerCase() === address.toLowerCase()) {
            return 'Admin';
        }

        const isSenior: boolean = await contract.seniors(address);
        if (isSenior) {
            return 'Senior';
        }

        const isWhale: boolean = await contract.whales(address);
        if (isWhale) {
            return 'Whale';
        }

        const isMember: boolean = await contract.members(address);
        if (isMember) {
            return 'Member';
        }

        return 'Guest'; // Default to Guest if none of the roles match
    } catch (error) {
        console.error('Error getting role:', error);
        return 'Unknown';
    }
};

// Utility function for joining as a member
export const joinAsMember = async () => {
    if (!contract) {
        throw new Error('Contract is not initialized');
    }

    try {
        const txResponse = await contract?.joinAsMember();
        console.log('Transaction sent:', txResponse);

        const receipt = await txResponse.wait();
        console.log('Transaction confirmed:', receipt);
        return receipt.transactionHash;
    } catch (error) {
        console.error('Error joining as member:', error);
        throw error;
    }
};

// Get agCoin balance of an address
export const getBalance = async (address: string): Promise<number> => {
    if (!contract) {
        throw new Error('Contract is not initialized');
    }

    try {
        const balance: string = await contract.agCoinBalance(address);
        return parseFloat(ethers.utils.formatUnits(balance, 'ether')); // Adjust the unit as needed
    } catch (error) {
        console.error('Error getting balance:', error);
        return 0;
    }
};

// Propose a new core value (Law 3)
export const proposeCoreValue = async (value: string): Promise<string> => {
    if (!contract) {
        throw new Error("Contract not initialized!");
    }
    return sendTransaction(contract.proposeCoreValue, value);
};

// Accept a proposed core value (Law 4)
export const acceptCoreValue = async (value: string): Promise<string> => {
    return sendTransaction(contract?.acceptCoreValue, value);
};

// Revoke a member's role (Law 5)
export const revokeMember = async (memberAddress: string): Promise<string> => {
    if (!contract) throw new Error("Contract not initialized!");
    return sendTransaction(contract.revokeMember, memberAddress);
};

// Reinstate a previously revoked member (Law 7)
export const reinstateMember = async (memberAddress: string): Promise<string> => {
    return sendTransaction(contract?.reinstateMember, memberAddress);
};

// Finalize law activation (Law 10)
export const finalizeLaw = async (lawId: string, blockDelay: number): Promise<string> => {
    if (!contract) {
        throw new Error("Contract not initialized!");
    }

    return sendTransaction(contract.finalizeLaw, lawId, blockDelay);
};

// Propose a new value for agDAO governance (Member proposal)
export const proposeNewValue = async (newValue: string): Promise<string> => {
    return sendTransaction(contract?.proposeNewValue, newValue);
};
