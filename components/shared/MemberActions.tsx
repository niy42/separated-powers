"use client"

import React, { useState } from 'react';
import { proposeNewValue, init, contract } from '@/blockChainUtils/blockChainUtils';
import { useTheme } from '@/context/ThemeContext';

const MemberActions: React.FC = () => {
    const [newValue, setNewValue] = useState<string>('');
    const [message, setMessage] = useState<string>('');
    const { address } = useTheme();

    const handleProposeNewValue = async () => {
        try {
            init();
            if (!address) {
                setMessage("Address is not available.");
                return;
            }

            const isMember = await contract?.members(address);
            if (isMember) {
                const result = await proposeNewValue(newValue);
                setMessage(`New value proposed successfully: ${result}`);
                setNewValue('');
            } else {
                setMessage("You are not a member.");
            }

        } catch (error: any) {
            console.error('Error proposing new value:', error);
            const parsedErrorMessage = (error as any)?.reason
                ? error?.reason.slice('execution reverted: '.length).slice(0, -1)
                : 'An unknown error occurred';
            setMessage(parsedErrorMessage);
        }
    };

    return (
        <div>
            <h3>Member Actions</h3>
            <div>
                <h4>Propose New Value</h4>
                <div className="bg-gradient-to-r from-purple-400 via-pink-500 to-red-500 p-6 rounded-lg shadow-lg">
                    <input
                        type="text"
                        value={newValue}
                        onChange={(e) => setNewValue(e.target.value)}
                        placeholder="Enter new value"
                        className="border border-white rounded-lg p-2 mb-4 w-full"
                    />
                    <button
                        onClick={handleProposeNewValue}
                        className="bg-white text-purple-600 font-semibold px-4 py-2 rounded-lg hover:bg-gray-200 transition duration-200"
                    >
                        Propose Value
                    </button>
                </div>

            </div>
            {message && <p>{message}</p>}
        </div>
    );
};

export default MemberActions;
