// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Law} from "./Law.sol"
import {IExecutive} from "./IExecutive.sol"

/**
 * @dev TBI: contract Executive Law. 
 *  
 */
contract Executive is Law, IExecutive {

  error ExecutiveLaw__CallNotImplemented(); 

  /**
   * execute function without proposalId. 
   * this allows for direct execution of governance actions, skipping a vote.  
   */
  function execute external (
    address separatedPowers, 
    address[] memory targets,
    uint256[] memory values,
    bytes[] memory calldatas,
    bytes32 descriptionHash 
    ) public checkAuthorized(separatedPowers) { 

    revert ExecutiveLaw__CallNotImplemented(); 
  } 

  /**
   * execute function with proposalId. 
   * this allows for checking if linked proposalId (and related content) has been subject to a vote. 
   */
  function execute external (
    address separatedPowers, 
    address[] memory targets,
    uint256[] memory values,
    bytes[] memory calldatas,
    bytes32 descriptionHash, 
    uint256 proposalId
    ) public checkAuthorized(separatedPowers) { 

    revert ExecutiveLaw__CallNotImplemented();   
  } 
  
  

}
