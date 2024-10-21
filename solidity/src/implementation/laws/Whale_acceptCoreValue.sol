// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Law} from "../../Law.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ISeparatedPowers} from "../../interfaces/ISeparatedPowers.sol";
import {SeparatedPowers} from "../../SeparatedPowers.sol";
import "@openzeppelin/contracts/utils/ShortStrings.sol";

/**
 * @notice Example Law contract. 
 * 
 * @dev This contract allows a whale role holder to accept a new requirement for accounts to be funded with agCoins.
 * the requirement needs to have passed a prior vote by members.  
 * 
 * If the contract passes the proposer can execute the law: 
 * 1 - proposer will get a reward.
 * 2 - requirement will be included in the agDAO.  
 *  
 */
contract Whale_acceptCoreValue is Law {
    error Whale_acceptCoreValue__ParentLawNotSet(); 
    error Whale_acceptCoreValue__ParentProposalnotSucceededOrExecuted(uint256 parentProposalId);
    error Whale_acceptCoreValue__ProposalVoteNotPassed(uint256 proposalId); 

    address public agCoins; 
    address public agDao;
    uint256 agCoinsReward = 50_000; 
    
    constructor(address payable agDao_, address agCoins_, address member_proposeCoreValue) // can take a address parentLaw param. 
      Law(
        "Whale_acceptCoreValue", // = name
        "A whale role holder ar agDAO can accept a new requirement and add it to the core values of the DAO. The whale will receive an AgCoin reward in return.", // = description
        2, // = access roleId = whale.  
        agDao_, // = SeparatedPower.sol derived contract. Core of protocol.   
        30, // = quorum
        51, // = succeedAt
        3_600, // votingPeriod_ in blocks, On arbitrum each block is about .5 (half) a second. This is about half an hour. 
        member_proposeCoreValue // = parent Law 
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
      (ShortString requirement, bytes32 descriptionHash) =
            abi.decode(lawCalldata, (ShortString, bytes32));

      // Note step 2: if a parentLaw is exists, check if the parentLaw has succeeded or has executed.
      if (parentLaw != address(0)) {
        uint256 parentProposalId = hashProposal(parentLaw, lawCalldata, descriptionHash); 
        ISeparatedPowers.ProposalState parentState = SeparatedPowers(payable(agDao)).state(parentProposalId);

        if ( parentState != ISeparatedPowers.ProposalState.Completed ) {
          revert Whale_acceptCoreValue__ParentProposalnotSucceededOrExecuted(parentProposalId);
        }
      } else {
        revert Whale_acceptCoreValue__ParentLawNotSet();
      }

      // step 3: check if the proposal has passed. 
      uint256 proposalId = hashProposal(address(this), lawCalldata, descriptionHash);
      ISeparatedPowers.ProposalState proposalState = SeparatedPowers(payable(agDao)).state(proposalId);
      if ( proposalState != ISeparatedPowers.ProposalState.Succeeded) {
        revert Whale_acceptCoreValue__ProposalVoteNotPassed(proposalId);
      }

      // step 4: complete the proposal. 
      SeparatedPowers(payable(agDao)).complete(lawCalldata, descriptionHash);

      // step 5 : creating data to send to the execute function of agDAO's SepearatedPowers contract.
      address[] memory targets = new address[](2);
      uint256[] memory values = new uint256[](2); 
      bytes[] memory calldatas = new bytes[](2);

      // 5a: action 1: give reward to proposer of proposal. 
      targets[0] = agCoins;
      values[0] = 0;
      calldatas[0] = abi.encodeWithSelector(IERC20.transfer.selector, msg.sender, agCoinsReward);

      // 5b: action 2: add requirement to agDAO. 
      targets[1] = agDao;
      values[1] = 0;
      calldatas[1] = abi.encodeWithSelector(0x7be05842, requirement);

      // step 6: call {SeparatedPowers.execute}
      // note, call goes in following format: (address proposer, bytes memory lawCalldata, address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash)
      SeparatedPowers(daoCore).execute(msg.sender, targets, values, calldatas);
  }
}
