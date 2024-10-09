// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @notice interface for law contracts.  
 *
 * @author 7Cedars, Oct 2024 RnDAO CollabTech Hackathon
 */
interface ILawsManager {
  error LawsManager_NotAuthorized(); 

  event LawSet(address indexed law, bool indexed active, bool indexed lawChanged); 

  /**
  * @notice set a law to active or inactive.
  * 
  * @dev 
  * @param law address of the law.
  * @param active bool to set the law to active or inactive.
  *
  * @dev this function can only be called from the execute function of SeperatedPowers.sol. 
  */
  function setLaw(address law, bool active) external; 

  /**
   * @notice returns bool if law is set as active or not. (true = active, false = inactive).   
   * @param law address of the law.
   */
  function getActiveLaw(address law) external returns (bool active); 
}
