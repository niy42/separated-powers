// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

// import {Law} from "./Law.sol"
// import {IElectoral} from "./IExecutive.sol"

/**
 * @dev TBI: contract Executive Law. 
 *  
 */
contract Electoral {

  // error ElectoralLaw__CallNotImplemented(); 

  // /**
  //  * elect function without proposalId. 
  //  * this allows for direct execution of governance actions, skipping a vote.  
  //  */
  // function elect external (
  //   bytes memory callData
  //   ) public checkAuthorized(separatedPowers) { 

  //   // (address[] users, uint64[] roleIds, bytes32 descriptionHash) =
  //   //         abi.decode(callData, (address[], uint64[], bytes32));

  //   revert ElectoralLaw__CallNotImplemented(); 
  // } 

  // /**
  //  * elect function with proposalId. 
  //  * this allows for checking if linked proposalId (and related content) has been subject to a vote. 
  //  */
  // function elect external (
  //   bytes memory callData,
  //   uint256 proposalId
  //   ) public checkAuthorized(separatedPowers) { 

  //   // (address[] users, uint64[] roleIds, bytes32 descriptionHash) =
  //   //         abi.decode(callData, (address[], uint64[], bytes32));

  //   revert ElectoralLaw__CallNotImplemented();   
  // } 

}
