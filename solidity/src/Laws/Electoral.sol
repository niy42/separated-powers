// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Law} from "./Law.sol"
import {IElectoral} from "./IExecutive.sol"

/**
 * @dev TBI: contract Executive Law. 
 *  
 */
contract Electoral is Law, IElectoral {

  error ElectoralLaw__CallNotImplemented(); 

  /**
   * elect function without proposalId. 
   * this allows for direct execution of governance actions, skipping a vote.  
   */
  function elect external (
    address separatedPowers, 
    address[] memory users,
    bytes[] memory roleIds,
    bytes32 descriptionHash 
    ) public checkAuthorized(separatedPowers) { 

    revert ElectoralLaw__CallNotImplemented(); 
  } 

  /**
   * elect function with proposalId. 
   * this allows for checking if linked proposalId (and related content) has been subject to a vote. 
   */
  function elect external (
    address separatedPowers, 
    address[] memory users,
    bytes[] memory roleIds,
    bytes32 descriptionHash 
    uint256 proposalId
    ) public checkAuthorized(separatedPowers) { 

    revert ElectoralLaw__CallNotImplemented();   
  } 

}
