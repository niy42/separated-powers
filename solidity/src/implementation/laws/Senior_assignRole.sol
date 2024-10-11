// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Law} from "../../Law.sol";

/**
 * @notice Example Law contract. 
 * 
 * @dev In this contract...
 *
 *  
 */
contract Senior_assignRole is Law {
    error Senior_assignRole__Error(); 

    address public agCoins; 
    uint256 agCoinsReward = 150_000; 
    
    constructor(address payable agDao, address agCoins_) // can take a address parentLaw param. 
      Law(
        "Senior_assignRole", // = name
        "Seniors can assign accounts to availabke senior role. A maximum of ten holders can be assigned. If passed the proposer receives a reward in agCoins", // = description
        1, // = access PUBLIC_ROLE
        agDao, // = SeparatedPower.sol derived contract. Core of protocol.   
        50, // = no quorum, means no vote. 
        66, // = succeedAt
        3_600, // votingPeriod_ in blocks, On arbitrum each block is about .5 (half) a second. This is about half an hour. 
        address(0) // = parent Law 
    ) {
      agCoins = agCoins_; 
    } 

    function executeLaw(
      bytes memory lawCalldata
      ) external virtual {  

      // step 0: check if caller has correct access control.
      if (SeparatedPowers(payable(agDao)).hasRoleSince(msg.sender, accessRole) == 0) {
        revert Law__AccessNotAuthorized(msg.sender);
      }

      // step 1: decode the calldata. Note: lawCalldata can have any format. 
      (address newSenior, bytes32 descriptionHash) = abi.decode(lawCalldata, (address, bytes32));

      // step 2:  check if newSenior is already a member and if the maximum amount of seniors has already been met.  
      if (SeparatedPowers(payable(agDao)).hasRoleSince(msg.sender, accessRole) == 0) {
        revert Law__AccessNotAuthorized(msg.sender);
      }

      if (requiredDescriptionHash != descriptionHash) {
        revert Member_assignRole__IncorrectRequiredStatement();
      }

      // step 3 : creating data to send to the execute function of agDAO's SepearatedPowers contract.
      address[] memory targets = new address[](1);
      uint256[] memory values = new uint256[](1); 
      bytes[] memory calldatas = new bytes[](1);

      // action 1: add membership role to applicant. 
      targets[0] = agDao;
      values[0] = 0;
      calldatas[0] = abi.encodeWithSelector(0xd2ab9970, 1, newSenior, true); // = setRole(uint64 roleId, address account, bool access); 

      // step 4: call {SeparatedPowers.execute} If reuiqrement is accepted, whale will get an amount of agCoins and new requirement will be included in the agDAO. 
      // note, call goes in following format: (address /* proposer */, bytes memory /* lawCalldata */, address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 /*descriptionHash*/)
      SeparatedPowers(daoCore).execute(msg.sender, lawCalldata, targets, values, calldatas, descriptionHash);
  }

  // error ExecutiveLaw__CallNotImplemented(); 

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
  // function execute external (
  //   bytes memory callData
  //   ) public checkAuthorized(separatedPowers) { 

  //   // (address[] targets, uint256[] values, bytes[] memory calldatas, bytes32 descriptionHash) =
  //   //         abi.decode(callData, (address[], uint256[], bytes[], bytes32));

  //   revert ExecutiveLaw__CallNotImplemented(); 
  // } 

  // /**
  //  * execute function with proposalId. 
  //  * this allows for checking if linked proposalId (and related content) has been subject to a vote. 
  //  */
  // function execute external (
  //   bytes memory callData
  //   uint256 proposalId
  //   ) public checkAuthorized(separatedPowers) { 

  //   // (address[] targets, uint256[] values, bytes[] memory calldatas, bytes32 descriptionHash) =
  //   //      abi.decode(callData, (address[], uint256[], bytes[], bytes32));

  //   revert ExecutiveLaw__CallNotImplemented();   
  // } 
  
  

}
