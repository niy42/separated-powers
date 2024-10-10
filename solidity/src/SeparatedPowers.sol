// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Law} from "./Law.sol";
import {LawsManager} from "./LawsManager.sol";
import {AuthoritiesManager} from "./AuthoritiesManager.sol";
import {ISeparatedPowers} from "./interfaces/ISeparatedPowers.sol"; 
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {Address} from "../lib/openzeppelin-contracts/contracts/utils/Address.sol";
import {EIP712} from "../lib/openzeppelin-contracts/contracts/utils/cryptography/EIP712.sol";

/**
 * @notice the core contract of the SeparatedPowers protocol. Inherits from {LawsManager}, {AuthoritiesManager} and {Law}.
 * Code derived from OpenZeppelin's Governor.sol contract. 
 * 
 * Some notable changes in comparison to Governor.sol 
 * - At the moment in this contract no ERC165 use; no interface. This might change later. 
 * - The onlyGovernor modifier is removed. 
 * - the use of the {clock} is removed. Only blocknumbers are used at the moment, no timestamps. 
 * - The original contract is set as abstract, with extensions being plugged in. SeparatedPowers is not an abstract contract, it is self contained.  
 *   Any additional functionality is brought in through Laws or through updating internal functions in implementations of SeparatedPowers. 
 * 
 * @author 7Cedars, Oct 2024, RnDAO CollabTech Hackathon
 */
contract SeparatedPowers is EIP712, AuthoritiesManager, LawsManager, ISeparatedPowers {

    mapping(uint256 proposalId => ProposalCore) private _proposals; // mapping from proposalId to proposalCore
    string private _name; // name of the contract.

    /**
     * @notice  Sets the value for {name} and {version} at the time of construction. 
     * 
     * @param name_ name of the contract
     */
    constructor(string memory name_) EIP712(name_, version()) { 
        _name = name_;
    }

    /**
     * @notice receive function enabling ETH deposits.  
     * 
     * @dev This is a virtual function, and can be overridden in child contracts.
     * @dev No access control on this function: anyone can send funds into the main contract.    
     */
    receive() external payable virtual {
      emit FundsReceived(msg.value);  
    }

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
     * @dev see {ISeperatedPowers.hashProposal}
     */
    function hashProposal(
        address targetLaw, 
        bytes memory executeCalldata,
        bytes32 descriptionHash
    ) public pure virtual returns (uint256) {
        return uint256(keccak256(abi.encode(targetLaw, executeCalldata, descriptionHash)));
    }

    /**
     * @dev see {ISeperatedPowers.hashProposal}
     */
    function _encodeExecuteCalldata(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal pure virtual returns (bytes) {
        return abi.encode(targets, values, calldatas, descriptionHash);
    }

    /**
     * @dev see {ISeperatedPowers.state}
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
     * @dev See {ISeperatedPowers.proposalDeadline}
     */
    function proposalDeadline(uint256 proposalId) public view virtual returns (uint256) {
        return _proposals[proposalId].voteStart + _proposals[proposalId].voteDuration;
    }

    /**
     * @dev see {ISeperatedPowers.propose}
     */
    function propose(
        address proposer,
        address targetLaw,
        bytes executeCalldata,
        string memory description
    ) public virtual returns (uint256) {
      if (proposer != msg.sender) {
        revert SeparatedPowers__RestrictedProposer(); 
      }

      return _propose(proposer, targetLaw, executeCalldata, description);
    }

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
        bytes memory executeCalldata,
        string memory description
    ) internal virtual returns (uint256 proposalId) {
        // note that targetLaw AND proposer are hashed into the proposalId. By including proposer in the hash, front running is avoided. 
        proposalId = hashProposal(targetLaw, executeCalldata, keccak256(bytes(description)));
        uint64 accessRole = Law(targetLaw).accessRole(); 
        if (roles[accessRole].members[proposer] == 0) {
            revert SeparatedPowers__AccessDenied();
        } 
        if (_proposals[proposalId].voteStart != 0) {
            revert SeparatedPowers__UnexpectedProposalState();
        }

        uint32 duration = Law(targetLaw).votingPeriod(); 
        ProposalCore storage proposal = _proposals[proposalId];
        proposal.proposer = proposer;
        proposal.voteStart = uint48(block.number); // at the moment proposal is made, voting start. There is no delay functionality. 
        proposal.voteDuration = duration;

        emit ProposalCreated(
            proposalId,
            proposer,
            targetLaw,
            new string[](1),
            executeCalldata,
            block.number,
            block.number + duration,
            description
        );

        // Using a named return variable to avoid stack too deep errors
    }

    /**
     * @dev see {ISeperatedPowers.execute}
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
     * @notice Internal execution mechanism. Can be overridden (without a super call) to modify the way execution is
     * performed 
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
     * @dev See {IseperatedPowers.cancel}
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
     * @notice Internal cancel mechanism with minimal restrictions. A proposal can be cancelled in any state other than
     * Cancelled, Expired, or Executed. Once cancelled a proposal can't be re-submitted.
     *
     * Emits a {ISeperatedPowers-ProposalCanceled} event.
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
     * @dev See {ISeperatedPowers.castVote}.
     */
    function castVote(uint256 proposalId, uint8 support) public virtual returns (uint256) {
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
      if (roles[accessRole].members[account] == 0) {
        revert SeparatedPowers__NoAccessToTargetLaw();          
      }
      // if all this passes: cast vote. 
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

