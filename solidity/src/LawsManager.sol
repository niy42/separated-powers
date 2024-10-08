// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {ILawsManager} from "./interfaces/ILawsManager.sol"; 

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
contract LawsManager is ILawsManager {
  mapping(address law => bool active) public activeLaws; 

  /* FUNCTIONS: */
  /* public */
  /**
  * NB! IF I check for correct type of law + if law is active -- the access control should be handled by the Law. NOT by governance contract. 
   */
  function setLaw(address law, bool active) public { 
    // this function can only be called from the execute function  of SeperatedPowers with a .call call. 
    // As such, there is a msg.sender, but it always has to come form address (this).  
    if (msg.sender != address(this)) { 
      revert LawsManager_NotAuthorized();  
    }
    // CHECK: call from executive Law? 
    // CHECK: executive law active in address(this)?  
    _setLaw(law, active);
  } 

  /* internal */
  function _setLaw(address law, bool active) internal virtual returns (bool lawChanged) { 
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