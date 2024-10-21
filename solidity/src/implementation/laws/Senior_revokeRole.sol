// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Law} from "../../Law.sol";
import {SeparatedPowers} from "../../SeparatedPowers.sol";
import {ISeparatedPowers} from "../../interfaces/ISeparatedPowers.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @notice Example Law contract. 
 * 
 * @dev In this contract...
 *
 *  
 */
contract Senior_revokeRole is Law {
    error Senior_revokeRole__NotASenior();
    error Senior_revokeRole__ProposalVoteNotPassed(uint256 proposalId);

    address public agCoins; 
    address public agDao;
    uint256 agCoinsReward = 60_000;
    
    constructor(address payable agDao_, address agCoins_) // can take a address parentLaw param. 
      Law(
        "Senior_revokeRole", // = name
        "Senior role can be revoked by large majority vote. If passed the proposer receives a reward in agCoins", // = description
        1, // = access senior
        agDao_, // = SeparatedPower.sol derived contract. Core of protocol.   
        80, // = quorum 
        80, // = succeedAt
        3_600, // votingPeriod_ in blocks, On arbitrum each block is about .5 (half) a second. This is about half an hour. 
        address(0) // = parent Law 
    ) {
      agDao = agDao_;
      agCoins = agCoins_; 
    } 

    function executeLaw(
      bytes memory lawCalldata
      ) external override {  

      // step 0: check if caller has correct access control.
      if (SeparatedPowers(payable(agDao)).hasRoleSince(msg.sender, accessRole) == 0) {
        revert Law__AccessNotAuthorized(msg.sender);
      }

      // step 1: decode the calldata. Note: lawCalldata can have any format. 
      (address seniorToRevoke, bytes32 descriptionHash) = abi.decode(lawCalldata, (address, bytes32));

      // step 2: check if newSenior is already a member and if the maximum amount of seniors has already been met.  
      if (SeparatedPowers(payable(agDao)).hasRoleSince(seniorToRevoke, accessRole) == 0) {
        revert Senior_revokeRole__NotASenior();
      }

      // step 3: check if proposal passed vote.
      uint256 proposalId = hashProposal(address(this), lawCalldata, descriptionHash);
      if (SeparatedPowers(payable(agDao)).state(proposalId) != ISeparatedPowers.ProposalState.Succeeded) {
        revert Senior_revokeRole__ProposalVoteNotPassed(proposalId);
      }

      // step 4: complete the proposal. 
      SeparatedPowers(payable(agDao)).complete(lawCalldata, descriptionHash);

      // step 5: creating data to send to the execute function of agDAO's SepearatedPowers contract.
      address[] memory targets = new address[](2);
      uint256[] memory values = new uint256[](2); 
      bytes[] memory calldatas = new bytes[](2);

      // 5a: action: add membership role to applicant. 
      targets[0] = agDao;
      values[0] = 0;
      calldatas[0] = abi.encodeWithSelector(0xd2ab9970, 1, seniorToRevoke, false); // = setRole(uint64 roleId, address account, bool access); 
      
      // 5b: action: give proposer reward. 
      targets[1] = agCoins;
      values[1] = 0;
      calldatas[1] = abi.encodeWithSelector(IERC20.transfer.selector, msg.sender, agCoinsReward);

      // step 6: call {SeparatedPowers.execute}
      // note, call goes in following format: (address proposer, bytes memory lawCalldata, address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash)
      SeparatedPowers(daoCore).execute(msg.sender, targets, values, calldatas);
    }
}
