// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @dev TBI: Description contract.
 *
 * Note: Derived from GovernorCountingSimple. 
 *
 */
interface IAuthoritiesManager {
    error AuthorityManager_NotAuthorized(address invalidAddress);
    error AuthorityManager_InvalidInitialAdmin(address invalidAddress);
    error AuthorityManager_LockedRole(uint64 roleId);
    error AuthorityManager_AlreadyCastVote(address account);
    error AuthorityManager_InvalidVoteType(); 
    
    /**
     * @dev Supported vote types. Matches Governor Bravo ordering.
     */
    enum VoteType {
        Against,
        For,
        Abstain
    }

    struct ProposalVote {
        uint256 againstVotes;
        uint256 forVotes;
        uint256 abstainVotes;
        mapping(address voter => bool) hasVoted;
    }
    
    struct Role {
        // Members of the role.
        mapping(address user => uint48 since) members;
        uint256 amountMembers; 
    }

    event RoleSet(uint64 indexed roleId, address indexed account, bool indexed accessChanged); 

    function setRole(uint64 roleId, address account, bool access) external; 
  
    function hasVoted(uint256 proposalId, address account) external returns (bool);

    function proposalVotes(uint256 proposalId) external returns (uint256 againstVotes, uint256 forVotes, uint256 abstainVotes); 

    function hasRoleSince(address user, uint64 roleId) external returns (uint48 since); 

    function canCall(address caller, address targetLaw) external returns (bool canCall); 

} 