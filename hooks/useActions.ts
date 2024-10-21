import { useCallback, useEffect, useRef, useState } from "react";
import { agDaoAbi } from "../context/abi";
import { Status } from "../context/types"
import { ConnectedWallet } from "@privy-io/react-auth";
import { Contract } from 'ethers';

const contractAddress = '0xe55DbF3B724fc6a590630C94f5f63C976880235a'; // The contract address of the core DAO contract

export let contract: Contract | undefined;

export const useActions = () => {
  const [status, setStatus ] = useState<Status>("idle")
  const [law, setLaw ] = useState<`0x${string}` | undefined>()
  const [error, setError] = useState<any | null>(null)

  const propose = useCallback( 
    async (
      wallet: ConnectedWallet, 
      targetLaw: `0x${string}`,
      lawCalldata: `0x${string}`,
      description: string
    ) => {
        setStatus("loading")
        setLaw(targetLaw)
        try {
          const provider = await wallet.getEthersProvider();
          const signer = provider.getSigner();
          contract = new Contract(contractAddress, agDaoAbi, signer);

          if (contract) { 
            const txResponse = await contract.execute(targetLaw, lawCalldata, description);
            console.log('Transaction sent:', txResponse);
    
            const receipt = await txResponse.wait();
            console.log('Transaction confirmed:', receipt);
            return receipt.transactionHash;
          }
        } catch (error) {
            setStatus("error") 
            setError(error)
        }
        setStatus("success")
        setLaw(undefined)
  }, [ ])

  const cancel = useCallback( 
    async (
      wallet: ConnectedWallet, 
      targetLaw: `0x${string}`,
      lawCalldata: `0x${string}`,
      descriptionHash: `0x${string}`
    ) => {
        setStatus("loading")
        setLaw(targetLaw)
        try {
          const provider = await wallet.getEthersProvider();
          const signer = provider.getSigner();
          contract = new Contract(contractAddress, agDaoAbi, signer);

          if (contract) { 
            const txResponse = await contract.cancel(targetLaw, lawCalldata, descriptionHash);
            console.log('Transaction sent:', txResponse);
    
            const receipt = await txResponse.wait();
            console.log('Transaction confirmed:', receipt);
            return receipt.transactionHash;
          }
        } catch (error) {
            setStatus("error") 
            setError(error)
        }
        setStatus("success")
        setLaw(undefined)
  }, [ ])

  const execute = useCallback( 
    async (
      wallet: ConnectedWallet, 
      targetLaw: `0x${string}`,
      lawCalldata: `0x${string}`,
      descriptionHash: `0x${string}`
    ) => {
        setStatus("loading")
        setLaw(targetLaw)
        try {
          const provider = await wallet.getEthersProvider();
          const signer = provider.getSigner();
          contract = new Contract(contractAddress, agDaoAbi, signer);

          if (contract) { 
            const txResponse = await contract.execute(targetLaw, lawCalldata, descriptionHash);
            console.log('Transaction sent:', txResponse);
    
            const receipt = await txResponse.wait();
            console.log('Transaction confirmed:', receipt);
            return receipt.transactionHash;
          }
        } catch (error) {
            setStatus("error") 
            setError(error)
        }
        setStatus("success")
        setLaw(undefined)
  }, [ ])

  // note: I did not implement castVoteWithReason -- to much work for now. 
  const castVote = useCallback( 
    async (
      wallet: ConnectedWallet, 
      proposalId: bigint,
      support: bigint 
    ) => {
        setStatus("loading")
        setLaw("0x01") // note: a dummy value to signify cast vote 
        try {
          const provider = await wallet.getEthersProvider();
          const signer = provider.getSigner();
          contract = new Contract(contractAddress, agDaoAbi, signer);

          if (contract) { 
            const txResponse = await contract.castVote(proposalId, support);
            console.log('Transaction sent:', txResponse);
    
            const receipt = await txResponse.wait();
            console.log('Transaction confirmed:', receipt);
            return receipt.transactionHash;
          }
        } catch (error) {
            setStatus("error") 
            setError(error)
        }
        setStatus("success")
        setLaw(undefined)
  }, [ ])

  return {status, error, law, propose, cancel, execute, castVote}
}