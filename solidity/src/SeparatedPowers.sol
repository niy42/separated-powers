// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {RolesManager} from "./RolesManager.sol";
import {LawsManager} from "./LawsManager.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";

/**
 * @dev TBI: Description contract. 
 *
 * Note: Where applicable, code taken from OpenZeppelin's Governor.sol contract. 
 * Note 2: Naming conventions followed from OpenZeppelin.  
 * 
 * Note, changes in comparison to Governor.sol:
 * no ERC165 use; no interface. For this core Governor contract. -- might change later. 
 * most central functions do have a virtual internal function, so these can be changed by inheriting this contract. -- coding practice of OpenZeppelin. 
 * No use of OnlyGovernor modifier: no actions outside this contract allowed. In essence, ALL functions are 'onlyGovernor'.
 * No use of clock() function. For now, everything goes with blocknumbers. Not timestamps. 
 * Original contract is abstract, with extensions being plugged in. All this NOT here. Any additional functionality is brought in through external law contracts. 
 * 
 */
contract SeparatedPowers is EIP712, RolesManager, LawsManager {

    bytes32 public constant BALLOT_TYPEHASH =
        keccak256("Ballot(uint256 proposalId,uint8 support,address voter,uint256 nonce)");
    bytes32 public constant EXTENDED_BALLOT_TYPEHASH =
        keccak256(
            "ExtendedBallot(uint256 proposalId,uint8 support,address voter,uint256 nonce,string reason,bytes params)"
        );

    struct ProposalCore {
        address proposer;
        uint48 voteStart;
        uint32 voteDuration;
        bool executed;
        bool canceled;
    }

    bytes32 private constant ALL_PROPOSAL_STATES_BITMAP = bytes32((2 ** (uint8(type(ProposalState).max) + 1)) - 1);
    string private _name;

    mapping(uint256 proposalId => ProposalCore) private _proposals;

    /**
     * @dev Sets the value for {name} and {version}
     */
    constructor(string memory name_) EIP712(name_, version()) { // NOTE Uses OpenZeppelin contract for management of EIP712. -- Where is this version called from? -- later on in the contract. 
        _name = name_;
    }

    /**
     * @dev Function to receive ETH 
     * Can be updated if needed.
     * No access control on this function: anyone can send funds into the main contract.    
     */
    receive() external payable virtual {
      emit SeparatedPowers__FundReceived(msg.value);  
    }

    /**
     * @dev 
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev
     */
    function version() public view virtual returns (string memory) {
        return "1";
    }

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
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) public pure virtual returns (uint256) {
        return uint256(keccak256(abi.encode(targets, values, calldatas, descriptionHash)));
    }

    /**
     * @dev 
     *
     * The same as the function above, but takes parentProposalId as additional parameter. 
     * 
     * Used in combination with the previous function, allows for chaining proposals into governance process. See function 'TBI' for more details. 
     * 
     */
    function hashProposal(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash,
        uint256 parentProposalId
    ) public pure virtual returns (uint256) {
        return uint256(keccak256(abi.encode(targets, values, calldatas, descriptionHash)));
    }

     /**
     * @dev returns the State of a proposal. 
     */
    function state(uint256 proposalId) public view virtual returns (ProposalState) {
        // We read the struct fields into the stack at once so Solidity emits a single SLOAD
        ProposalCore storage proposal = _proposals[proposalId];
        bool proposalExecuted = proposal.executed;
        bool proposalCanceled = proposal.canceled;

        if (proposalExecuted) {
            return ProposalState.Executed;
        }

        if (proposalCanceled) {
            return ProposalState.Canceled;
        }

        uint256 start = proposalStart(proposalId); // = startDate

        if (start == 0) {
            revert SeperatedPowers__NonexistentProposal(proposalId);
        }

        if (start >= currentTimepoint) {
            return ProposalState.Pending;
        }

        uint256 deadline = proposalDeadline(proposalId);

        if (deadline >= currentTimepoint) {
            return ProposalState.Active;
        } else if (!_quorumReached(proposalId) || !_voteSucceeded(proposalId)) {
            return ProposalState.Defeated;
        } else {
            return ProposalState.Succeeded;
        }
    }

    /**
     * @dev  
     * Was proposalSnapshot. -- too confusing for me, changed to proposalStart
     */
    function proposalStart(uint256 proposalId) public view virtual returns (uint256) {
        return _proposals[proposalId].voteStart;
    }

    /**
     * @dev See {IGovernor-proposalDeadline}.
     */
    function proposalDeadline(uint256 proposalId) public view virtual returns (uint256) {
        return _proposals[proposalId].voteStart + _proposals[proposalId].voteDuration;
    }

    /**
     * @dev See {IGovernor-proposalProposer}.
     */
    function proposalProposer(uint256 proposalId) public view virtual returns (address) {
        return _proposals[proposalId].proposer;
    }

    /**
     * @dev Amount of votes already cast passes the threshold limit.
     */
    function _quorumReached(uint256 proposalId) internal view virtual returns (bool) {
      // TBI 
    }

    /**
     * @dev Is the proposal successful or not.
     */
    function _voteSucceeded(uint256 proposalId) internal view virtual returns (bool); 

    /////////////////////////////////////////////////////////
    // CONTINUE HERE -- going to LAW & ROLE MANAGER NOW..  // 
    /////////////////////////////////////////////////////////

    /**
     * @dev  
     */
    function propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    ) public virtual returns (uint256) {
        address proposer = _msgSender();

        // check description restriction
        if (!_isValidDescriptionForProposer(proposer, description)) {
            revert GovernorRestrictedProposer(proposer);
        }

        // check proposal threshold
        uint256 votesThreshold = proposalThreshold();
        if (votesThreshold > 0) {
            uint256 proposerVotes = getVotes(proposer, clock() - 1);
            if (proposerVotes < votesThreshold) {
                revert GovernorInsufficientProposerVotes(proposer, proposerVotes, votesThreshold);
            }
        }

        return _propose(targets, values, calldatas, description, proposer);
    }

    /**
     * @dev Internal propose mechanism. Can be overridden to add more logic on proposal creation.
     *
     * Emits a {IGovernor-ProposalCreated} event.
     */
    function _propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description,
        address proposer
    ) internal virtual returns (uint256 proposalId) {
        proposalId = hashProposal(targets, values, calldatas, keccak256(bytes(description)));

        if (targets.length != values.length || targets.length != calldatas.length || targets.length == 0) {
            revert GovernorInvalidProposalLength(targets.length, calldatas.length, values.length);
        }
        if (_proposals[proposalId].voteStart != 0) {
            revert GovernorUnexpectedProposalState(proposalId, state(proposalId), bytes32(0));
        }

        uint256 snapshot = clock() + votingDelay();
        uint256 duration = votingPeriod();

        ProposalCore storage proposal = _proposals[proposalId];
        proposal.proposer = proposer;
        proposal.voteStart = SafeCast.toUint48(snapshot);
        proposal.voteDuration = SafeCast.toUint32(duration);

        emit ProposalCreated(
            proposalId,
            proposer,
            targets,
            values,
            new string[](targets.length),
            calldatas,
            snapshot,
            snapshot + duration,
            description
        );

        // Using a named return variable to avoid stack too deep errors
    }



}


// Notes to self: 
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
/* receive function (if exists) */
/* fallback function (if exists) */
/* external */
/* public */
/* internal */
/* private */
/* internal & private view & pure functions */
/* external & public view & pure functions */
