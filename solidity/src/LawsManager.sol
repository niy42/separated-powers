// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @dev TBI: contract managing LAws. 
 *
 * Note 1: Naming conventions followed from OpenZeppelin.  
 * 
 * This libary only manages setting law address to true and false + some getters. 
 * Laws are contracts of their own that need to be deployed through their own constructor functions. 
 * for now, this is just super simple. More complexity will be added later. 
 *  
 */
contract LawsManager {
  /* Type declarations */

  /* State variables */
  mapping(address law => bool active) public activeLaws; 

  /* Events */
  event LawSet(address indexed law, bool indexed active, bool indexed lawChanged); 

  /* FUNCTIONS: */
  /* public */
  /**
  * NB! IF I check for correct type of law + if law is active -- the access control should be handled by the Law. NOT by governance contract. 
   */
  function setLaw(address law, bool active) public { 
    // CHECK: call from executive Law? 
    // CHECK: executive law active in address(this)?  
    _setLaw(address law, bool active);
  } 

  /* internal */
  function _setLaw(address law, bool active) internal virtual { 
    bool lawChanged; 
    lawChanged = activeLaws[law] == active; 

    if (lawChanged) activeLaws[law] = active; 

    emit LawSet(law, active, lawChanged);
    return lawChanged; 
  } 

  /* getters */
  function getActiveLaw(address law) external view returns (bool active) { 
    return activeLaws[law]; 
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