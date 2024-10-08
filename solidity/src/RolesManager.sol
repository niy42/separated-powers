// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Law} from "./Law.sol";

/**
 * @dev TBI: Description contract.
 *
 * Note: Where applicable, code taken from OpenZeppelin's AccessManager.sol contract.
 * Note 2: Naming conventions followed from OpenZeppelin.
 *
 * Note, changes in comparison to AccessManager.sol
 * Original manages functions, not contracts.
 * Relationship between this contract and children very different. Originally the parent contracts sets access of child functions.
 * Here the contract only stores available roles, and manages adding & revoking roles.
 * this is because the original contract also managed the execution of function. This is not the case with this contract.
 * Everything todo with delay, schedule was excluded.
 *
 */
abstract contract RolesManager {
    // errors //
    error RolesManager_NotAuthorized(address invalidAddress);
    error RolesManager_InvalidInitialAdmin(address invalidAddress);
    error RolesManager_LockedRole(uint64 roleId);

    // Structure that stores the details of a role.
    struct Role {
        // Members of the role.
        mapping(address user => uint48 since) members;
        uint256 amountMembers; 
    }

    mapping(uint64 roleId => Role) public roles;

    uint64 public constant ADMIN_ROLE = type(uint64).min; // 0
    uint64 public constant PUBLIC_ROLE = type(uint64).max; // 2**64-1

    /* Events */
    event RoleSet(uint64 indexed roleId, address indexed account, bool indexed accessChanged);

    /* FUNCTIONS */ 
    function setRole(uint64 roleId, address account, bool access) public virtual {
      // this function can only be called from the execute function  of SeperatedPowers with a .call call. 
      // As such, there is a msg.sender, but it always has to come form address (this).  
      if (msg.sender != address(this)) { 
        revert RolesManager_NotAuthorized();  
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
            revert RolesManager_LockedRole(roleId);
        }

        bool newMember = roles[roleId].members[account] == 0;
        bool accessChanged;  

        if (access && newMember) {
            roles[roleId].members[account] = block.number; 
            roles[roleId].amountMembers++; 
            accessChanged = true; 
        } else if (!access && !newMember)  {
          roles[roleId].members[account] = 0;
          roles[roleId].amountMembers += -1; // NB! CHECK IF THIS WORKS 
          accessChanged = true;
        }

        emit RoleSet(roleId, account, accessChanged);
        return accessChanged;
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
