"use client"

import React, { useState } from 'react';
import { useActionsProps } from '@/context/types';
import { useActions } from '@/hooks/useActions';
import { ethers } from 'ethers';

const WhaleActions: React.FC<useActionsProps> = ({wallet, disabled}: useActionsProps ) => {
    const [addressLaw, setAddressLaw] = useState<`0x${string}`>('0x0');
    const [toInclude, setToInclude] = useState<boolean>(true);
    const [newValue, setNewValue] = useState<string>('');
    const [memberToRevoke, setMemberToRevoke] = useState<`0x${string}`>('0x0');
    const [description, setDescription] = useState<string>('');
    const {status, error, law, propose, execute} = useActions(); 
    const abiCoder = new ethers.utils.AbiCoder();

    const handleAcceptCoreValue = async () => {
        const lawCalldata: string = abiCoder.encode(["bytes"], [newValue]);
        propose(
            wallet, 
            "0x0", // = Member_proposeCoreValue
            lawCalldata as `0x${string}`,
            description
        )
    };

    const handleProposeLaw = async () => {
        const lawCalldata: string = abiCoder.encode(["address", "bool"], [addressLaw, toInclude]);
        propose(
            wallet, 
            "0x0", // = Member_assignWhale
            lawCalldata as `0x${string}`,
            description
        )
    };

    // 
    const handleRevokeMember = async () => {
        const lawCalldata: string = abiCoder.encode(["address"], [memberToRevoke]);
        propose(
            wallet, 
            "0x0", // = Member_proposeCoreValue
            lawCalldata as `0x${string}`,
            description
        )
    };

    return (
        <>
        {/* AcceptCoreValue */}
        <div 
            className="bg-gradient-to-r from-emerald-300 to-emerald-600 p-4 px-6 rounded-lg shadow-lg border-2 border-emerald-600 opacity-30 aria-selected:opacity-100"
            aria-selected={disabled}
            >
            <h4 className='text-white text-lg font-semibold text-center'>
                Accept proposed core value
            </h4>
            <p className='text-white text-center mb-4'>
                Following an accepted proposal by members, whales can vote to accept a new core value to AgDao. 
            </p>
                <input
                    type="text"
                    value={newValue}
                    onChange={(e) => setNewValue(e.target.value)}
                    placeholder="Enter the new value to be accepted (max length 30 characters)."
                    maxLength={30}
                    className="border border-white rounded-lg p-2 mb-4 w-full"
                />
                <input
                    type="text"
                    value={description}
                    onChange={(e) => setDescription(e.target.value)}
                    placeholder="Enter the original description of the proposal to add a new core value." 
                    maxLength={35}
                    className="border border-white rounded-lg p-2 mb-4 w-full"
                />
                <div className="flex flex-row justify-start mt-6">
                    <button
                        onClick={handleAcceptCoreValue}
                        className="w-fit bg-white text-emerald-600 font-semibold px-4 py-2 rounded-lg hover:bg-blue-200  disabled:hover:bg-white transition duration-100"
                        disabled 
                    >
                        Propose to add new value to agDao
                    </button>
                </div>
        </div>

        {/* ProposeLaw */}
        <div 
            className="bg-gradient-to-r from-emerald-300 to-emerald-600 p-4 px-6 rounded-lg shadow-lg border-2 border-emerald-600 opacity-30 aria-selected:opacity-100"
            aria-selected={disabled}
        >
            <h4 className='text-white text-lg font-semibold text-center'>
                Propose to (De-)Activate Law
            </h4>
            <p className='text-white text-center mb-4'>
                Whales can propose to active or deactivate laws that govern AgDAO. 
            </p>
                <input
                    type="text"
                    value={addressLaw}
                    onChange={(e) => setAddressLaw(e.target.value as `0x${string}`)}
                    placeholder="Enter the address of the law to be (de-)activated."
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
                <div className="flex flex-row justify-center mb-4">
                    <button
                        onClick={() => setToInclude(!toInclude)}
                        className="w-fit bg-white text-slate-700 px-4 py-2 rounded-lg hover:bg-blue-200 transition duration-100"
                    >
                        {
                            toInclude ? 'This is a new law that needs to be activated' : 'This is an existing law that needs to be deactivated'
                        }
                    </button>
                </div>

                <div className="flex flex-row justify-start mt-6">
                    <button
                        onClick={handleProposeLaw}
                        className="w-fit bg-white text-emerald-600 font-semibold px-4 py-2 rounded-lg hover:bg-blue-200 disabled:hover:bg-white transition duration-100"
                        disabled
                    >
                        {`Propose to ${toInclude ? 'activate' : 'deactivate'} law`}
                    </button>
                </div>
        </div>
        
        {/* RevokeMember */}
        <div 
            className="bg-gradient-to-r from-emerald-300 to-emerald-600 p-4 px-6 rounded-lg shadow-lg border-2 border-emerald-600 opacity-30 aria-selected:opacity-100"
            aria-selected={disabled}
        >
            <h4 className='text-white text-lg font-semibold text-center'>
                Revoke Member
            </h4>
            <p className='text-white text-center mb-4'>
                Whales can vote to blacklist an account and revoke its member role.
            </p>
                <input
                    type="text"
                    value={memberToRevoke}
                    onChange={(e) => setMemberToRevoke(e.target.value as `0x${string}`)}
                    placeholder="Enter proposal ID through which whales revoked he member."
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
                        onClick={handleRevokeMember}
                        className="w-fit bg-white text-emerald-600 font-semibold px-4 py-2 rounded-lg hover:bg-blue-200 disabled:hover:bg-white transition duration-100"
                        disabled 
                    >
                        Propose to blacklist and revoke member
                    </button>
                </div>
        </div>
        </>
    );
};

export default WhaleActions;
