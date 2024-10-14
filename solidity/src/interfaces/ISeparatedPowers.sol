// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

interface ISeparatedPowers { 
    /* errors */
    error SeparatedPowers__RestrictedProposer(); 
    error SeparatedPowers__OnlySeparatedPowers(); 
    error SeparatedPowers__AccessDenied(); 
    error SeparatedPowers__UnexpectedProposalState(); 
    error SeparatedPowers__InvalidProposalId(); 
    error SeperatedPowers__NonexistentProposal(uint256 proposalId); 
    error SeparatedPowers__InvalidProposalLength(uint256 targetsLength, uint256 calldatasLength); 
    error SeparatedPowers__ProposalAlreadyExecuted(); 
    error SeparatedPowers__ProposalCancelled(); 
    error SeparatedPowers__ExecuteCallNotFromActiveLaw(); 
    error SeparatedPowers__OnlyProposer(address caller); 
    error SeparatedPowers__ProposalNotActive(); 
    error SeparatedPowers__NoAccessToTargetLaw();

    enum ProposalState {
        Active,
        Cancelled,
        Defeated,
        Succeeded,
        Completed
    }

    struct ProposalCore {
        address proposer;
        address targetLaw; 
        uint48 voteStart;
        uint32 voteDuration;
        bool executed;
        bool cancelled;
    }

    /* Events */
    event SeparatedPowers__Initialized(address contractAddress);
    event ProposalCompleted(uint256 indexed proposalId); 
    event ProposalCancelled(uint256 indexed proposalId);
    event VoteCast(address indexed account, uint256 indexed proposalId, uint8 indexed support, string reason);
    event FundsReceived(uint256 value);  
    event ProposalCreated(
        uint256 proposalId,
        address proposer,
        address targetLaw,
        string signature,
        bytes ececuteCalldata,
        uint256 voteStart,
        uint256 voteEnd,
        string description
    );
    
    /**
     * @dev 
     */
    function name() external returns (string memory);

    /**
     * @dev
     */
    function version() external returns (string memory);

    /**
     * @dev 
     *
     * Creates ProposalId on the basis of targets, values, callDatas and descriptionHash. 
     * 
     * Difference original: a second HasProposal (see below) includes an optional, additional, uint256 parentProposalId.  
     * 
     * See the desctiption from OpenZepplin's Governor.sol for more details on the original reasons.
     * 
     */
    function hashProposal(
        address targetLaw, 
        bytes memory LawCalldata,
        bytes32 descriptionHash
    ) external returns (uint256);

    /**
     * @dev returns the State of a proposal. 
     */
    function state(uint256 proposalId) external returns (ProposalState);

    /**
     * @dev See {IGovernor-proposalDeadline}.
     */
    function proposalDeadline(uint256 proposalId) external returns (uint256);
    
    /**
     * @dev  
     */
    function propose(
        address proposer,
        address targetLaw,
        bytes memory lawCalldata,
        string memory description
    ) external returns (uint256);

    /**
     * @dev
     */
    function execute(
        address proposer, 
        bytes memory lawCalldata, 
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) external payable returns (uint256); 


    /**
     * @dev See {IGovernor-cancel}.
     */
    function cancel(
        address targetLaw, 
        bytes memory lawCalldata,
        bytes32 descriptionHash
    ) external returns (uint256); 

    /**
     * @dev See {IGovernor-castVote}.
     */
    function castVote(uint256 proposalId, uint8 support) external returns (uint256); 

    /**
     * @dev See {IGovernor-castVoteWithReason}.
     */
    function castVoteWithReason(
        uint256 proposalId,
        uint8 support,
        string calldata reason
    ) external returns (uint256);

    /**
    * @notice checks if account can call a law.
    *
    * @param caller caller address
    * @param targetLaw law address to check.
    *
    */
    function canCallLaw(address caller, address targetLaw) external returns (bool canCall); 

}
