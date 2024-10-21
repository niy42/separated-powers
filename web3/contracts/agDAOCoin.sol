// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AgDAOCoin {
    address public admin;
    uint256 public whaleCoinThreshold = 1000; // Example threshold value
    uint256 public nextProposalId = 0;
    uint256 public nextLawId = 0;

    struct Member {
        bool isSenior;
        bool isWhale;
        bool isMember;
        uint256 balance;
        bool isRevoked;
    }

    struct CoreValue {
        string value;
        bool accepted;
    }

    struct Proposal {
        uint256 id;
        string description;
        uint256 voteCount;
        ProposalStatus status;
        address proposer;
    }

    enum ProposalStatus { Proposed, Approved, Rejected }

    struct Law {
        uint256 id;
        bool isActive;
        string description;
    }

    mapping(address => Member) public members;
    mapping(address => bool) public seniors;
    mapping(address => bool) public whales;
    mapping(string => CoreValue) public coreValues;
    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => Law) public laws;
    string[] public proposedCoreValues;

    event CoreValueProposed(string value, address proposer);
    event CoreValueAccepted(string value, address acceptor);
    event MemberRevoked(address member, address admin);
    event MemberReinstated(address member);

    event LawFinalized(uint256 lawId, uint256 blockDelay);
    event ProposalCreated(uint256 proposalId, string description, address proposer);
    event ProposalVoted(uint256 proposalId, address voter);
    event MemberExpelled(address member);
    event LawAdded(uint256 lawId, string description);
    event LawActivated(uint256 lawId);
    event LawDeactivated(uint256 lawId);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can execute this.");
        _;
    }

    modifier onlyMember() {
        require(members[msg.sender].isMember, "Only members can execute this.");
        _;
    }

    modifier onlyWhale() {
        require(members[msg.sender].isWhale, "Only whales can execute this.");
        _;
    }

    modifier onlySenior() {
        require(members[msg.sender].isSenior, "Only seniors can execute this.");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    // Assign roles
    function addMember(address _member, bool _isSenior, bool _isWhale) external onlyAdmin {
        members[_member] = Member(_isSenior, _isWhale, true, 0, false);
    }

    function revokeMember(address _member) external onlyAdmin {
        require(members[_member].isMember, "Not a valid member");
        members[_member].isRevoked = true;
        emit MemberRevoked(_member, msg.sender);
    }

    function reinstateMember(address _member) external onlyAdmin {
        require(members[_member].isRevoked, "Member not revoked");
        members[_member].isRevoked = false;
        emit MemberReinstated(_member);
    }

    // Core value proposal
    function proposeCoreValue(string memory _value) external onlyMember {
        proposedCoreValues.push(_value);
        coreValues[_value] = CoreValue(_value, false);
        emit CoreValueProposed(_value, msg.sender);
    }

    function acceptCoreValue(string memory _value) external onlyAdmin {
        require(!coreValues[_value].accepted, "Already accepted");
        coreValues[_value].accepted = true;
        emit CoreValueAccepted(_value, msg.sender);
    }

    // agCoin balance
    function agCoinBalance(address _address) public view returns (uint256) {
        return members[_address].balance;
    }

    function increaseBalance(address _member, uint256 _amount) external onlyAdmin {
        members[_member].balance += _amount;
    }

    // Law finalization

    function finalizeLaw(string memory _description, uint256 blockDelay) external onlyAdmin {
        laws[nextLawId] = Law(nextLawId, false, _description);
        emit LawFinalized(nextLawId, blockDelay);
        nextLawId++;
    }

    // Law 1: Whales can claim their role by holding X agCoins
    function claimWhaleRole() public {
        require(!members[msg.sender].isWhale, "Already a whale");
        require(agCoinBalance(msg.sender) >= whaleCoinThreshold, "Not enough agCoins to claim whale role");
        members[msg.sender].isWhale = true;
    }

    // Law 2: Any address can become a member
    function joinAsMember() public {
        members[msg.sender] = Member(false, false, true, 0, false);
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
        require(members[_member].isMember, "Target address is not a member");
        members[_member].isMember = false;
        members[_member].balance = 0;

        emit MemberExpelled(_member);
    }

    // Law 6: Expelled members can challenge their expulsion
    function challengeExpulsion() public {
        require(!members[msg.sender].isMember, "You are still a member");
        // Logic for challenging expulsion can be added here
    }

    // Law 7: Seniors can reinstate expelled members
    function seniorReinstateMember(address _member) public onlySenior {
        require(!members[_member].isMember, "Already a member");
        members[_member].isMember = true;

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
        require(members[msg.sender].balance >= amount, "Insufficient balance");
        members[msg.sender].balance -= amount;
        members[to].balance += amount;
    }

    // Earn agCoins for participation (triggered by various actions)
    function earnAgCoins(address user, uint256 amount) internal {
        members[user].balance += amount;
    }

    // Get all proposals
    function getAllProposals() public view returns (Proposal[] memory) {
        Proposal[] memory allProposals = new Proposal[](nextProposalId);
        for (uint256 i = 0; i < nextProposalId; i++) {
            allProposals[i] = proposals[i];
        }
        return allProposals;
 
}
