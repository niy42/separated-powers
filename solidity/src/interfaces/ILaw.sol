// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @dev TBI: contract Executive Law. 
 * I can opt to follow OpenZeppelin with including most descriptions in the interface, not the actual contract. 
 *  
 */
interface ILaw {

  function executeLaw external (bytes memory callData); 
  function executeLaw external (bytes memory callData, uint256 proposalId);

}
