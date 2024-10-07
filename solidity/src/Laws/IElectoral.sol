// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @dev TBI: contract Executive Law. 
 *  
 */
interface IElectoral {
  
  /**
   * elect function without proposalId. 
   * this allows for direct execution of governance actions, skipping a vote.  
   */
  function elect external (
    address separatedPowers, 
    address[] memory users,
    bytes[] memory roleIds,
    bytes32 descriptionHash 
  ); 

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
  );

}
