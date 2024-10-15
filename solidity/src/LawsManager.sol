// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {ILawsManager} from "./interfaces/ILawsManager.sol"; 

 /**
 * @notice Contract to manage laws in the SeparatedPowers protocol. 
 *
 * @dev This libary only manages setting law address to true and false + some getters. 
 * Laws are contracts of their own that need to be deployed through their own constructor functions. 
 * for now, this is just super simple. More complexity will be added later. 
 *  
 */
contract LawsManager is ILawsManager {
  mapping(address law => bool active) public activeLaws; 

  /**
  * @dev {see ILawsManager.setLaw} 
  */
  function setLaw(address law, bool active) public { 

    if (msg.sender != address(this)) { 
      revert LawsManager_NotAuthorized();  
    }
    _setLaw(law, active);
  } 

  /**
  * @notice internal function to set a law to active or inactive.
  * 
  * @param law address of the law.
  * @param active bool to set the law to active or inactive.
  *
  * @dev this function can only be called from the execute function of SeperatedPowers.sol. 
  * 
  * returns bool lawChanged, true if the law is set as active.
  *
  * emits a LawSet event. 
  */
  function _setLaw(address law, bool active) internal virtual returns (bool lawChanged) { 
    lawChanged = (activeLaws[law] != active); 
    if (lawChanged) activeLaws[law] = active; 

    emit LawSet(law, active, lawChanged);
    return lawChanged; 
  } 

  /**
  * @dev {see ILawsManager.getActiveLaw} 
  */
  function getActiveLaw(address law) external view returns (bool active) { 
    return activeLaws[law]; 
  }
}