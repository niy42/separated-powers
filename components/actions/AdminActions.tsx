"use client"

import React, { useState } from 'react';
// import { finalizeLaw } from '../blockChainUtils/blockchainUtils';
import { finalizeLaw } from '@/blockChainUtils/blockChainUtils';

interface AdminActionsProps {
    adminAddress: string;
}

const AdminActions: React.FC = () => {
    const [lawId, setLawId] = useState<string>('');
    const [blockDelay, setBlockDelay] = useState<number>(0);
    const [message, setMessage] = useState<string>('');

    const handleFinalizeLaw = async () => {
        try {
            const result = await finalizeLaw(lawId, blockDelay);
            setMessage(`Law finalized successfully: ${result}`);
            setLawId('');
            setBlockDelay(0);
        } catch (error) {
            console.error('Error finalizing law:', error);
            setMessage('Failed to finalize law.');
        }
    };

    return (
        <div>
            <h3>Admin Actions</h3>
            <div>
                <h4>Finalize Law</h4>
                <input
                    type="text"
                    value={lawId}
                    onChange={(e) => setLawId(e.target.value)}
                    placeholder="Enter law ID"
                />
                <input
                    type="number"
                    value={blockDelay}
                    onChange={(e) => setBlockDelay(Number(e.target.value))}
                    placeholder="Enter block delay (in blocks)"
                />
                <button onClick={handleFinalizeLaw}>Finalize Law</button>
            </div>
            {message && <p>{message}</p>}
        </div>
    );
};

export default AdminActions;
