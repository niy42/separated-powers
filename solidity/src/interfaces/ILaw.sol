// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @notice interface for law contracts.  
 */
interface ILaw {
    
  /**
  * @param callData call data to be executed. 
  */ 
  function executeLaw (bytes memory callData) external; 
  
  /**
  * @param callData call data to be executed.
  * @param proposalId id of the proposal.
  */
  function executeLaw (bytes memory callData, uint256 proposalId) external;

}
