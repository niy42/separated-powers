// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Law} from "../../Law.sol";
import {SeparatedPowers} from "../../SeparatedPowers.sol";
import {ISeparatedPowers} from "../../interfaces/ISeparatedPowers.sol";

/**
 * @notice Example Law contract. 
 * 
 * @dev In this contract...
 *
 *  
 */
contract Member_challengeRevoke is Law {
    error Member_challengeRevoke__IncorrectRequiredStatement(); 
    error Member_challengeRevoke__TargetProposalNotExecuted(uint256 proposalId); 

    string private requiredStatement = "I challenge the revoking of my membership to agDAO.";
    address public agDao;  
    
    constructor(address payable agDao_, address Whale_revokeMember) // can take a address parentLaw param. 
      Law(
        "Member_assignRole", // = name
        "Any account that has been revoked can challenge this decision by sending a message and the data of the revoke decision to the agDAO.", // = description
        type(uint64).max, // = access PUBLIC_ROLE
        agDao_, // = SeparatedPower.sol derived contract. Core of protocol.   
        0, // = no quorum, means no vote. 
        0, // = succeedAt
        0, // votingPeriod_ in blocks, On arbitrum each block is about .5 (half) a second. This is about half an hour. 
        Whale_revokeMember // = no parent Law
    ) {
      agDao = agDao_;
    } 

    function executeLaw(
      bytes memory lawCalldata
      ) external override {  

      // step 0: note: access control absent. Any one can call this law. 

      // step 1: decode the calldata. Note: lawCalldata can have any format. 
      bytes32 requiredDescriptionHash = keccak256(bytes(requiredStatement)); 
      (bytes32 descriptionHash, bytes32 revokeDescriptionHash, bytes memory revokeCalldata) = abi.decode(lawCalldata, (bytes32, bytes32, bytes));
      if (requiredDescriptionHash != descriptionHash) {
        revert Member_challengeRevoke__IncorrectRequiredStatement();
      }

      uint256 proposalId = hashProposal(parentLaw, revokeCalldata, revokeDescriptionHash);
      if (SeparatedPowers(payable(agDao)).state(proposalId) != ISeparatedPowers.ProposalState.Executed) {
        revert Member_challengeRevoke__TargetProposalNotExecuted(proposalId);
      }

      // Note this 'executeLaw' function does not have a call to the execute function of the coreDA) contract. 
      // In this case the only important thing is that a complaint is logged in the form of a proposal that automatically succeeds because the quorum is set to 0.  
    }

}
