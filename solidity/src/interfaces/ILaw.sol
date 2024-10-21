// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @notice interface for law contracts.  
 */
interface ILaw {
    
  /**
  * @param lawCallData call data to be executed. 
  */ 
  function executeLaw (bytes memory lawCallData) external; 


}
