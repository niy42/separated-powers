"use client"

import React, { useEffect, useState } from 'react';
import { joinAsMember } from '@/blockChainUtils/blockChainUtils';

const JoinAsMember = () => {
    const [loading, setLoading] = useState(false);
    const [message, setMessage] = useState('');

    const handleJoin = async () => {
        setLoading(true);
        setMessage('');

        try {
            const txHash = await joinAsMember();
            setMessage(`Successfully joined as a member! Transaction Hash: ${txHash}`);
        } catch (error) {
            setMessage('Failed to join as a member. Please try again.');
            console.error(error);
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="flex flex-col items-center justify-center bg-gradient-to-r from-purple-400 to-pink-500 p-6 rounded-lg shadow-lg text-center">
            <h2 className="text-2xl font-bold text-white mb-4">Join as a Member</h2>
            <button
                className="bg-white text-purple-600 hover:bg-purple-500 hover:text-white p-2 rounded-lg transition duration-200 flex items-center justify-center"
                onClick={handleJoin}
                disabled={loading}
            >
                {loading ? 'Joining...' : 'Click to join'}
            </button>
            {message && <p className="mt-4 text-white">{message}</p>}
        </div>

    );
};

export default JoinAsMember;
