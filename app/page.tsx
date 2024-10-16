"use client"

import { useState } from "react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { motion, AnimatePresence } from "framer-motion"
import { CheckCircle, XCircle, AlertCircle, PlayCircle, User, Users } from "lucide-react"
import ThemeToggle from "@/components/shared/ThemeToggle"
import { useTheme } from "@/context/ThemeContext"

type Role = "A" | "B"
type ProposalStatus = "Proposed" | "Approved" | "Executed" | "Rejected"

interface Proposal {
    id: number
    description: string
    status: ProposalStatus
}

export default function DAOGovernance() {
    const [currentRole, setCurrentRole] = useState<Role>("A")
    const [proposals, setProposals] = useState<Proposal[]>([])
    const [newProposal, setNewProposal] = useState("")
    const { theme, setTheme } = useTheme();

    const proposeDecision = () => {
        if (currentRole === "A" && newProposal.trim() !== "") {
            const newId = proposals.length + 1
            setProposals([...proposals, { id: newId, description: newProposal, status: "Proposed" }])
            setNewProposal("")
        }
    }

    const approveDecision = (id: number) => {
        if (currentRole === "B") {
            setProposals(
                proposals.map((proposal) =>
                    proposal.id === id ? { ...proposal, status: "Approved" } : proposal
                )
            )
        }
    }

    const executeDecision = (id: number): void => {
        if (currentRole === "B") {
            setProposals(
                proposals.map((proposal) =>
                    proposal.id === id ? { ...proposal, status: "Executed" } : proposal
                )
            )
        }
    }

    const rejectDecision = (id: number) => {
        if (currentRole === "B") {
            setProposals(
                proposals.map((proposal) =>
                    proposal.id === id ? { ...proposal, status: "Rejected" } : proposal
                )
            )
        }
    }

    const getStatusColor = (status: ProposalStatus) => {
        switch (status) {
            case "Proposed":
                return "bg-yellow-100 text-yellow-800"
            case "Approved":
                return "bg-blue-100 text-blue-800"
            case "Executed":
                return "bg-green-100 text-green-800"
            case "Rejected":
                return "bg-red-100 text-red-800"
        }
    }

    const getStatusIcon = (status: ProposalStatus) => {
        switch (status) {
            case "Proposed":
                return <AlertCircle className="w-4 h-4" />
            case "Approved":
                return <CheckCircle className="w-4 h-4" />
            case "Executed":
                return <PlayCircle className="w-4 h-4" />
            case "Rejected":
                return <XCircle className="w-4 h-4" />
        }
    }

    return (
        <section>
            <Card className={`relative top-10 w-full bg-transparent max-w-4xl m-auto shadow-lg rounded-lg p-2 sm:p-6 ${theme === 'dark' ? "border-gray-700" : "border-gray-300"}`}>
                <CardHeader className="flex flex-col space-x-2">
                    <div className="flex justify-between items-center">

                        <p className="flex-auto">Logo</p>

                        <ThemeToggle currentTheme={theme} setTheme={setTheme} />
                    </div>
                    <div className="flex items-center justify-between max-md:space-x-8  ">

                        <div className="space-y-1 flex-grow">
                            <CardTitle className="text-lg sm:text-2xl lg:text-3xl font-extrabold text-center">DAO Governance System</CardTitle>
                            <CardDescription className="text-center">
                                A system with checks and balances for decentralized decision-making
                            </CardDescription>
                        </div>


                    </div>

                </CardHeader>
                <CardContent className="space-y-6">
                    <div className="flex flex-col sm:flex-row items-center justify-center sm:space-x-2 p-4 rounded-lg">
                        <Label htmlFor="role-select" className="text-sm font-medium dark:text-gray-200">
                            Current Role:
                        </Label>
                        <Select value={currentRole} onValueChange={(value: Role) => setCurrentRole(value)}>
                            <SelectTrigger id="role-select" className={`${theme === 'light' ? "border-gray-300" : "border-gray-700"} bg-inherit w-full sm:w-[250px] mt-2 sm:mt-0 outline-none focus:outline-none focus:ring-0`}>
                                <SelectValue placeholder="Select a role" />
                            </SelectTrigger>
                            <SelectContent className={`${theme === "dark" ? "bg-gray-700 border-gray-500" : ""}`}>
                                <SelectItem value="A">
                                    <div className="flex items-center">
                                        <User className="w-4 h-4 mr-2" />
                                        Role A (Proposer)
                                    </div>
                                </SelectItem>
                                <SelectItem value="B">
                                    <div className="flex items-center">
                                        <Users className="w-4 h-4 mr-2" />
                                        Role B (Approver/Executor)
                                    </div>
                                </SelectItem>
                            </SelectContent>
                        </Select>
                    </div>
                    {currentRole === "A" && (
                        <div className="flex flex-col focus:outline-none focus:ring-0 space-y-2 sm:flex-row sm:space-x-2 sm:space-y-0 items-center space-x-2">
                            <Input
                                placeholder="Enter new proposal"
                                value={newProposal}
                                onChange={(e) => setNewProposal(e.target.value)}
                                className={`flex-grow ${theme === 'dark' ? "border-gray-700" : "border-gray-300"} outline-transparent focus:outline-none focus-visible:ring-0 focus:ring-0`}
                            />
                            <Button onClick={proposeDecision} className="whitespace-nowrap w-full sm:w-auto">
                                Propose Decision
                            </Button>
                        </div>
                    )}
                    <div className="space-y-4">
                        <h3 className="text-lg font-semibold">Proposals</h3>
                        <AnimatePresence>
                            {proposals.map((proposal) => (
                                <motion.div
                                    key={proposal.id}
                                    initial={{ opacity: 0, y: 20 }}
                                    animate={{ opacity: 1, y: 0 }}
                                    exit={{ opacity: 0, y: -20 }}
                                    transition={{ duration: 0.3 }}
                                >
                                    <Card className={`${theme === "light" ? "" : "border-gray-700"} overflow-hidden shadow-sm bg-inherit transition-shadow hover:shadow-md`}>
                                        <CardContent className="p-4">
                                            <div className="flex justify-between items-center">
                                                <div className="space-y-2">
                                                    <p className="font-medium">{proposal.description}</p>
                                                    <div className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusColor(proposal.status)}`}>
                                                        {getStatusIcon(proposal.status)}
                                                        <span className="ml-1">{proposal.status}</span>
                                                    </div>
                                                </div>
                                                {currentRole === "B" && proposal.status === "Proposed" && (
                                                    <div className="space-y-4 lg:space-y-0 lg:space-x-2 flex flex-col items-center justify-end lg:justify-center lg:flex-row">
                                                        <Button onClick={() => approveDecision(proposal.id)} variant="outline" className={`${theme === "dark" ? "bg-gray-500 hover:bg-gray-600 hover:text-gray-200 border-gray-600" : "bg-green-300 hover:bg-green-400"} max-lg:w-16`} size="sm">
                                                            Approve
                                                        </Button>
                                                        <Button onClick={() => rejectDecision(proposal.id)} variant="destructive" size="sm" className="max-lg:w-16">
                                                            Reject
                                                        </Button>
                                                    </div>
                                                )}
                                                {currentRole === "B" && proposal.status === "Approved" && (
                                                    <Button onClick={() => executeDecision(proposal.id)} variant="default" size="sm">
                                                        Execute
                                                    </Button>
                                                )}
                                            </div>
                                        </CardContent>
                                    </Card>
                                </motion.div>
                            ))}
                        </AnimatePresence>
                    </div>
                </CardContent>
                <CardFooter className="flex justify-center">
                    <p className="text-sm text-muted-foreground text-center max-w-md">
                        Role A can propose decisions. Role B can approve, reject, and execute decisions.
                        This system ensures checks and balances in the decision-making process.
                    </p>
                </CardFooter>
            </Card>
        </section>
    )
}
