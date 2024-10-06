// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;


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
 * 
 */
contract RolesManager {

  // NB! £todo constructor should take initial ADMIN role. 
  // 
  // /**
  //    * @dev Sets the value for {name} and {version}
  //    */
  //   constructor() {
  //   }
  
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