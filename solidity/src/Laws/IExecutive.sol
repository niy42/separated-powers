// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @dev TBI: contract Executive Law. 
 * I can opt to follow OpenZeppelin with including most descriptions in the interface, not the actual contract. 
 *  
 */
interface IExecutive {

  function execute external (
    address separatedPowers, 
    address[] memory targets,
    uint256[] memory values,
    bytes[] memory calldatas,
    bytes32 descriptionHash 
    ); 

  function execute external (
    address separatedPowers, 
    address[] memory targets,
    uint256[] memory values,
    bytes[] memory calldatas,
    bytes32 descriptionHash, 
    uint256 proposalId
    );

}
