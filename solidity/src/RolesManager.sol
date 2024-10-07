// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Context} from "@openzeppelin/contracts/utils/Context.sol";

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
contract RolesManager is Context {
    // errors //
    error RolesManager_InvalidInitialAdmin(address invalidAddress);
    error RolesManager_LockedRole(uint64 roleId)

    // Structure that stores the details of a role.
    struct Role {
        // Members of the role.
        mapping(address user => uint48 since) members;
        uint256 amountMembers; 
    }

    mapping(uint64 roleId => Role) private _roles;

    uint64 public constant ADMIN_ROLE = type(uint64).min; // 0
    uint64 public constant PUBLIC_ROLE = type(uint64).max; // 2**64-1

    /* Events */
    event RoleSet(uint64 indexed roleId, address indexed account, bool indexed accessChanged);


    // modifiers // 
    /**
     * @dev Check that the caller is authorized to perform the operation.
     * See {AccessManager} description for a detailed breakdown of the authorization logic.
     * NB: I might want to use this in the main separated-powers contract. Keep. Do not take out. 
     */
    modifier onlyAuthorized() {
        _checkAuthorized();
        _;
    }

    constructor(address initialAdmin) {
        if (initialAdmin == address(0)) {
            revert RolesManager_InvalidInitialAdmin(address(0));
        }

        // admin is active immediately.
        _grantRole(ADMIN_ROLE, initialAdmin, 0, 0); // this
    }

    // getters //
    /**
    * £TODO: implement together with implementing laws. 
    * Note: does NOT check if law is actually active in the governance contract. It purely checks if roleId can call a particular law contract. 
    *
    */ 
    function canCall(
        address caller,
        address target
    ) public view virtual returns (uint48 since) {
        // £todo step 1: check for signatures: are they laws?
        // if not, revert.   
        if (isTargetLaw(target)) {
            return (false, 0);
        // step 2: check if RoleID of law is correct/ 
        } else {
            uint64 roleId = getTargetLawRole(target);
            return hasRoleSince(roleId, caller);
        }
    }

    /// @inheritdoc IAccessManager
    function setRole(uint64 roleId, address account, bool access) public virtual onlyAuthorized {
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

        bool newMember = _roles[roleId].members[account] == 0;
        bool accessChanged;  

        if (access && newMember) {
            _roles[roleId].members[account] = block.number; 
            _roles[roleId].amountMembers++; 
            accessChanged = true; 
        } else if (!access && !newMember)  {
          _roles[roleId].members[account] = 0;
          _roles[roleId].amountMembers +-; // NB! CHECK IF THIS WORKS 
          accessChanged = true;
        }

        emit RoleSet(roleId, account, accessChanged);
        return accessChanged;
    }

    function _checkAuthorized(address targetLaw) private {
        address caller = _msgSender();
        // £todo; have to complete this when completing laws infra. 
            // if (delay == 0) {
            //     (, uint64 requiredRole, ) = _getAdminRestrictions(_msgData());
            //     revert RolesManager_UnauthorizedAccount(caller, requiredRole);
        // }
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
