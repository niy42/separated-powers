// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Law} from "./Law.sol"
import {IAdministrative} from "./IAdministrative.sol"

/**
 * @dev TBI: contract Executive Law. 
 *  
 */
contract Administrative is Law, IAdministrative {

  error AdministrativeLaw__CallNotImplemented(); 

  /**
   * checkProposal function without proposalId. 
   * this allows a chain of votes to be initated. 
   * It enables checks and balances of power within a DAO.   
   */
  function checkProposal external (
    address separatedPowers, 
    address[] memory targets,
    uint256[] memory values,
    bytes[] memory calldatas,
    bytes32 descriptionHash
    ) public checkAuthorized(separatedPowers) { 

    revert AdministrativeLaw__CallNotImplemented();   

  } 

  /**
   * checkProposal function with proposalId. 
   * this allows a vote on a proopsal that has already been voted on. 
   * It enables checks and balances of power within a DAO.   
   */
  function checkProposal external (
    address separatedPowers, 
    address[] memory targets,
    uint256[] memory values,
    bytes[] memory calldatas,
    bytes32 descriptionHash, 
    uint256 parentProposalId
    ) public checkAuthorized(separatedPowers) { 

    revert AdministrativeLaw__CallNotImplemented();   

  } 
   
}
