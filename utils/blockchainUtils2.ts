import Web3 from 'web3';
import agContract from './agDAOCoinABI.json'
//import agContract from './agDAOABI.json';

// Initialize Web3 and the contract
// agDAO: 0x0438Cd38B03C5Bd0fd8091eF8e608A26707C93AF
// AgDAO_coin: 0x86D50D642e15CAA3C7C11806adad4fA17c53Ba55
const { abi: agDAOAbi } = agContract;
const web3 = new Web3(Web3.givenProvider || 'http://localhost:8545');
const contractAddress: string = '0x86D50D642e15CAA3C7C11806adad4fA17c53Ba55'; // Replace with actual contract address
const contract = new web3.eth.Contract(agDAOAbi, contractAddress);
console.log("contract: ", contract);

// Utility functions for interacting with the smart contract

// Get the role of an address
export const getRole = async (address: string): Promise<string> => {
    try {
        const admin: string = await contract.methods.admin().call();
        console.log("Admin address:", admin);

        if (admin && admin.toLowerCase() === address.toLowerCase()) {
            console.log("Role: Admin");
            return 'Admin';
        }

        const isSenior = await contract.methods.seniors(address).call();
        console.log("Senior status:", isSenior);
        if (isSenior) {
            return 'Senior';
        }

        const isWhale = await contract.methods.whales(address).call();
        console.log("Whale status:", isWhale);
        if (isWhale) {
            console.log("Whale!");
            return 'Whale';
        }

        const isMember = await contract.methods.members(address).call();
        console.log("Member status:", isMember);
        if (isMember) {
            console.log('Member');
            return 'Member';
        }

        return 'Guest'; // Default to Guest if none of the roles match
    } catch (error) {
        console.error('Error getting role:', error);
        return 'Unknown';
    }
};


// Get agCoin balance of an address
export const getBalance = async (address: string): Promise<number> => {
    try {
        const balance: string = await contract.methods.agCoinBalance(address).call();
        return parseFloat(web3.utils.fromWei(balance, 'ether'));
    } catch (error) {
        console.error('Error getting balance:', error);
        return 0;
    }
};

// Propose a new core value (Law 3)
export const proposeCoreValue = async (value: string, address: string): Promise<string> => {
    try {
        const result = await contract.methods.proposeCoreValue(value).send({ from: address });
        return result.transactionHash;
    } catch (error) {
        console.error('Error proposing new value:', error);
        throw error;
    }
};

// Accept a proposed core value (Law 4)
export const acceptCoreValue = async (value: string, address: string): Promise<string> => {
    try {
        const result = await contract.methods.acceptCoreValue(value).send({ from: address });
        return result.transactionHash;
    } catch (error) {
        console.error('Error accepting core value:', error);
        throw error;
    }
};

// Revoke a member's role (Law 5)
export const revokeMember = async (memberAddress: string, address: string): Promise<string> => {
    try {
        const result = await contract.methods.revokeMember(memberAddress).send({ from: address });
        return result.transactionHash;
    } catch (error) {
        console.error('Error revoking member:', error);
        throw error;
    }
};

// Reinstate a previously revoked member (Law 7)
export const reinstateMember = async (memberAddress: string, address: string): Promise<string> => {
    try {
        const result = await contract.methods.reinstateMember(memberAddress).send({ from: address });
        return result.transactionHash;
    } catch (error) {
        console.error('Error reinstating member:', error);
        throw error;
    }
};

// Finalize law activation (Law 10)
export const finalizeLaw = async (lawId: string, blockDelay: number, adminAddress: string): Promise<string> => {
    try {
        const result = await contract.methods.finalizeLaw(lawId, blockDelay).send({ from: adminAddress });
        return result.transactionHash;
    } catch (error) {
        console.error('Error finalizing law:', error);
        throw error;
    }
};

// Propose a new value for agDAO governance (Member proposal)
export const proposeNewValue = async (newValue: string, userAddress: string): Promise<string> => {
    try {
        const result = await contract.methods.proposeNewValue(newValue).send({ from: userAddress });
        return result.transactionHash;
    } catch (error) {
        console.error('Error proposing new value:', error);
        throw error;
    }
};
