// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Law} from "./Law.sol";
import {IAuthoritiesManager} from "./interfaces/IAuthoritiesManager.sol"; 

/**
 * @dev TBI: Description contract.
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
    
    /* FUNCTIONS */ 
    function setRole(uint64 roleId, address account, bool access) public virtual {
      // this function can only be called from the execute function  of SeperatedPowers with a .call call. 
      // As such, there is a msg.sender, but it always has to come form address (this).  
      if (msg.sender != address(this)) { 
        revert AuthorityManager_NotAuthorized(msg.sender);  
      }
        _setRole(roleId, account, access);
    }

    /**
     * @dev Internal version of {setRole} without access control. Returns true if the role was newly granted.
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
            roles[roleId].members[account] = uint48(block.number); 
            roles[roleId].amountMembers++; 
            accessChanged = true; 
        } else if (!access && !newMember)  {
          roles[roleId].members[account] = 0;
          roles[roleId].amountMembers--; // NB! CHECK IF THIS WORKS 
          accessChanged = true;
        }

        emit RoleSet(roleId, account, accessChanged);
        return accessChanged;
    }

    /**
     * @dev }.
     */
    function hasVoted(uint256 proposalId, address account) public view virtual returns (bool) {
        return _proposalVotes[proposalId].hasVoted[account];
    }

    /**
     * @dev
     */
    function proposalVotes(
        uint256 proposalId
    ) public view virtual returns (uint256 againstVotes, uint256 forVotes, uint256 abstainVotes) {
        ProposalVote storage proposalVote = _proposalVotes[proposalId];
        return (proposalVote.againstVotes, proposalVote.forVotes, proposalVote.abstainVotes);
    }

    /**
     * @dev
     */
    function _quorumReached(uint256 proposalId, address targetLaw) internal view virtual returns (bool) {
        ProposalVote storage proposalVote = _proposalVotes[proposalId];

        uint8 quorum = Law(targetLaw).quorum(); 
        uint64 accessRole = Law(targetLaw).accessRole(); 
        uint256 amountMembers = roles[accessRole].amountMembers;

        return (amountMembers * quorum) / DECIMALS <= proposalVote.forVotes + proposalVote.abstainVotes; 

        // return true;
    }

    /**
     * @dev 
     */
    function _voteSucceeded(uint256 proposalId, address targetLaw) internal view virtual returns (bool) {
        ProposalVote storage proposalVote = _proposalVotes[proposalId];
      
        uint8 succeedAt = Law(targetLaw).succeedAt(); 
        uint64 accessRole = Law(targetLaw).accessRole(); 
        uint256 amountMembers = roles[accessRole].amountMembers;

        return (amountMembers * succeedAt) / DECIMALS <= proposalVote.forVotes; 

        // return true;
    }

    /**
     * @dev In this module, the support follows the `VoteType` enum (from Governor Bravo).
     */
    function _countVote(
        uint256 proposalId,
        address account,
        uint8 support
    ) internal virtual {
        ProposalVote storage proposalVote = _proposalVotes[proposalId];
        // HERE NEED TO CHECK IF account has roleID! 

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
    function _canCall(address caller, address targetLaw) internal virtual returns (bool) {
        uint64 accessRole = Law(targetLaw).accessRole(); 
        uint48 since =  hasRoleSince(caller, accessRole); 
        
        return since != 0; 
    }
    
    /* getters */
    function hasRoleSince(address account, uint64 roleId) public returns (uint48 since) {
      return roles[roleId].members[account]; 
    }

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
