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
contract Whale_revokeMember is Law {
    error Whale_revokeMember__AccountIsNotMember();
    error Whale_revokeMember__ProposalVoteNotPassed(uint256 proposalId);

    address public agCoins; 
    address public agDao;
    uint256 agCoinsReward = 75_000;
    
    constructor(address payable agDao_, address agCoins_) // can take a address parentLaw param. 
      Law(
        "Whale_revokeMember", // = name
        "Whales can revoke membership of members when they think the Member has the broken core DAO requirements for funding accounts.", // = description
        2, // = access whale
        agDao_, // = SeparatedPower.sol derived contract. Core of protocol.   
        50, // = quorum 
        66, // = succeedAt
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
      (address memberToRevoke, bytes32 descriptionHash) = abi.decode(lawCalldata, (address, bytes32));

      // step 2: retrieve necessary data.  
      uint48 since = SeparatedPowers(payable(agDao)).hasRoleSince(memberToRevoke, 3); // = member role. 
      if (since == 0) {
        revert Whale_revokeMember__AccountIsNotMember();
      }

      // step 3: check if proposal passed vote.
      uint256 proposalId = hashProposal(address(this), lawCalldata, descriptionHash);
      if (SeparatedPowers(payable(agDao)).state(proposalId) != ISeparatedPowers.ProposalState.Succeeded) {
        revert Whale_revokeMember__ProposalVoteNotPassed(proposalId);
      }

      // step 4: set proposal to completed. 
      SeparatedPowers(payable(agDao)).complete(lawCalldata, descriptionHash);

      // step 5: creating data to send to the execute function of agDAO's SepearatedPowers contract.
      address[] memory targets = new address[](3);
      uint256[] memory values = new uint256[](3); 
      bytes[] memory calldatas = new bytes[](3);

      // 5a: action 1: revoke membership role to applicant. 
      targets[0] = agDao;
      values[0] = 0;
      calldatas[0] = abi.encodeWithSelector(0xd2ab9970, 3, memberToRevoke, false); // = setRole(uint64 roleId, address account, bool access); 

      // 5b: action 2: add account to blacklist 
      targets[1] = agDao;
      values[1] = 0;
      calldatas[1] = abi.encodeWithSelector(0xe594707e, memberToRevoke, true); // = blacklistAccount(address account, bool isBlacklisted);

      // 5c: action 3: give proposer reward.  
      targets[2] = agCoins;
      values[2] = 0;
      calldatas[2] = abi.encodeWithSelector(IERC20.transfer.selector, msg.sender, agCoinsReward);

      // step 6: call {SeparatedPowers.execute}
      // note, call goes in following format: (address proposer, bytes memory lawCalldata, address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash)
      SeparatedPowers(daoCore).execute(msg.sender, targets, values, calldatas);
    }
}
