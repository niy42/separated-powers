// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @dev 
 *  
 */
interface ILawsManager {
  error LawsManager_NotAuthorized(); 

  event LawSet(address indexed law, bool indexed active, bool indexed lawChanged); 

  function setLaw(address law, bool active) external; 

  function getActiveLaw(address law) external returns (bool active); 
}
