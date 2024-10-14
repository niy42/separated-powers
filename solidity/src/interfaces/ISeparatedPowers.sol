// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

interface ISeparatedPowers { 
    
    /* Type declarations */
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
        bool cancelled;
        bool completed;
    }

    /* external function */ 
    /**
     * @dev  
     */
    function propose(
        address targetLaw,
        bytes memory lawCalldata,
        string memory description
        ) external returns (uint256);

    /**
     * @dev
     */
    function execute(
        address executioner, 
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas
        ) external payable returns (bool); 

    /**
     * @dev
     */
    function complete(
        bytes memory lawCalldata, 
        bytes32 descriptionHash
        ) external; 

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
    function castVote(
        uint256 proposalId, 
        uint8 support
        ) external returns (uint256); 

    /**
     * @dev See {IGovernor-castVoteWithReason}.
     */
    function castVoteWithReason(
        uint256 proposalId,
        uint8 support,
        string calldata reason
        ) external returns (uint256);

    /* public */ 
    /**
     * @dev returns the State of a proposal. 
     */
    function state(uint256 proposalId) external returns (ProposalState);

    /* public pure & view functions */  
    /**
     * @dev 
     */
    function name() external returns (string memory);

    /**
     * @dev
     */
    function version() external returns (string memory);

    /**
    * @notice checks if account can call a law.
    *
    * @param caller caller address
    * @param targetLaw law address to check.
    *
    */
    function canCallLaw(address caller, address targetLaw) external returns (bool); 

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
     * @dev See {IGovernor-proposalDeadline}.
     */
    function proposalDeadline(uint256 proposalId) external returns (uint256);

}


// Structure contract //
/* version */
/* imports */
/* errors */
/* interfaces, libraries, contracts */
/* Type declarations */
/* State variables */
/* Events */
/* Modifiers */

/* FUNCTIONS: */
/* constructor */
/* receive function */
/* fallback function */
/* external */
/* public */
/* internal */
/* private */
/* internal & private view & pure functions */
/* external & public view & pure functions */
/* helpers */
/* complience */ // functions required for interactions with ERC standards 

