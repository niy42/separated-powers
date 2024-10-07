// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Law} from "./Law.sol"
import {IExecutive} from "./IExecutive.sol"
import {SeparatedPowers} from "../SeparatedPowers.sol"

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

    /**
    * Example usage: 

    abi.encode( 
    )
    
    SeparatedPowers(separatedPowers).execute(
      address[] memory targets,
      uint256[] memory values,
      bytes[] memory calldatas
    )
    
    */ 
  function execute external (
    bytes memory callData
    ) public checkAuthorized(separatedPowers) { 

    // (address[] targets, uint256[] values, bytes[] memory calldatas, bytes32 descriptionHash) =
    //         abi.decode(callData, (address[], uint256[], bytes[], bytes32));

    revert ExecutiveLaw__CallNotImplemented(); 
  } 

  /**
   * execute function with proposalId. 
   * this allows for checking if linked proposalId (and related content) has been subject to a vote. 
   */
  function execute external (
    bytes memory callData
    uint256 proposalId
    ) public checkAuthorized(separatedPowers) { 

    // (address[] targets, uint256[] values, bytes[] memory calldatas, bytes32 descriptionHash) =
    //      abi.decode(callData, (address[], uint256[], bytes[], bytes32));

    revert ExecutiveLaw__CallNotImplemented();   
  } 
  
  

}
