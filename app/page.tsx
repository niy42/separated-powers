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
    const [loading, setLoading] = useState<boolean>(true);
    const [error, setError] = useState<string | null>(null); // State for errors

    useEffect(() => {
        const fetchRole = async () => {
            try {
                const signer = await getSigner();
                if (signer) {
                    const userAddress = await signer.getAddress();
                    console.log("User Address:", userAddress);

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

            <div className="mb-6">
                <JoinAsMember />
            </div>

            <div className="bg-white shadow-lg rounded-lg p-6">
                {role === "Admin" && <AdminActions />}
                {role === "Whale" && <WhaleActions />}
                {role === "Senior" && <SeniorActions />}
                {role === "Member" && <MemberActions />}
                {role === "Guest" && (
                    <p className="text-gray-600">You do not have any role assigned. Please contact support.</p>
                )}
            </div>
        </div>
    );
};

export default DashboardPage;
