// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @notice Interface for managing Roles and . Derived from OpenZeppelin's GovernorCountingSimple.sol. 
 * @dev See the [OpenZeppelinGovernorCountingSimple](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/governance/extensions/GovernorCountingSimple.sol)
 *
 * @author 7Cedars, Oct 2024 RnDAO CollabTech Hackathon 
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

    /**
     * @dev Keeps track of the votes for each proposal.
     */
    struct ProposalVote {
        uint256 againstVotes;
        uint256 forVotes;
        uint256 abstainVotes;
        mapping(address voter => bool) hasVoted;
    }
    
    /**
    * @dev struct keeping track of 1) account acceess to role and 2) total amount of members of role.
    */
    struct Role {
        // Members of the role.
        mapping(address account => uint48 since) members;
        uint256 amountMembers; 
    }
    
    /**
     * @dev Emitted when a role is set.
     */
    event RoleSet(uint64 indexed roleId, address indexed account, bool indexed accessChanged); 

    /**
     * @notice set role access.
     * 
     * @param roleId role identifier
     * @param account account address
     * @param access access
     *  
     * @dev this function can only be called from the execute function of SeperatedPowers.sol. 
     */
    function setRole(uint64 roleId, address account, bool access) external; 
  
    /**
    * @notice Checks if account has voted for a proposal.
    * 
    * @dev Returns true if the role has been voted for a proposal.
    *
    * @param proposalId id of the proposal.
    * @param account address of the account to check.
    */
    function hasVoted(uint256 proposalId, address account) external returns (bool);
    
    /**
    * @notice Returns the number of against, for, and abstain votes for a proposal.
    * 
    * @param proposalId id of the proposal.
    */
    function proposalVotes(uint256 proposalId) external returns (uint256 againstVotes, uint256 forVotes, uint256 abstainVotes); 

    /**
    * @notice returns the block number since the account has held the role. Returns 0 if account does not currently hold the role. 
    *
    * @param account account address
    * @param roleId role identifier
    */
    function hasRoleSince(address account, uint64 roleId) external returns (uint48 since); 

    /**
    * @notice checks if account can call a law.
    *
    * @param caller caller address
    * @param targetLaw law address to check.
    *
    */
    function canCallLaw(address caller, address targetLaw) external returns (bool canCall); 

} 