// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract agDAO {
    // Admin, Seniors, Whales, and Members roles
    address public admin;
    mapping(address => bool) public seniors;
    mapping(address => bool) public whales;
    mapping(address => bool) public members;

    uint public whaleCoinThreshold = 1000;
    uint public seniorQuorum = 10;  // Maximum of 10 seniors allowed

    // Track agCoin balances
    mapping(address => uint256) public agCoinBalance;
    
    // Proposal structure and status
    enum ProposalStatus { Proposed, Approved, Rejected }
    struct Proposal {
        uint256 id;
        string description;
        uint256 voteCount;
        ProposalStatus status;
        address proposer;
    }
    uint256 public nextProposalId;
    mapping(uint256 => Proposal) public proposals;

    // Voting and laws management
    struct Law {
        uint lawId;
        bool isActive;
        string description;
    }
    mapping(uint256 => Law) public laws;
    uint256 public nextLawId;
    
    // Events
    event ProposalCreated(uint256 id, string description, address proposer);
    event ProposalVoted(uint256 id, address voter);
    event LawAdded(uint256 id, string description);
    event LawActivated(uint256 id);
    event LawDeactivated(uint256 id);
    event MemberExpelled(address member);
    event MemberReinstated(address member);

    // Modifiers for role-based access
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    modifier onlySenior() {
        require(seniors[msg.sender], "Only seniors can perform this action");
        _;
    }

    modifier onlyWhale() {
        require(whales[msg.sender], "Only whales can perform this action");
        _;
    }

    modifier onlyMember() {
        require(members[msg.sender], "Only members can perform this action");
        _;
    }

    // Constructor
    constructor() {
        admin = msg.sender;  // Admin is the initiator of the DAO
    }

    // Law 1: Whales can claim their role by holding X agCoins
    function claimWhaleRole() public {
        require(agCoinBalance[msg.sender] >= whaleCoinThreshold, "Not enough agCoins to claim whale role");
        whales[msg.sender] = true;
    }

    // Law 2: Any address can become a member
    function joinAsMember() public {
        members[msg.sender] = true;
    }

    // Law 3: Members can propose new values
    function proposeNewValue(string memory _description) public onlyMember {
        proposals[nextProposalId] = Proposal(nextProposalId, _description, 0, ProposalStatus.Proposed, msg.sender);
        emit ProposalCreated(nextProposalId, _description, msg.sender);
        nextProposalId++;
    }

    // Law 4: Whales can approve values proposed by members
    function voteOnProposal(uint256 _proposalId) public onlyWhale {
        Proposal storage proposal = proposals[_proposalId];
        require(proposal.status == ProposalStatus.Proposed, "Proposal is not open for voting");
        proposal.voteCount++;

        if (proposal.voteCount >= whaleCoinThreshold / 10) {  // Simple majority based on whale coin thresholds
            proposal.status = ProposalStatus.Approved;
        }

        emit ProposalVoted(_proposalId, msg.sender);
    }

    // Law 5: Whales can expel members for misconduct
    function expelMember(address _member) public onlyWhale {
        require(members[_member], "Target address is not a member");
        members[_member] = false;
        agCoinBalance[_member] = 0;  // Remove steady drip of agCoins

        emit MemberExpelled(_member);
    }

    // Law 6: Expelled members can challenge their expulsion
    function challengeExpulsion() public {
        require(!members[msg.sender], "You are still a member");
        // Allow challenges from expelled members
        // Reinstatement logic handled by Seniors (Law 7)
    }

    // Law 7: Seniors can reinstate expelled members
    function reinstateMember(address _member) public onlySenior {
        require(!members[_member], "Already a member");
        members[_member] = true;

        emit MemberReinstated(_member);
    }

    // Law 8: Whales can propose activation/deactivation of laws
    function proposeLawActivation(string memory _description) public onlyWhale {
        laws[nextLawId] = Law(nextLawId, false, _description);
        emit LawAdded(nextLawId, _description);
        nextLawId++;
    }

    // Law 9: Seniors can activate/deactivate laws
    function activateLaw(uint256 _lawId) public onlySenior {
        Law storage law = laws[_lawId];
        require(!law.isActive, "Law is already active");
        law.isActive = true;

        emit LawActivated(_lawId);
    }

    function deactivateLaw(uint256 _lawId) public onlySenior {
        Law storage law = laws[_lawId];
        require(law.isActive, "Law is not active");
        law.isActive = false;

        emit LawDeactivated(_lawId);
    }

    // Law 10: Admin must accept law activation after seniors
    function finalizeLawActivation(uint256 _lawId) public onlyAdmin {
        Law storage law = laws[_lawId];
        require(law.isActive, "Law is not yet active");
        // Add final check or time delay logic for law activation

        // Law is now fully active
    }

    // Transfer agCoins between members
    function transferAgCoins(address to, uint256 amount) public onlyMember {
        require(agCoinBalance[msg.sender] >= amount, "Insufficient balance");
        agCoinBalance[msg.sender] -= amount;
        agCoinBalance[to] += amount;
    }

    // Earn agCoins for participation (triggered by various actions)
    function earnAgCoins(address user, uint256 amount) internal {
        agCoinBalance[user] += amount;
    }
}
