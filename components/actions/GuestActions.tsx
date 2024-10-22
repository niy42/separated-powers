"use client"

import React, { useState } from 'react';
import { useActionsProps } from '@/context/types';
import { useActions } from '@/hooks/useActions';
import { ethers } from 'ethers';

const GuestActions: React.FC<useActionsProps> = ({wallet, disabled}: useActionsProps ) => {
    const [addressSenior, setAddressSenior] = useState<`0x${string}`>('0x0');
    const [revokeId, setRevokeId] = useState<string>('');
    const [description, setDescription] = useState<string>('');
    const {status, error, law, propose, execute} = useActions(); 
    const abiCoder = new ethers.utils.AbiCoder();

    console.log({status, error, law})

    const handleAssignRole = async () => {
        const lawCalldata: string = abiCoder.encode(["address"], [wallet.address]);
        const descriptionHash = ethers.utils.keccak256(ethers.utils.toUtf8Bytes("I request membership to agDAO."));
        execute(
            wallet, 
            "0xd2aBB3eb2E55a143c7CE4E7aC500701e5DA1fDE3", // = Member_assignRole
            lawCalldata as `0x${string}`,
            descriptionHash as `0x${string}`
        )
    };

    const handleChallengeRevoke = async () => {
        const descriptionHash = ethers.utils.keccak256(ethers.utils.toUtf8Bytes(description));
        // using revokeId, need to retrieve this data from the initial proposal! 
        const revokeDescriptionHash = '0x0'
        const revokeCalldata = '0x0'
        const lawCalldata: string = abiCoder.encode(["bytes32", "bytes"], [revokeDescriptionHash, revokeCalldata]);
        propose(
            wallet, 
            "0x0", // = Member_proposeCoreValue
            lawCalldata as `0x${string}`,
            description
        )
    };

    return (
        <>
        {/* AssignRole */}
        <div 
            className="bg-gradient-to-r from-purple-300 to-purple-600 p-4 px-6 rounded-lg shadow-lg border-2 border-purple-600 opacity-30 aria-selected:opacity-100"
            aria-selected={disabled}
        >
            <h4 className='text-white text-lg font-semibold text-center'>
                Claim Member Role
            </h4>
            <p className='text-white text-center mb-4'>
                Anyone can claim a member role. 
            </p>
                <div className="flex flex-row justify-center mt-6">
                    <button
                        onClick={handleAssignRole}
                        className="w-fit bg-white text-purple-600 font-semibold px-4 py-2 rounded-lg hover:bg-blue-200 disabled:hover:bg-white transition duration-100"
                        disabled = { false }
                    >
                        Claim member role
                    </button>
                </div>
        </div>
        
        {/* ChallengeRevoke */}
        <div 
            className="bg-gradient-to-r from-purple-300 to-purple-600 p-4 px-6 rounded-lg shadow-lg border-2 border-purple-600 opacity-30 aria-selected:opacity-100"
            aria-selected={disabled}
        >
            <h4 className='text-white text-lg font-semibold text-center'>
                Challenge Revoke Member Role
            </h4>
            <p className='text-white text-center mb-4'>
                If your member role has been revoked, you can create a challenge which allows seniors to vote on your reinstatement. 
            </p>
                <input
                    type="text"
                    value={addressSenior}
                    onChange={(e) => setRevokeId(e.target.value)}
                    placeholder="Enter proposal ID through which whales revoked your member role."
                    maxLength={100}
                    className="border border-white rounded-lg p-2 mb-4 w-full"
                />
                <input
                    type="text"
                    value={description}
                    onChange={(e) => setDescription(e.target.value)}
                    placeholder="Enter supporting statement." 
                    maxLength={35}
                    className="border border-white rounded-lg p-2 mb-4 w-full"
                />
                <div className="flex flex-row justify-start mt-6">
                    <button
                        onClick={handleChallengeRevoke}
                        className="w-fit bg-white text-purple-600 font-semibold px-4 py-2 rounded-lg hover:bg-blue-200 disabled:hover:bg-white transition duration-100"
                        disabled 
                    >
                        Challenge revoke (NB: this creates a proposal you need to accept) 
                    </button>
                </div>
        </div>
        </>
    );
};

export default GuestActions;
