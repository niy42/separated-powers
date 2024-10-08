// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Law} from "./Law.sol";
import {LawsManager} from "./LawsManager.sol";
import {AuthorityManager} from "./AuthorityManager.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {Address} from "../lib/openzeppelin-contracts/contracts/utils/Address.sol";
import {EIP712} from "../lib/openzeppelin-contracts/contracts/utils/cryptography/EIP712.sol";

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
contract SeparatedPowers is EIP712, AuthorityManager, LawsManager {
    /* errors */
    error SeparatedPowers__RestrictedProposer(); 
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

    /* Type declarations */
    bytes32 public constant BALLOT_TYPEHASH =
        keccak256("Ballot(uint256 proposalId,uint8 support,address voter,uint256 nonce)");
    bytes32 public constant EXTENDED_BALLOT_TYPEHASH =
        keccak256(
            "ExtendedBallot(uint256 proposalId,uint8 support,address voter,uint256 nonce,string reason,bytes params)"
        );

    enum ProposalState {
        Active,
        Cancelled,
        Defeated,
        Succeeded,
        Executed
    }

    struct ProposalCore {
        address proposer;
        address targetLaw; 
        uint48 voteStart;
        uint32 voteDuration;
        bool executed;
        bool cancelled;
    }

    /* State variables */
    mapping(uint256 proposalId => ProposalCore) private _proposals;
    string private _name;

    /* Events */
    event ProposalExecuted(uint256 indexed proposalId); 
    event ProposalCancelled(uint256 indexed proposalId);
    event VoteCast(address indexed account, uint256 indexed proposalId, uint8 indexed support, string reason);
    event FundsReceived(uint256 value);  
       event ProposalCreated(
        uint256 proposalId,
        address proposer,
        address[] targets,
        string[] signatures,
        bytes[] calldatas,
        uint256 voteStart,
        uint256 voteEnd,
        string description
    );

    /* FUNCTIONS */
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
      emit FundsReceived(msg.value);  
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
        address targetLaw, 
        address proposer,  
        address[] memory targets,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) public pure virtual returns (uint256) {
        return uint256(keccak256(abi.encode(targetLaw, proposer, targets, calldatas, descriptionHash)));
    }

    /**
     * @dev returns the State of a proposal. 
     */
    function state(uint256 proposalId) public view virtual returns (ProposalState) {
        // We read the struct fields into the stack at once so Solidity emits a single SLOAD
        ProposalCore storage proposal = _proposals[proposalId];
        bool proposalExecuted = proposal.executed;
        bool proposalCancelled = proposal.cancelled;

        if (proposalExecuted) {
            return ProposalState.Executed;
        }
        if (proposalCancelled) {
            return ProposalState.Cancelled;
        }

        uint256 start = _proposals[proposalId].voteStart; // = startDate

        if (start == 0) {
            revert SeperatedPowers__NonexistentProposal(proposalId);
        }

        uint256 deadline = proposalDeadline(proposalId);
        address targetLaw = proposal.targetLaw; 

        if (deadline >= block.number) {
            return ProposalState.Active;
        } else if (!_quorumReached(proposalId, targetLaw) || !_voteSucceeded(proposalId, targetLaw)) {
            return ProposalState.Defeated;
        } else {
            return ProposalState.Succeeded;
        }
    }

    /**
     * @dev See {IGovernor-proposalDeadline}.
     */
    function proposalDeadline(uint256 proposalId) public view virtual returns (uint256) {
        return _proposals[proposalId].voteStart + _proposals[proposalId].voteDuration;
    }

    /**
     * @dev  
     */
    function propose(
        address targetLaw,
        address proposer, 
        address[] memory targets,
        bytes[] memory calldatas,
        string memory description
    ) public virtual returns (uint256) {
      if (proposer != msg.sender) {
        revert SeparatedPowers__RestrictedProposer(); 
      }
      return _propose(targetLaw, proposer, targets, calldatas, description);
    }

    /**
     * @dev Internal propose mechanism. Can be overridden to add more logic on proposal creation.
     *
     * Emits a {IGovernor-ProposalCreated} event.
     */
    function _propose(
        address targetLaw,
        address proposer, 
        address[] memory targets,
        bytes[] memory calldatas,
        string memory description
    ) internal virtual returns (uint256 proposalId) {
        // note that targetLaw AND proposer are hashed into the proposalId. By including proposer in the hash, front running can be avoided. 
        proposalId = hashProposal(targetLaw, proposer, targets, calldatas, keccak256(bytes(description)));
        uint64 accessRole = Law(targetLaw).accessRole(); 
        if (roles[accessRole].members[proposer] == 0) {
            revert SeparatedPowers__AccessDenied();
        } 
        if (targets.length != calldatas.length || targets.length == 0) {
            revert SeparatedPowers__InvalidProposalLength(targets.length, calldatas.length);
        }
        if (_proposals[proposalId].voteStart != 0) {
            revert SeparatedPowers__UnexpectedProposalState();
        }

        uint32 duration = Law(targetLaw).votingPeriod(); 
        ProposalCore storage proposal = _proposals[proposalId];
        proposal.proposer = proposer;
        proposal.voteStart = uint48(block.number); // at the moment proposal is made, voting start. 
        proposal.voteDuration = duration;

        emit ProposalCreated(
            proposalId,
            proposer,
            targets,
            new string[](targets.length),
            calldatas,
            block.number,
            block.number + duration,
            description
        );

        // Using a named return variable to avoid stack too deep errors
    }

    /**
     * @dev
     */
    function execute(
        address proposer, 
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) public payable virtual returns (uint256) {
      uint256 proposalId = hashProposal(msg.sender, proposer, targets, calldatas, descriptionHash);

      if (_proposals[proposalId].proposer == address(0)) {
        revert SeparatedPowers__InvalidProposalId(); 
      }
      if (_proposals[proposalId].executed == true) {
        revert SeparatedPowers__ProposalAlreadyExecuted(); 
      }
      if (_proposals[proposalId].cancelled == true) {
        revert SeparatedPowers__ProposalCancelled(); 
      }
      if (!activeLaws[msg.sender]) {
        revert SeparatedPowers__ExecuteCallNotFromActiveLaw(); 
      }

      // mark as executed before calls to avoid reentrancy
      _proposals[proposalId].executed = true;

      _executeOperations(proposalId, targets, values, calldatas, descriptionHash);

      emit ProposalExecuted(proposalId);

      return proposalId;
    }

    /**
     * @dev Internal execution mechanism. Can be overridden (without a super call) to modify the way execution is
     * performed (for example adding a vault/timelock).
     *
     * NOTE: Calling this function directly will NOT check the current state of the proposal, set the executed flag to
     * true or emit the `ProposalExecuted` event. Executing a proposal should be done using {execute} or {_execute}.
     */
    function _executeOperations(
        uint256 /* proposalId */,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 /*descriptionHash*/
    ) internal virtual {
        for (uint256 i = 0; i < targets.length; ++i) {
            (bool success, bytes memory returndata) = targets[i].call{value: values[i]}(calldatas[i]);
            Address.verifyCallResult(success, returndata);
        }
    }

    /**
     * @dev See {IGovernor-cancel}.
     */
    function cancel(
        address targetLaw, 
        address proposer, 
        address[] memory targets,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) public virtual returns (uint256) {
        // The proposalId will be recomputed in the `_cancel` call further down. However we need the value before we
        // do the internal call, because we need to check the proposal state BEFORE the internal `_cancel` call
        // changes it. The `hashProposal` duplication has a cost that is limited, and that we accept.
        uint256 proposalId = hashProposal(targetLaw, proposer, targets, calldatas, descriptionHash);

        if (msg.sender !=  _proposals[proposalId].proposer) {
            revert SeparatedPowers__OnlyProposer(msg.sender);
        }

        return _cancel(targetLaw, proposer, targets, calldatas, descriptionHash);
    }

    /**
     * @dev Internal cancel mechanism with minimal restrictions. A proposal can be cancelled in any state other than
     * Cancelled, Expired, or Executed. Once cancelled a proposal can't be re-submitted.
     *
     * Emits a {IGovernor-ProposalCancelled} event.
     */
    function _cancel(
        address targetLaw, 
        address proposer, 
        address[] memory targets,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal virtual returns (uint256) {
        uint256 proposalId = hashProposal(targetLaw, proposer, targets, calldatas, descriptionHash);

        _proposals[proposalId].cancelled = true;
        emit ProposalCancelled(proposalId);

        return proposalId;
    }

        /**
     * @dev See {IGovernor-castVote}.
     */
    function castVote(uint256 proposalId, uint8 support) public virtual returns (uint256) {
        address voter = msg.sender;
        return _castVote(proposalId, voter, support, "");
    }

    /**
     * @dev See {IGovernor-castVoteWithReason}.
     */
    function castVoteWithReason(
        uint256 proposalId,
        uint8 support,
        string calldata reason
    ) public virtual returns (uint256) {
        address voter = msg.sender;
        return _castVote(proposalId, voter, support, reason);
    }

 /**
     * @dev Internal vote casting mechanism: Check that the vote is pending, that it has not been cast yet, retrieve
     * voting weight using {IGovernor-getVotes} and call the {_countVote} internal function. Uses the _defaultParams().
     *
     * Emits a {IGovernor-VoteCast} event.
     */
    function _castVote(
        uint256 proposalId,
        address account,
        uint8 support,
        string memory reason
    ) internal virtual returns (uint256) {
      if (SeparatedPowers(payable(address(this))).state(proposalId) != ProposalState.Active) {
        revert SeparatedPowers__ProposalNotActive(); 
      } 

      _countVote(proposalId, account, support);  
      
      emit VoteCast(account, proposalId, support, reason);
    }


     /**
     * @dev See {IERC721Receiver-onERC721Received}.
     */
    function onERC721Received(address, address, uint256, bytes memory) public virtual returns (bytes4) {
        return this.onERC721Received.selector;
    }

    /**
     * @dev See {IERC1155Receiver-onERC1155Received}.
     */
    function onERC1155Received(address, address, uint256, uint256, bytes memory) public virtual returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    /**
     * @dev See {IERC1155Receiver-onERC1155BatchReceived}.
     */
    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
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
