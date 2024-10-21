"use client";

import React, { useState, useEffect } from "react";
import AdminDashboard from "@/components/shared/AdminActions";
import MemberActions from "@/components/shared/MemberActions";
import WhaleActions from "@/components/shared/WhaleActions";
import SeniorActions from "@/components/shared/SeniorActions";
import { getRole } from "@/blockChainUtils/blockChainUtils";
import { ethers } from "ethers";
import AdminActions from "@/components/shared/AdminActions";
import JoinAsMember from "@/components/shared/JoinAsMember";
import ConnectWallet from "@/components/shared/ConnectWallet";
import { Button } from "@/components/ui/button";

type Role = "Admin" | "Member" | "Whale" | "Senior" | "Guest";

// Connect to Ethereum provider (MetaMask)
const getSigner = async () => {
    if (typeof window.ethereum !== "undefined") {
        try {
            // Request account access if needed
            await window.ethereum.request({ method: "eth_requestAccounts" });

            // Get the provider (MetaMask)
            const provider = new ethers.providers.Web3Provider(window.ethereum);

            // Get the signer (the user's wallet)
            const signer = provider.getSigner();
            const network = await provider.getNetwork();
            console.log("Connected to network:", network.name);

            return signer;
        } catch (error) {
            console.error("Error connecting to MetaMask", error);
            return null;
        }
    } else {
        console.error("Ethereum provider (MetaMask) not found.");
        return null;
    }
};

const DashboardPage: React.FC = () => {
    const [role, setRole] = useState<string>(""); // Role can be Admin, Member, Whale, Senior, Guest
    const [hasRoles, setHasRoles] = useState<Role[]>(["Guest"]);
    const [admin, setAdmin] = useState<boolean>(false);  
    const [senior, setSenior] = useState<boolean>(false);  ;  
    const [whale, setWhale] = useState<boolean>(false);  
    const [member, setMember] = useState<boolean>(false);  
    const [guest, setGuest] = useState<boolean>(false);  
    const [mode, setMode] = useState<"Values"|"Actions"|"Proposals">("Actions");  
    const [loading, setLoading] = useState<boolean>(true);
    const [error, setError] = useState<string | null>(null); // State for errors

    console.log({
        admin, 
        senior, 
        whale, 
        member, 
        guest
    })

    useEffect(() => {
        const fetchRole = async () => {
            try {
                const signer = await getSigner();
                if (signer) {
                    const userAddress = await signer.getAddress();
                    console.log("User Address:", userAddress);

                    // NB: getRole needs to fetch MULTIPLE ROLES. 
                    // see the hasRole array above. 
                    const role = await getRole(userAddress); // Fetch role using blockchain logic
                    console.log("Fetched role:", role);

                    if (!role) {
                        setRole("Guest"); // Set default role if no role is found
                    } else {
                        setRole(role);
                    }
                } else {
                    setRole("Guest");
                }
            } catch (err) {
                console.error("Error fetching role:", err);
                setError("Unable to fetch role. Please try again later.");
                setRole("Guest");
            } finally {
                setLoading(false);
            }
        };

        fetchRole();
    }, []);

    if (loading) {
        return (
            <div className="flex justify-center items-center h-screen">
                <div className="text-lg">Loading...</div>
            </div>
        );
    }

    if (error) {
        return (
            <div className="flex justify-center items-center h-screen">
                <div className="text-lg text-red-500">{error}</div>
            </div>
        );
    }

    return (
        <div className="p-6 bg-gray-100 min-h-screen">
            <h1 className="text-3xl font-bold text-center mb-6">Welcome to AgDAO</h1>
            <h2 className="text-2xl font-semibold mb-4 text-center">Dashboard</h2>
            <div className="flex justify-end mb-4">
                <ConnectWallet />
            </div>
            <div className="flex flex-row gap-2 p-1">
                <button 
                    className="w-full bg-red-400 border-2 aria-pressed:border-red-700 hover:bg-red-500 text-white font-bold py-2 px-4 aria-selected:opacity-100 opacity-50 rounded-lg"
                    onClick={() => setAdmin(!admin)}
                    aria-selected={hasRoles.includes("Admin")}
                    aria-pressed={admin}
                    >
                    Admin
                </button>
                <button className="w-full bg-amber-400 border-2 aria-pressed:border-amber-700 hover:bg-amber-500 text-white font-bold py-2 px-4 aria-selected:opacity-100 opacity-50 rounded-lg"
                    onClick={() => setSenior(!senior)}
                    aria-selected={hasRoles.includes("Senior")}
                    aria-pressed={senior}
                    >
                    Senior
                </button>
                <button className="w-full bg-emerald-400 border-2 aria-pressed:border-emerald-700 hover:bg-emerald-500 text-white font-bold py-2 px-4 aria-selected:opacity-100 opacity-50 rounded-lg"
                    onClick={() => setWhale(!whale)}
                    aria-selected={hasRoles.includes("Whale")}
                    aria-pressed={whale}
                    >
                    Whale
                </button>
                <button className="w-full bg-blue-400 border-2 aria-pressed:border-blue-700 hover:bg-blue-500 text-white font-bold py-2 px-4 aria-selected:opacity-100 opacity-50 rounded-lg"
                    onClick={() => setMember(!member)}
                    aria-selected={hasRoles.includes("Member")}
                    aria-pressed={member}
                    >
                    Member
                </button>
                <button className="w-full bg-purple-400 border-2 aria-pressed:border-purple-700 hover:bg-purple-500 text-white font-bold py-2 px-4 aria-selected:opacity-100 opacity-50 rounded-lg"
                    onClick={() => setGuest(!guest)}
                    aria-selected={hasRoles.includes("Guest")}
                    aria-pressed={guest}
                    >
                    Guest
                </button>
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
                    {/* {role === "Guest" && <GuestActions />} */}
                    {/* {role === "Guest" && (
                        <p className="text-gray-600">You do not have any role assigned. Please contact support.</p>
                    )} */}
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
    );
};

export default DashboardPage;
