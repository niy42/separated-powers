// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "../lib/openzeppelin-contracts/contracts/utils/ShortStrings.sol";
import {SeparatedPowers} from "./SeparatedPowers.sol";
import {ISeparatedPowers} from "./interfaces/ISeparatedPowers.sol";
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
 * @dev See the natspecs at the constructor function for the specifics of what can be (optionally) defined inside a law. 
 *
 * @author 7Cedars, Oct 2024 RnDAO CollabTech Hackathon
 *  
 */
contract Law is IERC165, ERC165, EIP712, ILaw {
  using ShortStrings for *;

  error Law__AccessNotAuthorized(address caller);  
  error Law__CallNotImplemented(); 
  error Law__InvalidLengths(uint256 lengthTargets, uint256 lengthCalldatas); 
  error Law__TargetLawNotPassed(address targetLaw);

  string private _nameFallback;

  ShortString public immutable name;
  uint64 public immutable accessRole; // note: only allows single roleId. 
  uint8 public immutable quorum; // in percent.  
  uint8 public immutable succeedAt; // in percent.  
  uint32 public immutable votingPeriod;  // voting period in blocks. The contract does not use clock(), for now.  
  address payable public immutable separatedPowers; // address to related separatedPower contract. Laws cannot be shared between them. They have to be re-initialised through a constructor function.  
  address public parentLaw; // address to law that need to pass before this law can pass. 
  string public description; // note: any length. 
  string constant version = "1";  

  /**
  * @dev Constructor function for Law contract. 
  * 
  * @param name_ Name of the law. Cannot be longer than 31 characters. 
  * @param description_ Description of the law. Any length.  
  * @param accessRole_ The uint64 identifier of the roleId that has access to this law. 
  * @param separatedPowers_ The address of the SeparatedPowers contract that will call this Law and that it will call the function execute at. 
  * optionalParam checkedLaw_ The address of the Law that is checked before the execution of the Law.
  * optionalParam quorum_ quorum of votes needed to pass a vote (as percentage of accounts holding roleId). If set to 0, law can be executed without vote. 
  * optionalParam succeedAt_  support votes needed to pass execution of law (as percentage of accounts holding roleId). If quorum_ is set to 0, this value is meaningless.   
  * optionalParam votingPeriod_  number of blocks that the vote is open for, from the moment that the proposal is created. If quorum_ is set to 0, this value is meaningless. 
  *  
  */
  constructor(
    string memory name_, 
    string memory description_, 
    uint64 accessRole_, 
    address payable separatedPowers_
    // following params are optional 
    // uint8 quorum_ , 
    // uint8 succeedAt_ ,  
    // uint32 votingPeriod_ ,
    // address parentLaw_
    ) EIP712(name_, version) {
      name = name_.toShortString();
      description = description_; 
      accessRole = accessRole_; 
      separatedPowers = separatedPowers_;
      // checkedLaws = checkedLaw_; 
      // quorum = quorum_;
      // succeedAt = succeedAt_; 
      // votingPeriod = votingPeriod_;
  }

  /**
   * @dev See {ILaw-executeLaw}.
   * 
   * @param lawCalldata any data needed to execute the law. 
   * 
   * @dev this function needs to be overwritten with the custom logic of the law. 
   * 
   */
  function executeLaw(
    bytes memory lawCalldata
    ) external virtual {  
      
      revert Law__CallNotImplemented(); // acts as a blocker so that the function will not get executed.
      
      /* everything below is an example of how to implement laws. */   

      // step 0: check if caller has correct access control.
      // if (SeparatedPowers(payable(separatedPowers)).hasRoleSince(msg.sender, accessRole) == 0) {
      //   revert Law__AccessNotAuthorized(msg.sender);
      // }

      // // step 1: decode the calldata.
      // // Note: lawCalldata can have any format. 
      // (address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash) =
      //      abi.decode(lawCalldata, (address[], uint256[], bytes[], bytes32));

      // // step 2 : check lengths.
      // if (targets.length != calldatas.length || targets.length == 0) {
      //   revert Law__InvalidLengths(targets.length, calldatas.length);
      // }

      // // Note step 3: if a parentLaw is exists, check if the parentLaw has succeeded or has executed.
      // if (parentLaw != address(0)) {
      //   uint256 parentProposalId = hashProposal(parentLaw, lawCalldata, descriptionHash); 
      //   ISeparatedPowers.ProposalState parentState = SeparatedPowers(payable(separatedPowers)).state(parentProposalId);

      //   if (
      //     parentState != ISeparatedPowers.ProposalState.Executed || 
      //     parentState != ISeparatedPowers.ProposalState.Succeeded
      //     ) {
      //     revert Law__TargetLawNotPassed(parentLaw);
      //   }
      // }

      // // step 4: call {SeparatedPowers.execute}
      // // note: a call to SeparatedPower.execute always has the same params: 
      // // (uint256 /* proposalId */, address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 /*descriptionHash*/)
      // SeparatedPowers(separatedPowers).execute(msg.sender, lawCalldata, targets, values, calldatas, descriptionHash);
  }

  /**
   * @dev See {IERC165-supportsInterface}.
   */
  function supportsInterface(bytes4 interfaceId) public view override(ERC165, IERC165) returns (bool) {
     return interfaceId == type(ILaw).interfaceId || super.supportsInterface(interfaceId);
  }

  
  /**
    * @dev see {ISeperatedPowers.hashProposal}
    */
  function hashProposal(
      address targetLaw, 
      bytes memory lawCalldata,
      bytes32 descriptionHash
  ) internal pure virtual returns (uint256) {
      return uint256(keccak256(abi.encode(targetLaw, lawCalldata, descriptionHash)));
  }

}



