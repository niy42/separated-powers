// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "../lib/openzeppelin-contracts/contracts/utils/ShortStrings.sol";
import {ILaw} from "./interfaces/ILaw.sol"; 
import {EIP712} from "../lib/openzeppelin-contracts/contracts/utils/cryptography/EIP712.sol";
import {ERC165} from "lib/openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";
import {IERC165} from "lib/openzeppelin-contracts/contracts/utils/introspection/IERC165.sol";

/**
 * @notice Base implementation of a Law in the SeparatedPowers protocol. It is meant to be inherited by law implementations. 
 *
 * @dev A law has the following characteristics: 
 * - It is only accesible to one roleId. 
 * - It gives accounts who hold this roleId the privilege to call specific outside functions.
 * - It constrains these privileges with specific conditions, for instance a proposal to a specific other law needs to have passed.
 * 
 * @dev See the natspecs at the constructor function for the specific of what can be defined inside a law. 
 *
 * @author 7Cedars, Oct 2024 RnDAO CollabTech Hackathon
 *  
 */
contract Law is IERC165, ERC165, EIP712 {
  using ShortStrings for *;

  error Law__AccessNotAuthorized(address caller);  
  error Law__CallNotImplemented(); 

  string private _nameFallback;

  ShortString public immutable name;
  uint64 public immutable accessRole; // note: only allows single roleId. 
  uint8 public immutable quorum; // in percent.  
  uint8 public immutable succeedAt; // in percent.  
  uint32 public immutable votingPeriod;  // voting period in blocks. The contract does not use clock(), for now.  
  address public immutable separatedPowers; // address to related separatedPower contract. Laws cannot be shared between them. They have to be re-initialised through a constructor function.  
  string public description; // note: any length. 
  string constant version = "1";  

  /**
  * @dev Constructor function for Law contract. 
  * 
  * @param name_ Name of the law. Cannot be longer than 31 characters. 
  * @param description_ Description of the law. Any length.  
  * @param accessRole_ The uint64 identifier of the roleId that has access to this law. 
  * @param quorum_ quorum of votes needed to pass a vote (as percentage of accounts holding roleId). If set to 0, law can be executed without vote. 
  * @param succeedAt_  support votes needed to pass execution of law (as percentage of accounts holding roleId). If quorum_ is set to 0, this value is meaningless.   
  * @param votingPeriod_  number of blocks that the vote is open for, from the moment that the proposal is created. If quorum_ is set to 0, this value is meaningless. 
  * @param separatedPowers_ The address of the SeparatedPowers contract that will call this Law and that it will call the function execute at.    
  *  
  */
  constructor(
    string memory name_, 
    string memory description_, 
    uint64 accessRole_, 
    uint8 quorum_ , 
    uint8 succeedAt_ ,  
    uint32 votingPeriod_ ,
    address separatedPowers_
    ) EIP712(name_, version) {
      name = name_.toShortString();
      description = description_; 
      accessRole = accessRole_; 
      quorum = quorum_;
      succeedAt = succeedAt_; 
      votingPeriod = votingPeriod_;
      separatedPowers = separatedPowers_; 
  }

  /**
   * @dev See {ILaw-executeLaw}. 
   */
  function executeLaw(bytes memory callData) external virtual {
    revert Law__CallNotImplemented(); 
  }

  /**
   * @dev See {ILaw-executeLaw}. 
   */
  function executeLaw(bytes memory callData, uint256 proposalId) external virtual {
    revert Law__CallNotImplemented(); 
  }

  /**
   * @dev See {IERC165-supportsInterface}.
   */
  function supportsInterface(bytes4 interfaceId) public view override(ERC165, IERC165) returns (bool) {
     return interfaceId == type(ILaw).interfaceId || super.supportsInterface(interfaceId);
  }

}



