// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Law} from "../../Law.sol";
import {SeparatedPowers} from "../../SeparatedPowers.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ShortStrings.sol";

/**
 * @notice Example Law contract. 
 * 
 * @dev This contract allows a member to propose a new requirement for accounts to be funded with agCoins.
 * members can only propose, they cannot change requirements themselves. 
 * the contract DOES have an execute call: if the proposal passes the members vote, the member who proposed the requirement can claim a reward. 
 *  
 */
contract Member_proposeCoreValue is Law {
    string private _name = "Member_proposeCoreValue"; 
    address public agCoins;
    address public agDao;  
    uint256 agCoinsReward = 100_000;  
    
    constructor(address payable agDao_, address agCoins_) // can take a address parentLaw param. 
      Law(
        "Member_proposeCoreValue", // = name
        "A member of agDAO can propose new values to be added to the core values of the DAO.", // = description
        3, // = access roleId 
        agDao_, // = SeparatedPower.sol derived contract. Core of protocol.   
        30, // = quorum
        60, // = succeedAt
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
      (ShortString requirement, bytes32 descriptionHash) =
            abi.decode(lawCalldata, (ShortString, bytes32));

      // step 2 : creating data to send to the execute function of agDAO's SepearatedPowers contract.
      address[] memory targets = new address[](1);
      uint256[] memory values = new uint256[](1); 
      bytes[] memory calldatas = new bytes[](1);

      targets[0] = agCoins;
      values[0] = 0;
      calldatas[0] = abi.encodeWithSelector(IERC20.transfer.selector, msg.sender, agCoinsReward);

      // step 3: call {SeparatedPowers.execute} If reuiqrement is accepted, member will get an amount of agCoins. 
      // note: at this point _nothing_ happens with the agDAOs requirements. 
      // note, call goes in following format: (address /* proposer */, bytes memory /* lawCalldata */, address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 /*descriptionHash*/)
      SeparatedPowers(daoCore).execute(msg.sender, lawCalldata, targets, values, calldatas, descriptionHash);
  }
}
