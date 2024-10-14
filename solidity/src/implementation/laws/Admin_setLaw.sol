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
 contract Admin_setLaw is Law {
    error Senior_acceptProposedLaw__ParentProposalNotExecuted(uint256 parentProposalId); 
    error Senior_acceptProposedLaw__ProposalNotExecuted(proposalId); 

    address public agDao;  
    
    constructor(address payable agDao_, address Senior_acceptProposedLaw) // can take a address parentLaw param. 
      Law(
        "Senior_acceptProposedLaw", // = name
        "Seniors can accept to activate or deactive laws as propised by whales.", // = description
        0, // = access roleId = ADMIN 
        agDao_, // = SeparatedPower.sol derived contract. Core of protocol.   
        0, // = quorum
        0, // = succeedAt
        0, // votingPeriod_ in blocks, On arbitrum each block is about .5 (half) a second. This is about half an hour. 
        Senior_acceptProposedLaw // = parent Law 
    ) {
      agDao = agDao_;
    } 

    function executeLaw(
      bytes memory lawCalldata
      ) external override {  

      // step 0: check if caller has correct access control.
      if (SeparatedPowers(payable(agDao)).hasRoleSince(msg.sender, accessRole) == 0) {
        revert Law__AccessNotAuthorized(msg.sender);
      }

      // step 1: decode the calldata. Note: lawCalldata can have any format. 
      (address law, bool toInclude, bytes32 parentDescriptionHash, bytes32 descriptionHash) =
            abi.decode(lawCalldata, (address, bool, bytes32, bytes32));

      // step 2: check if parent proposal has been executed. 
      uint256 parentProposalId = hashProposal(parentLaw, abi.encode(law, toInclude), parentDescriptionHash);
      if (SeparatedPowers(payable(agDao)).state(parentProposalId) != ISeparatedPowers.ProposalState.Completed) {
        revert Senior_acceptProposedLaw__ParentProposalNotExecuted(parentProposalId);
      }

      // step 3: Note : check if proposal succeeded is absent. This law does not require a proposal to be set or a vote to pass - it can be executed directly by the Admin. 
      
      // step 4: creating data to send to the execute function of agDAO's SepearatedPowers contract.
      address[] memory targets = new address[](1);
      uint256[] memory values = new uint256[](1); 
      bytes[] memory calldatas = new bytes[](1);

      targets[0] = agDao; 
      values[0] = 0;
      calldatas[0] = abi.encodeWithSelector(0xd55a5cc6, law, toInclude);

      // step 5: call {SeparatedPowers.execute}
      // note, call goes in following format: (address proposer, bytes memory lawCalldata, address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash)
      SeparatedPowers(daoCore).execute(msg.sender, lawCalldata, targets, values, calldatas, descriptionHash);
      
  }
}
