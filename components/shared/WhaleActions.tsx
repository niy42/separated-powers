"use client"

import React, { useState } from 'react';
import { proposeCoreValue, acceptCoreValue, revokeMember } from '../../utils/blockchainUtils';

interface WhaleActionsProps {
    address: string;
}

const WhaleActions: React.FC = () => {
    const [newCoreValue, setNewCoreValue] = useState<string>('');
    const [memberAddress, setMemberAddress] = useState<string>('');
    const [message, setMessage] = useState<string>('');

    const handleProposeCoreValue = async () => {
        try {
            const result = await proposeCoreValue(newCoreValue);
            setMessage(`Core value proposed: ${result}`);
            setNewCoreValue('');
        } catch (error) {
            console.error('Error proposing core value:', error);
            setMessage('Failed to propose core value.');
        }
    };

    const handleAcceptCoreValue = async () => {
        try {
            const result = await acceptCoreValue(newCoreValue);
            setMessage(`Core value accepted: ${result}`);
            setNewCoreValue('');
        } catch (error) {
            console.error('Error accepting core value:', error);
            setMessage('Failed to accept core value.');
        }
    };

    const handleRevokeMember = async () => {
        try {
            const result = await revokeMember(memberAddress);
            setMessage(`Member revoked: ${result}`);
            setMemberAddress('');
        } catch (error) {
            console.error('Error revoking member:', error);
            setMessage('Failed to revoke member.');
        }
    };

    return (
        <div>
            <h3>Whale Actions</h3>
            <div>
                <h4>Propose Core Value</h4>
                <input
                    type="text"
                    value={newCoreValue}
                    onChange={(e) => setNewCoreValue(e.target.value)}
                    placeholder="Enter new core value"
                />
                <button onClick={handleProposeCoreValue}>Propose</button>
            </div>
            <div>
                <h4>Accept Core Value</h4>
                <input
                    type="text"
                    value={newCoreValue}
                    onChange={(e) => setNewCoreValue(e.target.value)}
                    placeholder="Enter core value to accept"
                />
                <button onClick={handleAcceptCoreValue}>Accept</button>
            </div>
            <div>
                <h4>Revoke Member</h4>
                <input
                    type="text"
                    value={memberAddress}
                    onChange={(e) => setMemberAddress(e.target.value)}
                    placeholder="Enter member address to revoke"
                />
                <button onClick={handleRevokeMember}>Revoke</button>
            </div>
            {message && <p>{message}</p>}
        </div>
    );
};

export default WhaleActions;
