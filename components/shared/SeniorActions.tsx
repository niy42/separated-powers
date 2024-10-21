"use client"

import React, { useState } from 'react';
import { reinstateMember } from '../../utils/blockchainUtils';



const SeniorActions: React.FC = () => {
    const [memberAddress, setMemberAddress] = useState<string>('');
    const [message, setMessage] = useState<string>('');

    const handleReinstateMember = async () => {
        try {
            const result = await reinstateMember(memberAddress);
            setMessage(`Member reinstated successfully: ${result}`);
            setMemberAddress('');
        } catch (error) {
            console.error('Error reinstating member:', error);
            setMessage('Failed to reinstate member.');
        }
    };

    return (
        <div>
            <h3>Senior Actions</h3>
            <div>
                <h4>Reinstate Expelled Member</h4>
                <input
                    type="text"
                    value={memberAddress}
                    onChange={(e) => setMemberAddress(e.target.value)}
                    placeholder="Enter expelled member address"
                />
                <button onClick={handleReinstateMember}>Reinstate Member</button>
            </div>
            {message && <p>{message}</p>}
        </div>
    );
};

export default SeniorActions;
