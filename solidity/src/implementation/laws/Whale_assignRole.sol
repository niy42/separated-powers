// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Law} from "../../Law.sol";
import {SeparatedPowers} from "../../SeparatedPowers.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @notice Example Law contract. 
 * 
 * @dev In this contract...
 *
 *  
 */
abstract contract Whale_assignRole is Law {
    error Whale_assignRole__Error();
    error Senior_assignRole__TooManySeniors();

    address public agCoins; 
    address public agDao;
    uint256 amountTokensForWhaleRole = 1_000_000;
    uint256 agCoinsReward = 75_000;
    
    constructor(address payable agDao_, address agCoins_) // can take a address parentLaw param. 
      Law(
        "Whale_assignRole", // = name
        "Whales can assign or revoke whale roles, according to the agCoins an account hold. If a change has been applied, the executioner will receive a reward.", // = description
        2, // = access Whale
        agDao_, // = SeparatedPower.sol derived contract. Core of protocol.   
        0, // = no quorum, means no vote. 
        0, // = succeedAt
        0, // votingPeriod_ in blocks, On arbitrum each block is about .5 (half) a second. This is about half an hour. 
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
      (address accountToAssess, bytes32 descriptionHash) = abi.decode(lawCalldata, (address, bytes32));

      // step 2: retrieve necessary data.  
      uint256 balanceAccount = ERC20(agCoins).balanceOf(accountToAssess);
      uint48 since = SeparatedPowers(payable(agDao)).hasRoleSince(accountToAssess, accessRole);

      // step 3: Note that check for proposal to have passed & setting proposal as completed is missing. This action can be executed without setting a proposal or passing a vote.  

      // step 4: set data structure for call to execute function.
      address[] memory targets = new address[](2);
      uint256[] memory values = new uint256[](2); 
      bytes[] memory calldatas = new bytes[](2);
      
      // 4a: action 1: conditional assign or revoke role. 
      targets[0] = agDao;
      values[0] = 0;

      // 4b:action 2: give reward to proposer of proposal. 
      targets[1] = agCoins;
      values[1] = 0;
      calldatas[1] = abi.encodeWithSelector(IERC20.transfer.selector, msg.sender, agCoinsReward);

      //step 5: conditionally execute call. 
      // 5a: option 1: if accountToCheck is a whale but has fewer tokens than the minimum. Role is revoked. 
      if (balanceAccount < amountTokensForWhaleRole && since != 0) {
        calldatas[0] = abi.encodeWithSelector(0xd2ab9970, 1, accountToAssess, false); // = setRole(uint64 roleId, address account, bool access); 
        SeparatedPowers(daoCore).execute(msg.sender, lawCalldata, targets, values, calldatas, descriptionHash);
      } 
      // 5b: option 2: if accountToCheck is not a whale but has more tokens than the minimum. Role is assigned. 
      else if (balanceAccount >= amountTokensForWhaleRole && since == 0) {
        calldatas[0] = abi.encodeWithSelector(0xd2ab9970, 0, accountToAssess, true); // = setRole(uint64 roleId, address account, bool access); 
        SeparatedPowers(daoCore).execute(msg.sender, lawCalldata, targets, values, calldatas, descriptionHash);
      } else {
        revert Whale_assignRole__Error();
      }
  }
}
