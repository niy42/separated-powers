"use client";

import React, { useState, useEffect } from "react";
import AdminDashboard from "@/components/actions/AdminActions";
import MemberActions from "@/components/actions/MemberActions";
import WhaleActions from "@/components/actions/WhaleActions";
import SeniorActions from "@/components/actions/SeniorActions";
import GuestActions from "@/components/actions/GuestActions";
import { getRole } from "@/blockChainUtils/blockChainUtils";
import { ethers } from "ethers";
import AdminActions from "@/components/actions/AdminActions";
import ConnectWallet from "@/components/shared/ConnectWallet";
import { usePrivy, useWallets } from "@privy-io/react-auth";
import { Role } from "@/context/types";
import { useRoles } from "@/hooks/useRoles";

const DashboardPage: React.FC = () => {
    const [role, setRole] = useState<string>(""); // Role can be Admin, Member, Whale, Senior, Guest
    const [admin, setAdmin] = useState<boolean>(false);  
    const [senior, setSenior] = useState<boolean>(false);  ;  
    const [whale, setWhale] = useState<boolean>(false);  
    const [member, setMember] = useState<boolean>(false);  
    const [guest, setGuest] = useState<boolean>(false);  
    const [mode, setMode] = useState<"Values"|"Actions"|"Proposals">("Actions");  
    const [loading, setLoading] = useState<boolean>(true);
    // const [error, setError] = useState<string | null>(null); // State for errors
    const {wallets } = useWallets();
    const wallet = wallets[0];
    const {status, error, roles, fetchRoles} = useRoles();
    const {ready, authenticated, login} = usePrivy();
    new ethers.providers.AlchemyProvider("optimism-goerli", process.env.NEXT_PUBLIC_ALCHEMY_KEY);

    useEffect(() => {
        if (ready && wallet && status == "idle") {
            console.log("fetch roles triggered")
            fetchRoles(wallet);
        }
    }, [status, ready, wallet])

    console.log({status, error, roles});
    console.log({ready, authenticated});

    return (
        <section>
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

        <div className="p-6 bg-gray-100 min-h-screen">
            <h1 className="text-3xl font-bold text-center mb-6">Welcome to AgDAO</h1>
            <h2 className="text-2xl font-semibold mb-4 text-center">Dashboard</h2>
            <div className="flex justify-end mb-4">
            
            <div className="bg-gradient-to-r from-blue-400 to-blue-600 p-4 rounded-lg hover:from-blue-500 hover:to-blue-700 shadow-lg z-10 cursor-pointer transition duration-200">
                {ready && wallet && authenticated ? (
                    <p className="text-white text-lg font-semibold">
                        Wallet Connected: {wallet.address.slice(0, 5)}...{wallet.address.slice(-4)}
                    </p>
                ) : (
                    <button className="text-white text-lg font-semibold"
                        onClick={() => login()}
                    >
                        Please connect your wallet
                    </button>
                )}
            </div>

            </div>
            
            <div className="flex flex-row my-6">
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

            <div className="flex flex-row gap-2 p-1">
                <button 
                    className="w-full bg-red-400 border-2 aria-pressed:border-red-700 hover:bg-red-500 text-white font-bold py-2 px-4 aria-selected:opacity-100 opacity-50 rounded-lg"
                    onClick={() => setAdmin(!admin)}
                    aria-selected={roles.includes(0n)}
                    aria-pressed={admin}
                    >
                    Admin
                </button>
                <button className="w-full bg-amber-400 border-2 aria-pressed:border-amber-700 hover:bg-amber-500 text-white font-bold py-2 px-4 aria-selected:opacity-100 opacity-50 rounded-lg"
                    onClick={() => setSenior(!senior)}
                    aria-selected={roles.includes(1n)}
                    aria-pressed={senior}
                    >
                    Senior
                </button>
                <button className="w-full bg-emerald-400 border-2 aria-pressed:border-emerald-700 hover:bg-emerald-500 text-white font-bold py-2 px-4 aria-selected:opacity-100 opacity-50 rounded-lg"
                    onClick={() => setWhale(!whale)}
                    aria-selected={roles.includes(2n)}
                    aria-pressed={whale}
                    >
                    Whale
                </button>
                <button className="w-full bg-blue-400 border-2 aria-pressed:border-blue-700 hover:bg-blue-500 text-white font-bold py-2 px-4 aria-selected:opacity-100 opacity-50 rounded-lg"
                    onClick={() => setMember(!member)}
                    aria-selected={roles.includes(3n)}
                    aria-pressed={member}
                    >
                    Member
                </button>
                <button className="w-full bg-purple-400 border-2 aria-pressed:border-purple-700 hover:bg-purple-500 text-white font-bold py-2 px-4 aria-selected:opacity-100 opacity-50 rounded-lg"
                    onClick={() => setGuest(!guest)}
                    aria-selected={roles.includes(4n)}
                    aria-pressed={guest}
                    >
                    Guest
                </button>
            </div>



            {

            mode == "Values" ? 
                <div className="bg-white shadow-lg rounded-lg p-6 m-1">
                    A list of the currently accepted 'core values' of the DAO go here. (There is no selection by role for this tab.)
                </div>
            :
            mode == "Actions" ?
                <div className="bg-white shadow-lg rounded-lg p-6 m-1">
                    {admin === true ? <AdminActions /> : null}
                    {senior === true ? <SeniorActions /> : null}
                    {whale === true ? <WhaleActions /> : null}
                    {member === true ? <MemberActions /> : null}
                    {guest === true ? <GuestActions />  : null}
                </div>
            :
            mode == "Proposals" ?
            <div className="bg-white shadow-lg rounded-lg p-6 m-1">
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
                <div className="text-lg text-green-900">Idling...</div>
            </div>
        }
        </section>
    );
};

export default DashboardPage;
