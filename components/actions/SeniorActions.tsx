"use client"

import React, { useState } from 'react';
import { useActionsProps } from '@/context/types';
import { useActions } from '@/hooks/useActions';
import { ethers } from 'ethers';

const SeniorActions: React.FC<useActionsProps> = ({wallet, disabled}: useActionsProps ) => {
    const [addressLaw, setAddressLaw] = useState<`0x${string}`>('0x0');
    const [addressSenior, setAddressSenior] = useState<`0x${string}`>('0x0');
    const [revokeId, setRevokeId] = useState<string>('');
    const [description, setDescription] = useState<string>('');
    const [toInclude, setToInclude] = useState<boolean>(true);
    const {status, error, law, propose, execute} = useActions(); 
    const abiCoder = new ethers.utils.AbiCoder();

    const handleAcceptProposeLaw = async () => {
        const lawCalldata: string = abiCoder.encode(["address", "bool"], [addressLaw, toInclude]);
        propose(
            wallet, 
            "0x0", // = Member_proposeCoreValue
            lawCalldata as `0x${string}`,
            description
        )
    };

    const handleAssignRole = async () => {
        const lawCalldata: string = abiCoder.encode(["address"], [addressSenior]);
        propose(
            wallet, 
            "0x0", // = Member_assignWhale
            lawCalldata as `0x${string}`,
            description
        )
    };

    const handleReinstateMember = async () => {
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

    const handleRevokeRole = async () => {
        const lawCalldata: string = abiCoder.encode(["address"], [addressSenior]);
        propose(
            wallet, 
            "0x0", // = Member_assignWhale
            lawCalldata as `0x${string}`,
            description
        )
    };

    return (
        <>
        {/* AcceptProposeLaw */}
        <div 
            className="bg-gradient-to-r from-amber-300 to-amber-600 p-4 px-6 rounded-lg shadow-lg border-2 border-amber-600 opacity-30 aria-selected:opacity-100"
            aria-selected={disabled}
            >
            <h4 className='text-white text-lg font-semibold text-center'>
                Accept proposed law
            </h4>
            <p className='text-white text-center mb-4'>
                Following an accepted proposal by whales, Seniors can accept the proposed (in- or) exclusion of a law. 
            </p>
                <input
                    type="text"
                    value={addressLaw}
                    onChange={(e) => setAddressLaw(e.target.value as `0x${string}`)}
                    placeholder="Enter the address of the law."
                    maxLength={100}
                    className="border border-white rounded-lg p-2 mb-4 w-full"
                />
                <input
                    type="text"
                    value={description}
                    onChange={(e) => setDescription(e.target.value)}
                    placeholder="Enter the original description of the proposal to add a new law." 
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
                        onClick={handleAcceptProposeLaw}
                        className="w-fit bg-white text-amber-600 font-semibold px-4 py-2 rounded-lg hover:bg-blue-200  disabled:hover:bg-white transition duration-100"
                        disabled 
                        
                    >
                        {`Propose to ${toInclude ? 'activate' : 'deactivate'} law`}
                    </button>
                </div>
        </div>

        {/* AssignRole */}
        <div 
            className="bg-gradient-to-r from-amber-300 to-amber-600 p-4 px-6 rounded-lg shadow-lg border-2 border-amber-600 opacity-30 aria-selected:opacity-100"
            aria-selected={disabled}
        >
            <h4 className='text-white text-lg font-semibold text-center'>
                Assign a senior role to an account
            </h4>
            <p className='text-white text-center mb-4'>
                Seniors can assign a senior role to an account by majority vote. 
            </p>
                <input
                    type="text"
                    value={addressSenior}
                    onChange={(e) => setAddressSenior (e.target.value as `0x${string}`)}
                    placeholder="Enter the address of the account to be assign a senior role."
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
                        onClick={handleAssignRole}
                        className="w-fit bg-white text-amber-600 font-semibold px-4 py-2 rounded-lg hover:bg-blue-200 disabled:hover:bg-white transition duration-100"
                        disabled
                    >
                        Propose to assign senior role 
                    </button>
                </div>
        </div>
        
        {/* ReinstateMember */}
        <div 
            className="bg-gradient-to-r from-amber-300 to-amber-600 p-4 px-6 rounded-lg shadow-lg border-2 border-amber-600 opacity-30 aria-selected:opacity-100"
            aria-selected={disabled}
        >
            <h4 className='text-white text-lg font-semibold text-center'>
                Reinstate member
            </h4>
            <p className='text-white text-center mb-4'>
                Seniors can reinstate an account to a member role, following a challenge by this member. 
            </p>
                <input
                    type="text"
                    value={addressSenior}
                    onChange={(e) => setRevokeId(e.target.value)}
                    placeholder="Enter proposal ID through which whales revoked he member."
                    maxLength={100}
                    className="border border-white rounded-lg p-2 mb-4 w-full"
                />
                <input
                    type="text"
                    value={description}
                    onChange={(e) => setDescription(e.target.value)}
                    placeholder="Enter the exact supporting statement from the member challenge." 
                    maxLength={35}
                    className="border border-white rounded-lg p-2 mb-4 w-full"
                />
                <div className="flex flex-row justify-start mt-6">
                    <button
                        onClick={handleReinstateMember}
                        className="w-fit bg-white text-amber-600 font-semibold px-4 py-2 rounded-lg hover:bg-blue-200 disabled:hover:bg-white transition duration-100"
                        disabled 
                    >
                        Propose to reinstate member role 
                    </button>
                </div>
        </div>


        {/* RevokeRole */}
        <div 
            className="bg-gradient-to-r from-amber-300 to-amber-600 p-4 px-6 rounded-lg shadow-lg border-2 border-amber-600 opacity-30 aria-selected:opacity-100"
            aria-selected={disabled}>
            
            <h4 className='text-white text-lg font-semibold text-center'>
                Revoke senior role
            </h4>
            <p className='text-white text-center mb-4'>
                By large majority vote, seniors can revoke an account their senior role. 
            </p>
                <input
                    type="text"
                    value={addressSenior}
                    onChange={(e) => setAddressSenior (e.target.value as `0x${string}`)}
                    placeholder="Enter the address of the account to be revoked a senior role."
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
                        onClick={handleRevokeRole}
                        className="w-fit bg-white text-amber-600 font-semibold px-4 py-2 rounded-lg hover:bg-blue-200 disabled:hover:bg-white transition duration-100"
                        disabled 
                    >
                        Propose to revoke senior role 
                    </button>
                </div>
        </div>
        </>
    );
};

export default SeniorActions;
