// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Law} from "../../Law.sol";
import {SeparatedPowers} from "../../SeparatedPowers.sol";

/**
 * @notice Example Law contract. 
 * 
 * @dev In this contract...
 *
 *  
 */
contract Whale_proposeLaw is Law {  
    error Whale_proposeLaw__ProposalVoteNotPassed(uint256 proposalId);
    
    address public agCoins;
    address public agDao;  
    uint256 agCoinsReward = 33_000;  
    
    constructor(address payable agDao_, address agCoins_) // can take a address parentLaw param. 
      Law(
        "Whale_proposeLaw", // = name
        "A whale can propose laws to be included or excluded from the whitelisted active laws of agDAO.", // = description
        2, // = access roleId = whale 
        agDao_, // = SeparatedPower.sol derived contract. Core of protocol.   
        20, // = quorum
        51, // = succeedAt
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
      (address law, bool toInclude, bytes32 descriptionHash) =
            abi.decode(lawCalldata, (address, bool, bytes32));

      // step 2: check if proposal passed vote.
      uint256 proposalId = hashProposal(address(this), lawCalldata, descriptionHash);
      if (SeparatedPowers(payable(agDao)).state(proposalId) != ISeparatedPowers.ProposalState.Succeeded) {
        revert Whale_proposeLaw__ProposalVoteNotPassed(proposalId);
      }

      // step 3: set proposal to completed. 
      SeparatedPowers(payable(agDao)).complete(proposalId);

      // step 4: creating data to send to the execute function of agDAO's SepearatedPowers contract.
      address[] memory targets = new address[](1);
      uint256[] memory values = new uint256[](1); 
      bytes[] memory calldatas = new bytes[](1);

      targets[0] = agCoins;
      values[0] = 0;
      calldatas[0] = abi.encodeWithSelector(IERC20.transfer.selector, msg.sender, agCoinsReward);

      // step 5: call {SeparatedPowers.execute}
      // note, call goes in following format: (address proposer, bytes memory lawCalldata, address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash)
      SeparatedPowers(daoCore).execute(msg.sender, lawCalldata, targets, values, calldatas, descriptionHash);
  }
}
