"use client"

import { useState } from "react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { motion, AnimatePresence } from "framer-motion"
import { CheckCircle, XCircle, AlertCircle, PlayCircle, User, Users } from "lucide-react"

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

    const executeDecision = (id: number) => {
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
        <Card className="w-full max-w-4xl mx-auto bg-gradient-to-br from-gray-50 to-gray-100 dark:from-gray-900 dark:to-gray-800">
            <CardHeader className="space-y-1">
                <CardTitle className="text-2xl font-bold text-center">DAO Governance System</CardTitle>
                <CardDescription className="text-center">
                    A system with checks and balances for decentralized decision-making
                </CardDescription>
            </CardHeader>
            <CardContent className="space-y-6">
                <div className="flex items-center justify-center space-x-2 p-4 bg-primary/5 rounded-lg">
                    <Label htmlFor="role-select" className="text-sm font-medium">
                        Current Role:
                    </Label>
                    <Select value={currentRole} onValueChange={(value: Role) => setCurrentRole(value)}>
                        <SelectTrigger id="role-select" className="w-[200px]">
                            <SelectValue placeholder="Select a role" />
                        </SelectTrigger>
                        <SelectContent>
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
                    <div className="flex items-center space-x-2">
                        <Input
                            placeholder="Enter new proposal"
                            value={newProposal}
                            onChange={(e) => setNewProposal(e.target.value)}
                            className="flex-grow"
                        />
                        <Button onClick={proposeDecision} className="whitespace-nowrap">
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
                                <Card className="overflow-hidden">
                                    <CardContent className="p-4">
                                        <div className="flex justify-between items-center">
                                            <div className="space-y-1">
                                                <p className="font-medium">{proposal.description}</p>
                                                <div className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusColor(proposal.status)}`}>
                                                    {getStatusIcon(proposal.status)}
                                                    <span className="ml-1">{proposal.status}</span>
                                                </div>
                                            </div>
                                            {currentRole === "B" && proposal.status === "Proposed" && (
                                                <div className="space-x-2">
                                                    <Button onClick={() => approveDecision(proposal.id)} variant="outline" size="sm">
                                                        Approve
                                                    </Button>
                                                    <Button onClick={() => rejectDecision(proposal.id)} variant="destructive" size="sm">
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
    )
}