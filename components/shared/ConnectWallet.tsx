"use client"

import { useTheme } from '@/context/ThemeContext';
import { useState, useEffect } from 'react';
import Web3 from 'web3';

const ConnectWallet: React.FC = () => {
    const [connected, setConnected] = useState<boolean>(false);
    const { address, setAddress } = useTheme();

    // useEffect(() => {
    //     const connectWallet = async () => {
    //         if ((window as any)?.ethereum) {
    //             const web3 = new Web3((window as any)?.ethereum);
    //             try {
    //                 const accounts = await (window as any)?.ethereum.request({ method: 'eth_requestAccounts' });
    //                 setAddress(accounts[0]);
    //                 setConnected(true);
    //             } catch (error) {
    //                 console.error('Failed to connect wallet:', error);
    //             }
    //         }
    //     };
    //     connectWallet();
    // }, []);

    return (
        <div className="bg-gradient-to-r from-blue-400 to-blue-600 p-4 rounded-lg hover:from-blue-500 hover:to-blue-700 shadow-lg z-10 cursor-pointer transition duration-200">
            {connected && address ? (
                <p className="text-white text-lg font-semibold">
                    Wallet Connected: {address.slice(0, 5)}...{address.slice(-4)}
                </p>
            ) : (
                <p className="text-white text-lg font-semibold">
                    Please connect your wallet
                </p>
            )}
        </div>

    );
};

export default ConnectWallet;
