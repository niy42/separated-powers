// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Law} from "./Law.sol";
import {IAuthoritiesManager} from "./interfaces/IAuthoritiesManager.sol"; 

/**
 * @notice Interface for managing roles and vote access. Derived from OpenZeppelin's GovernorCountingSimple.sol. 
 *
 * Note: Derived from GovernorCountingSimple. 
 *
 */
contract AuthoritiesManager is IAuthoritiesManager { 
    mapping(uint256 proposalId => ProposalVote) private _proposalVotes;
    mapping(uint64 roleId => Role) public roles;   
    
    uint64 public constant ADMIN_ROLE = type(uint64).min; // 0
    uint64 public constant PUBLIC_ROLE = type(uint64).max; // 2**64-1
    uint256 constant DECIMALS = 100;
    
    /**
    * @dev see {IAuthoritiesManager.setRole}
    */
    function setRole(uint64 roleId, address account, bool access) public virtual {
      // this function can only be called from the execute function  of SeperatedPowers with a .call call. 
      // As such, there is a msg.sender, but it always has to come form address (this).  
      if (msg.sender != address(this)) { 
        revert AuthorityManager_NotAuthorized(msg.sender);  
      }
        _setRole(roleId, account, access);
    }

    /**
     * @notice Internal version of {setRole} without access control. Returns true if the role was newly granted.
     *
     * Emits a {RoleGranted} event.
     */
    function _setRole(
        uint64 roleId,
        address account,
        bool access
    ) internal virtual returns (bool) {
        if (roleId == PUBLIC_ROLE) {
            revert AuthorityManager_LockedRole(roleId);
        }

        bool newMember = roles[roleId].members[account] == 0;
        bool accessChanged;  

        if (access && newMember) {
            roles[roleId].members[account] = uint48(block.number); // 'since' is set at current block.number  
            roles[roleId].amountMembers++; 
            accessChanged = true; 
        } else if (!access && !newMember)  {
          roles[roleId].members[account] = 0;
          roles[roleId].amountMembers--; 
          accessChanged = true;
        }

        emit RoleSet(roleId, account, accessChanged);
        return accessChanged;
    }

    /**
     * @dev see {IAuthoritiesManager.hasVoted}
     */
    function hasVoted(uint256 proposalId, address account) public view virtual returns (bool) {
        return _proposalVotes[proposalId].hasVoted[account];
    }

    /**
     * @dev see {IAuthoritiesManager.proposalVotes}
     */
    function proposalVotes(
        uint256 proposalId
    ) public view virtual returns (uint256 againstVotes, uint256 forVotes, uint256 abstainVotes) {
        ProposalVote storage proposalVote = _proposalVotes[proposalId];
        return (proposalVote.againstVotes, proposalVote.forVotes, proposalVote.abstainVotes);
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

        return (amountMembers * quorum) / DECIMALS <= proposalVote.forVotes + proposalVote.abstainVotes; 
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
        uint64 accessRole = Law(targetLaw).accessRole(); 
        uint256 amountMembers = roles[accessRole].amountMembers;

        return (amountMembers * succeedAt) / DECIMALS <= proposalVote.forVotes; 
    }

    /**
     * @notice internal function {countVote} that counts against, for, and abstain votes for a given proposal.
     * 
     * @dev In this module, the support follows the `VoteType` enum (from Governor Bravo).
     * @dev It does not check if account has roleId referenced in proposalId. This has to be done by {SeparatedPowers.castVote} function.  
     */
    function _countVote(
        uint256 proposalId,
        address account,
        uint8 support
    ) internal virtual {
        ProposalVote storage proposalVote = _proposalVotes[proposalId];

        if (proposalVote.hasVoted[account]) {
            revert AuthorityManager_AlreadyCastVote(account);
        }
        proposalVote.hasVoted[account] = true;

        if (support == uint8(VoteType.Against)) {
            proposalVote.againstVotes++;
        } else if (support == uint8(VoteType.For)) {
            proposalVote.forVotes++;
        } else if (support == uint8(VoteType.Abstain)) {
            proposalVote.abstainVotes++;
        } else {
            revert AuthorityManager_InvalidVoteType();
        }
    }

    /* internal & private view & pure functions */
    /**
     * @notice internal function {canCallLaw} that checks if a caller can call a given law.
     *
     * @param caller address of the caller.
     * @param targetLaw address of the law to check. 
     */
    function _canCall(address caller, address targetLaw) internal virtual returns (bool) {
        uint64 accessRole = Law(targetLaw).accessRole(); 
        uint48 since =  hasRoleSince(caller, accessRole); 
        
        return since != 0; 
    }
    
    /**
     * @dev see {IAuthoritiesManager.hasRoleSince}
     */
    function hasRoleSince(address account, uint64 roleId) public returns (uint48 since) {
      return roles[roleId].members[account]; 
    }

    /**
     * @dev see {IAuthoritiesManager.canCallLaw}
     */
    function canCallLaw(address caller, address targetLaw) external returns (bool)  {
        _canCall(caller, targetLaw); 
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
