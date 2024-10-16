import { useState } from "react";

type roles = "A" | "B";
type proposalStatus = "Rejected" | "Approved" | "Executed" | "Proposed";

interface Proposal {
    id: number,
    description: string,
    status: proposalStatus
}

function DAOGovernance() {
    const [currentRole, setCurrentRole] = useState<roles>("A");
    const [proposals, setProposals] = useState<Proposal[]>([]);
    const [newProposal, setNewProposal] = useState<string>("");

    function proposeDecision(): void {
        if (newProposal.trim() !== "" && currentRole === "A") {
            setProposals([...proposals, { id: proposals.length + 1, description: newProposal, status: "Proposed" }]);
            setNewProposal("");

        }
    }

    function approveDecision(id: number) {
        if (currentRole === "B") {
            setProposals(proposals.map(proposal => proposal.id === id ? { ...proposal, status: "Approved" } : proposal));
        }
    }

    function rejectDecision(id: number) {
        if (currentRole === "B") {
            setProposals(proposals.map(proposal => proposal.id === id ? { ...proposal, status: "Rejected" } : proposal));
        }
    }

    function executeDecision(id: number): void {
if(currentRole === "B"){
    setProposals(proposals.map(proposal => proposal.id === id ? { ...proposal, status: "Executed"} : proposal))
}
    }
}