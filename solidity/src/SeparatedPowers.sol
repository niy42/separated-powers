// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Law} from "./Law.sol";
import {LawsManager} from "./LawsManager.sol";
import {AuthoritiesManager} from "./AuthoritiesManager.sol";
import {ISeparatedPowers} from "./interfaces/ISeparatedPowers.sol"; 
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {Address} from "../lib/openzeppelin-contracts/contracts/utils/Address.sol";
import {EIP712} from "../lib/openzeppelin-contracts/contracts/utils/cryptography/EIP712.sol";

// ONLY FOR TESTING PURPOSES // DO NOT USE IN PRODUCTION
import {console2} from "lib/forge-std/src/Test.sol";

/**
 * @notice the core contract of the SeparatedPowers protocol. Inherits from {LawsManager}, {AuthoritiesManager} and {Law}.
 * Code derived from OpenZeppelin's Governor.sol contract. 
 * 
 * Some notable changes in comparison to Governor.sol 
 * - At the moment in this contract no ERC165 use; no interface. This might change later. 
 * - The onlyGovernor modifier is removed. 
 * - the use of the {clock} is removed. Only blocknumbers are used at the moment, no timestamps. 
 * - There is currently no protection against front running. 
 * - The original contract is set as abstract, with extensions being plugged in. SeparatedPowers is not an abstract contract, it is self contained.  
 *   Any additional functionality is brought in through Laws or through updating internal functions in implementations of SeparatedPowers. 
 * 
 * @author 7Cedars, Oct 2024, RnDAO CollabTech Hackathon
 */
contract SeparatedPowers is EIP712, AuthoritiesManager, LawsManager, ISeparatedPowers {
    /* errors */
    error SeparatedPowers__ConstitutionAlreadyExecuted(); 
    error SeparatedPowers__RestrictedProposer(); 
    error SeparatedPowers__OnlySeparatedPowers(); 
    error SeparatedPowers__AccessDenied(); 
    error SeparatedPowers__UnexpectedProposalState(); 
    error SeparatedPowers__InvalidProposalId(); 
    error SeperatedPowers__NonExistentProposal(uint256 proposalId); 
    error SeparatedPowers__InvalidProposalLength(uint256 targetsLength, uint256 calldatasLength); 
    error SeparatedPowers__ProposalAlreadyCompleted(); 
    error SeparatedPowers__ProposalCancelled(); 
    error SeparatedPowers__ExecuteCallNotFromActiveLaw(); 
    error SeparatedPowers__OnlyProposer(address caller); 
    error SeparatedPowers__ProposalNotActive(); 
    error SeparatedPowers__NoAccessToTargetLaw();
    
    /* State variables */
    mapping(uint256 proposalId => ProposalCore) private _proposals; // mapping from proposalId to proposalCore
    string private _name; // name of the contract.
    bool private _constitutionalLawsExecuted; // name of the contract.

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
    
    /* Modifiers */
    /** 
    * @notice A modifier that sets a function to only be callable by the {SeparatedPowers} contract itself.
    * 
    * @dev It can used in derived contracts to easily protect functions from being called from outside the protocol.
    */ 
    modifier onlySeparatedPowers() {
        if (msg.sender != address(this)) {
            revert SeparatedPowers__OnlySeparatedPowers();
            _;
        }
    }

    //////////////////////////////
    //          FUNCTIONS       //
    //////////////////////////////
    /* constructor */
    /**
     * @notice  Sets the value for {name} and {version} at the time of construction. 
     * 
     * @param name_ name of the contract
     */
    constructor(string memory name_) EIP712(name_, version()) { 
        _name = name_;
        _setRole(ADMIN_ROLE, msg.sender, true); // the account that initiates a SeparatedPowers contract is set to its admin.

        emit SeparatedPowers__Initialized(address(this));
    }

    /* receive function */
    /**
     * @notice receive function enabling ETH deposits.  
     * 
     * @dev This is a virtual function, and can be overridden in child contracts.
     * @dev No access control on this function: anyone can send funds into the main contract.    
     */
    receive() external payable virtual {
      emit FundsReceived(msg.value);  
    }

    //////////////////////////////
    //        EXTERNAL          //
    //////////////////////////////
    /**
     * @dev see {ISeperatedPowers.constitute}
     */
    function constitute(
        address[] memory constitutionalLaws,
        ConstituentRole[] memory constitutionalRoles
    ) external virtual {
        // check 1: only admin can call this function
        if (roles[ADMIN_ROLE].members[msg.sender] == 0) {
            revert SeparatedPowers__AccessDenied();
        }

        // check 2: this function can only be called once.
        if (_constitutionalLawsExecuted) {
            revert SeparatedPowers__ConstitutionAlreadyExecuted();
        }
        
        // if checks pass, set _constitutionalLawsExecuted to true... 
        _constitutionalLawsExecuted = true;

        // ...and execute constitutional laws
        for (uint256 i = 0; i < constitutionalLaws.length; i++) {
            _setLaw(constitutionalLaws[i], true);
        }
        for (uint256 i = 0; i < constitutionalRoles.length; i++) {
            _setRole(constitutionalRoles[i].roleId, constitutionalRoles[i].account, true);
        }
    }

    /**
     * @dev see {ISeperatedPowers.propose}
     */
    function propose(
        address targetLaw,
        bytes memory lawCalldata,
        string memory description
    ) external virtual returns (uint256) {
        // check 1: does msg.sender have access to targetLaw?
        uint64 accessRole = Law(targetLaw).accessRole(); 
        if (roles[accessRole].members[msg.sender] == 0 && accessRole != PUBLIC_ROLE) {
            revert SeparatedPowers__AccessDenied();
        } 

        // if check passes: propose. 
        return _propose(msg.sender, targetLaw, lawCalldata, description);
    }

    /**
     * @dev See {ISeperatedPowers.castVote}.
     */
    function castVote(uint256 proposalId, uint8 support) external virtual returns (uint256) {
        address voter = msg.sender;
        return _castVote(proposalId, voter, support, "");
    }

    /**
     * @dev See {ISeperatedPowers.castVoteWithReason}.
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
     * @dev see {ISeperatedPowers.execute}
     * 
     * Note any reference to proposal (as in OpenZeppelin's Governor.sol) are removed. 
     * The mechanism of SeparatedPowers detaches proposals from execution logic. 
     * Instead, proposal checks are, placed in the {complete} funciton.)
     */
    function execute(
        address executioner,  
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas
    ) external payable virtual returns (bool) {
        // check 1: is call from an active law? 
        if (!activeLaws[msg.sender]) {
            revert SeparatedPowers__ExecuteCallNotFromActiveLaw(); 
        }

        // check 2: does executioner have access to law being executed? 
        uint64 accessRole = Law(msg.sender).accessRole(); 
        if (roles[accessRole].members[executioner] == 0 && accessRole != PUBLIC_ROLE) {
            revert SeparatedPowers__AccessDenied();
        } 

        // if checks pass: execute.
        _executeOperations(targets, values, calldatas);

    }

    /**
     * @dev see {ISeperatedPowers.complete} 
     */
    function complete(
        bytes memory lawCalldata,
        bytes32 descriptionHash
        ) external virtual {

        uint256 proposalId = hashProposal(msg.sender, lawCalldata, descriptionHash);

        // check 1: is call from an active law? 
        if (!activeLaws[msg.sender]) {
            revert SeparatedPowers__ExecuteCallNotFromActiveLaw(); 
        }
        // check 2: does proposal exist?  
        if (_proposals[proposalId].proposer == address(0)) {
                revert SeparatedPowers__InvalidProposalId(); 
        }
        // check 3: is proposal already completed?
        if (_proposals[proposalId].completed == true) {
            revert SeparatedPowers__ProposalAlreadyCompleted(); 
        }
        // check 4: is proposal cancelled?
        if (_proposals[proposalId].cancelled == true) {
            revert SeparatedPowers__ProposalCancelled(); 
        }

        // if checks pass: complete & emit event.
        _proposals[proposalId].completed = true; 
        emit ProposalCompleted(proposalId);
    }

    /**
     * @dev See {IseperatedPowers.cancel}
     */
    function cancel(
        address targetLaw, 
        bytes memory lawCalldata,
        bytes32 descriptionHash
    ) public virtual returns (uint256) {
        // The proposalId will be recomputed in the `_cancel` call further down. However we need the value before we
        // do the internal call, because we need to check the proposal state BEFORE the internal `_cancel` call
        // changes it. The `hashProposal` duplication has a cost that is limited, and that we accept.
        uint256 proposalId = hashProposal(targetLaw, lawCalldata, descriptionHash);

        if (msg.sender !=  _proposals[proposalId].proposer) {
            revert SeparatedPowers__OnlyProposer(msg.sender);
        }

        return _cancel(targetLaw, lawCalldata, descriptionHash);
    }

 
    //////////////////////////////
    //         PUBLIC           //
    //////////////////////////////
    
    /**
     * @dev see {ISeperatedPowers.state}
     */
    function state(uint256 proposalId) public view virtual returns (ProposalState) {
        // We read the struct fields into the stack at once so Solidity emits a single SLOAD
        ProposalCore storage proposal = _proposals[proposalId];
        bool proposalCompleted = proposal.completed;
        bool proposalCancelled = proposal.cancelled;

        if (proposalCompleted) {
            return ProposalState.Completed;
        }
        if (proposalCancelled) {
            return ProposalState.Cancelled;
        }

        uint256 start = _proposals[proposalId].voteStart; // = startDate

        if (start == 0) {
            revert SeperatedPowers__NonExistentProposal(proposalId);
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

    //////////////////////////////
    //        INTERNAL          //
    //////////////////////////////
    /**
     * @notice Internal propose mechanism. Can be overridden to add more logic on proposal creation.
     * 
     * @dev The mechanism checks for access of proposer and for the length of targets and calldatas. 
     *
     * Emits a {IGovernor-ProposalCreated} event.
     */
    function _propose(
        address proposer,
        address targetLaw,
        bytes memory lawCalldata,
        string memory description
    ) internal virtual returns (uint256 proposalId) {
        // note that targetLaw AND proposer are hashed into the proposalId. By including proposer in the hash, front running is avoided. 
        proposalId = hashProposal(targetLaw, lawCalldata, keccak256(bytes(description)));
        if (_proposals[proposalId].voteStart != 0) {
            revert SeparatedPowers__UnexpectedProposalState();
        }

        uint32 duration = Law(targetLaw).votingPeriod(); 
        ProposalCore storage proposal = _proposals[proposalId];
        proposal.proposer = proposer;
        proposal.targetLaw = targetLaw;
        proposal.voteStart = uint48(block.number); // at the moment proposal is made, voting start. There is no delay functionality. 
        proposal.voteDuration = duration;

        emit ProposalCreated(
            proposalId,
            proposer,
            targetLaw,
            "",
            lawCalldata,
            block.number,
            block.number + duration,
            description
        );

        // Using a named return variable to avoid stack too deep errors
    }

    /**
     * @notice Internal vote casting mechanism: Check that the proposal is active, and that account is has access to targetLaw.  
     *
     * Emits a {ISeperatedPowers-VoteCast} event.
     */
    function _castVote(
        uint256 proposalId,
        address account,
        uint8 support,
        string memory reason
    ) internal virtual returns (uint256) {
      // Check that the proposal is active, that it has not been paused, cancelled or ended yet. 
      if (SeparatedPowers(payable(address(this))).state(proposalId) != ProposalState.Active) {
        revert SeparatedPowers__ProposalNotActive(); 
      } 
      // Note that we check if account has access to the law targetted in the proposal. 
      address targetLaw = _proposals[proposalId].targetLaw;
      uint64 accessRole = Law(targetLaw).accessRole();  
      if (roles[accessRole].members[account] == 0 && accessRole != PUBLIC_ROLE) {
        revert SeparatedPowers__NoAccessToTargetLaw();          
      }
      // if all this passes: cast vote. 
      _countVote(proposalId, account, support);  
      
      emit VoteCast(account, proposalId, support, reason);
    }

    /**
     * @notice internal function {quorumReached} that checks if the quorum for a given proposal has been reached.
     *
     * @param proposalId id of the proposal.
     * @param targetLaw address of the law that the proposal belongs to. 
     *
     */
    function _quorumReached(uint256 proposalId, address targetLaw) internal view virtual returns (bool) {
        ProposalVote storage proposalVote = _proposalVotes[proposalId];

        uint8 quorum = Law(targetLaw).quorum(); 
        uint64 accessRole = Law(targetLaw).accessRole(); 
        uint256 amountMembers = roles[accessRole].amountMembers;

        return (amountMembers * quorum) / DENOMINATOR <= proposalVote.forVotes + proposalVote.abstainVotes; 
    }

    /**
     * @dev internal function {voteSucceeded} that checks if a vote for a given proposal has succeeded.
     *
     * @param proposalId id of the proposal.
     * @param targetLaw address of the law that the proposal belongs to.
     */
    function _voteSucceeded(uint256 proposalId, address targetLaw) internal view virtual returns (bool) {
        ProposalVote storage proposalVote = _proposalVotes[proposalId];
      
        uint8 succeedAt = Law(targetLaw).succeedAt(); 
        uint8 quorum = Law(targetLaw).quorum(); 
        uint64 accessRole = Law(targetLaw).accessRole(); 
        uint256 amountMembers = roles[accessRole].amountMembers;
 
        // note if quorum is set to 0 in a Law, it will automatically return true.
        return quorum == 0 || amountMembers * succeedAt <= proposalVote.forVotes * DENOMINATOR;  
    }

    /**
     * @notice Internal execution mechanism. Can be overridden (without a super call) to modify the way execution is
     * performed 
     *
     * NOTE: Calling this function directly will NOT check the current state of the proposal, set the executed flag to
     * true or emit the `ProposalExecuted` event. Executing a proposal should be done using {execute} or {_execute}.
     */
    function _executeOperations(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas
    ) internal virtual {
        for (uint256 i = 0; i < targets.length; ++i) {
            (bool success, bytes memory returndata) = targets[i].call{value: values[i]}(calldatas[i]);
            Address.verifyCallResult(success, returndata);
        }
    }

    /**
     * @notice Internal cancel mechanism with minimal restrictions. A proposal can be cancelled in any state other than
     * Cancelled, Expired, or Executed. Once cancelled a proposal can't be re-submitted.
     *
     * Emits a {ISeperatedPowers-ProposalCanceled} event.
     */
    function _cancel(
        address targetLaw, 
        bytes memory lawCalldata,
        bytes32 descriptionHash
    ) internal virtual returns (uint256) {
        uint256 proposalId = hashProposal(targetLaw, lawCalldata, descriptionHash);

        _proposals[proposalId].cancelled = true;
        emit ProposalCancelled(proposalId);

        return proposalId;
    }

    /////////////////////////////////////
    //  PUBLIC PURE & VIEW (Getters)   //
    /////////////////////////////////////
    /**
     * @notice saves the name of the SeparatedPowers implementation.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @notice saves the version of the SeparatedPowers implementation.
     */
    function version() public view virtual returns (string memory) {
        return "1";
    }

    /**
     * @notice public function {canCallLaw} that checks if a caller can call a given law.
     *
     * @param caller address of the caller.
     * @param targetLaw address of the law to check. 
     */
    function canCallLaw(address caller, address targetLaw) public view returns (bool) {
        uint64 accessRole = Law(targetLaw).accessRole(); 
        uint48 since =  hasRoleSince(caller, accessRole); 
        
        return since != 0; 
    }

    /**
     * @dev see {ISeperatedPowers.hashProposal}
     */
    function hashProposal(
        address targetLaw, 
        bytes memory lawCalldata,
        bytes32 descriptionHash
    ) public pure virtual returns (uint256) {
        return uint256(keccak256(abi.encode(targetLaw, lawCalldata, descriptionHash)));
    }

    /**
     * @dev See {ISeperatedPowers.proposalDeadline}
     */
    function proposalDeadline(uint256 proposalId) public view virtual returns (uint256) {
        return _proposals[proposalId].voteStart + _proposals[proposalId].voteDuration;
    }

    //////////////////////////////
    //        COMPLIENCE        //
    //////////////////////////////
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
