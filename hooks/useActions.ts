import { useCallback, useEffect, useRef, useState } from "react";
import { agDaoAbi } from "../context/abi";
import { Status } from "../context/types"
import { ConnectedWallet } from "@privy-io/react-auth";
import { Contract } from 'ethers';

const contractAddress = '0xe55DbF3B724fc6a590630C94f5f63C976880235a'; // Your contract address

export let contract: Contract | undefined;

export const useRoles = () => {
  const [status, setStatus ] = useState<Status>("idle")
  const [error, setError] = useState<any | null>(null)
  const [roles, setRoles] = useState<bigint[]>([]) 

  const fetchRoles = useCallback( 
    async (wallet: ConnectedWallet) => {
        setStatus("loading")
        try {
          const provider = await wallet.getEthersProvider();
          const signer = provider.getSigner();
          contract = new Contract(contractAddress, agDaoAbi, signer);
          console.log({contract})

          let role: bigint; 
          let allRoles: bigint[] = [0n, 1n, 2n, 3n]
          let hasRoles: bigint[] = [4n]

          if (contract) { 
              for await (role of allRoles) {
                const response = await contract.hasRoleSince(wallet.address, role)
                if (response != 0) hasRoles.push(role)
              }
              setRoles(hasRoles)
          }
        } catch (error) {
            setStatus("error") 
            setError(error)
        }
        setStatus("success")
  }, [ ])

  return {status, error, roles, fetchRoles }
}