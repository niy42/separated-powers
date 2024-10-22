"use client"

import React, { useState } from 'react';
import { useTheme } from '@/context/ThemeContext';
import { useActions } from '@/hooks/useActions';
import {ethers} from 'ethers';
import { useActionsProps } from '@/context/types';

// about encoding lawCalldata
// https://docs.ethers.org/v5/api/utils/abi/coder/
// abiCoder.encode([ "uint", "string" ], [ 1234, "Hello World" ]);

const MemberActions: React.FC<useActionsProps> = ({wallet, disabled}: useActionsProps ) => {
    const [newValue, setNewValue] = useState<string>('');
    const [whaleAddress, setWhaleAddress] = useState<`0x${string}`>('0x0');
    const [description, setDescription] = useState<string>('');
    const {status, error, law, propose, execute} = useActions(); 
    const abiCoder = new ethers.utils.AbiCoder();

    const handleProposeCoreValue = async () => {
        const lawCalldata: string = abiCoder.encode(["bytes"], [newValue]);
        propose(
            wallet, 
            "0x8508D5b9bA7F255F70E8022A8aFbDe72083773f8", // = Member_proposeCoreValue
            lawCalldata as `0x${string}`,
            description
        )
    };

    const handleAssignWhale = async () => {
        const descriptionHash = ethers.utils.keccak256(ethers.utils.toUtf8Bytes(description));
        const lawCalldata: string = abiCoder.encode(["address"], [whaleAddress]);
        execute(
            wallet, 
            "0x0", // = Member_assignWhale
            lawCalldata as `0x${string}`,
            descriptionHash as `0x${string}`
        )
    };
    
    return (
        <>
            <div className="bg-gradient-to-r from-blue-300 to-blue-600 p-4 px-6 rounded-lg shadow-lg border-2 border-blue-600 opacity-30 aria-selected:opacity-100"
            aria-selected={disabled}>
                <h4 className='text-white text-lg font-semibold text-center mb-4'>
                    Propose New Core Value for the AgDao
                </h4>
                <p className='text-white text-center mb-4'>
                    This decision will only pass if Seniors have accepted Whale's proposal. 
                </p>
                    <input
                        type="text"
                        value={newValue}
                        onChange={(e) => setNewValue(e.target.value)}
                        placeholder="Enter new value (max 30 characters)"
                        maxLength={30}
                        className="border border-white rounded-lg p-2 mb-4 w-full"
                    />
                    <input
                        type="text"
                        value={description}
                        onChange={(e) => setDescription(e.target.value)}
                        placeholder="Enter supporting message"
                        maxLength={100}
                        className="border border-white rounded-lg p-2 mb-4 w-full"
                    />
                    <div className="flex flex-row justify-start">
                        <button
                            onClick={handleProposeCoreValue}
                            className="w-fit bg-white text-blue-600 font-semibold px-4 py-2 rounded-lg hover:bg-blue-200 transition duration-100"
                        >
                            Propose Value
                        </button>
                    </div>
        
            </div>

            <div className="bg-gradient-to-r from-blue-300 to-blue-600 p-4 px-6 rounded-lg shadow-lg border-2 border-blue-600 opacity-30 aria-selected:opacity-100"
            aria-selected={disabled}>
                <h4 className='text-white text-lg font-semibold text-center mb-4'>
                    Assess an Account and Assign a whale Role 
                </h4>
                <p className='text-white text-center mb-4'>
                    If the account has more than one million Ag coins, it will be assigned a whale role. If it already is a whale and has fewer than one million Ag coins, it will be removed from the whale role.
                </p>
                    <input
                        type="text"
                        value={newValue}
                        onChange={(e) => setWhaleAddress(e.target.value as `0x${string}`)}
                        placeholder="Enter account address"
                        className="border border-white rounded-lg p-2 mb-4 w-full"
                    />
                    <input
                        type="text"
                        value={description}
                        onChange={(e) => setDescription(e.target.value)}
                        placeholder="Enter supporting message"
                        maxLength={100}
                        className="border border-white rounded-lg p-2 mb-4 w-full"
                    />
                    <div className="flex flex-row justify-start">
                        <button
                            onClick={handleAssignWhale}
                            className="w-fit bg-white text-blue-600 font-semibold px-4 py-2 rounded-lg hover:bg-blue-200 disabled:hover:bg-white transition duration-100"
                            disabled
                        >
                            Assess account
                        </button>
                    </div>
        
            </div>

        </>
    );
};

export default MemberActions;
