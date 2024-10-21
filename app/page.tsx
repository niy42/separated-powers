"use client";

import React, { useState, useEffect } from "react";
import MemberActions from "@/components/actions/MemberActions";
import WhaleActions from "@/components/actions/WhaleActions";
import SeniorActions from "@/components/actions/SeniorActions";
import GuestActions from "@/components/actions/GuestActions";
import { ethers } from "ethers";
import AdminActions from "@/components/actions/AdminActions";
import { ConnectedWallet, usePrivy, useWallets } from "@privy-io/react-auth";
import { useRoles } from "@/hooks/useRoles";
import { useStore } from "zustand";

const DashboardPage: React.FC = () => {
    const [admin, setAdmin] = useState<boolean>(false);  
    const [senior, setSenior] = useState<boolean>(false);  ;  
    const [whale, setWhale] = useState<boolean>(false);  
    const [member, setMember] = useState<boolean>(false);  
    const [guest, setGuest] = useState<boolean>(false);  
    const [mode, setMode] = useState<"Values"|"Actions"|"Proposals">("Actions");  

    const {wallets } = useWallets();
    const wallet = wallets[0];
    const {status, error, roles, fetchRoles} = useRoles();
    const {ready, authenticated, login} = usePrivy();
    // this seems odd, but it seems to be the only name supported by ethers.  
    new ethers.providers.AlchemyProvider("optimism-goerli", process.env.NEXT_PUBLIC_ALCHEMY_KEY);

    useEffect(() => {
        if (ready && wallet && status == "idle") fetchRoles(wallet);
    }, [status, ready, wallet])

    return (
        <section className="w-full">
        {
        status == 'loading' ? 
            <div className="flex justify-center items-center h-screen">
                <div className="text-lg">Loading...</div>
            </div>
        :
        status == 'error' ? 
            <div className="flex justify-center items-center h-screen">
                <div className="text-lg text-red-500"> Error. See the console for details.</div>
            </div>
        :
        ready == true  ?

        <div className="p-6 bg-gray-100 min-h-screen flex flex-col items-center w-screen">
            <h1 className="text-3xl font-bold text-center mb-2">Welcome to AgDAO</h1>
            <h2 className="text-lg mb-4 text-center">A decentralised system of checks and balances for funding aligned accounts</h2>
            <div className="flex flex-col justify-center mb-8 w-full items-center">
                <div className="bg-gray-400 py-2 px-8 rounded-lg hover:from-blue-500 hover:to-blue-700 shadow-lg z-10 cursor-pointer transition duration-200">
                    {ready && wallet && authenticated ? (
                        <p className="text-white">
                            Wallet Connected @{wallet.address.slice(0, 5)}...{wallet.address.slice(-4)}
                        </p>
                    ) : (
                        <button className="text-white text-lg font-semibold"
                            onClick={() => login()}
                        >
                            Please connect your wallet
                        </button>
                    )}
                </div>

                <div className="max-w-3xl bg-gray-200 text-center border border-gray-300 py-2 px-4 rounded-lg shadow-lg z-10 mt-6">
                    <h2 className="font-bold mb-4"> Goal: Fund projects that are ‘aligned’ with core values of the agDAO. </h2>
                    
                    <ul> 
                        <li>0. Anyone can become a community member of AgDao.</li>
                        <li>1. Community members are paid in agCoins for governance participation.</li>
                        <li>2. Community members can transfer agCoins to any address they want.</li> 
                        <li>3. Whales can revoke member roles of accounts that fund non-aligned addresses.</li>
                        <li>4. Members can challenge this decision and be reinstated.</li>
                        <li>5. Whales can propose new laws, senior can accept them, and the admin implements them.</li>
                    </ul>

                    <h2 className="font-bold mt-4"> See below for the concrete implementation of AgDAO </h2>
                </div>
            </div>
            
            <div className="flex flex-row mb-6 w-full">
                <button 
                    className="w-full font-bold font-xl text-center aria-selected:opacity-100 opacity-25 py-2 px-4"
                    onClick={() => setMode("Values")}
                    aria-selected={(mode == "Values")}
                > 
                    Values
                </button>
                <button
                    className="w-full font-bold font-xl text-center aria-selected:opacity-100 opacity-25 py-2 px-4"
                    onClick={() => setMode("Actions")}
                    aria-selected={(mode == "Actions")}
                >  
                    Actions
                </button>
                <button 
                    className="w-full font-bold font-xl text-center aria-selected:opacity-100 opacity-25 py-2 px-4"
                    onClick={() => setMode("Proposals")}
                    aria-selected={(mode == "Proposals")}
                > 
                    Proposals
                </button>
            </div> 

            <div className="flex flex-row gap-2 overflow-x-auto p-1 w-full">
                <button 
                    className="w-full bg-red-400 border-2 aria-pressed:border-red-700 hover:bg-red-500 text-white font-bold py-2 px-4 aria-selected:opacity-100 opacity-30 rounded-lg "
                    onClick={() => setAdmin(!admin)}
                    aria-selected={roles.includes(0n)}
                    aria-pressed={admin}
                    >
                    Admin
                </button>
                <button className="w-full bg-amber-400 border-2 aria-pressed:border-amber-700 hover:bg-amber-500 text-white font-bold py-2 px-4 aria-selected:opacity-100 opacity-30 rounded-lg "
                    onClick={() => setSenior(!senior)}
                    aria-selected={roles.includes(1n)}
                    aria-pressed={senior}
                    >
                    Senior
                </button>
                <button className="w-full bg-emerald-400 border-2 aria-pressed:border-emerald-700 hover:bg-emerald-500 text-white font-bold py-2 px-4 aria-selected:opacity-100 opacity-30 rounded-lg "
                    onClick={() => setWhale(!whale)}
                    aria-selected={roles.includes(2n)}
                    aria-pressed={whale}
                    >
                    Whale
                </button>
                <button className="w-full bg-blue-400 border-2 aria-pressed:border-blue-700 hover:bg-blue-500 text-white font-bold py-2 px-4 aria-selected:opacity-100 opacity-30 rounded-lg "
                    onClick={() => setMember(!member)}
                    aria-selected={roles.includes(3n)}
                    aria-pressed={member}
                    >
                    Member
                </button>
                <button className="w-full bg-purple-400 border-2 aria-pressed:border-purple-700 hover:bg-purple-500 text-white font-bold py-2 px-4 aria-selected:opacity-100 opacity-30 rounded-lg "
                    onClick={() => setGuest(!guest)}
                    aria-selected={roles.includes(4n)}
                    aria-pressed={guest}
                    >
                    Guest
                </button>
            </div>

            {
            mode == "Values" ? 
                <div className="bg-white shadow-lg rounded-lg p-6 m-1 w-full">
                    A list of the currently accepted 'core values' of the DAO go here. (There is no selection by role for this tab.)
                </div>
            :
            mode == "Actions" ?
                <div className="flex flex-col overflow-y-auto gap-4 bg-white shadow-lg rounded-lg p-6 m-1 w-full">
                    {admin === true ? <AdminActions wallet={wallet} disabled={roles.includes(0n) ? true : false}/> : null}
                    {senior === true ? <SeniorActions wallet={wallet} disabled={roles.includes(1n) ? true : false}/> : null}
                    {whale === true ? <WhaleActions wallet={wallet} disabled={roles.includes(2n) ? true : false} /> : null}
                    {member === true ? <MemberActions wallet={wallet} disabled={roles.includes(3n) ? true : false} /> : null}
                    {guest === true ? <GuestActions  wallet={wallet} disabled={roles.includes(4n) ? true : false} /> : null} 
                    {admin === false && senior === false && whale === false && member === false && guest === false ? 
                        <p className="text-gray-600 text-center italic">Please select a role.</p> : null
                    }
                </div>
            :
            mode == "Proposals" ?
            <div className="bg-white shadow-lg rounded-lg p-6 m-1 w-full">
                A list of currently active and completed proposals will go here. (These proposals should ALSO be selected by role, just as in the Actions tab)
            </div>
            :
            <div className="bg-white shadow-lg rounded-lg p-6 m-1">
                <p className="text-gray-600">Please select a mode.</p>
            </div>
            }
        </div>
        :
            <div className="flex justify-center items-center h-screen">
                <div className="text-lg text-green-900">...</div>
            </div>
        }
        </section>
    );
};

export default DashboardPage;
