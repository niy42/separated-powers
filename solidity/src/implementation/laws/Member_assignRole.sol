// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Law} from "../../Law.sol";
import {SeparatedPowers} from "../../SeparatedPowers.sol";
import {AgDAO} from "../AgDAO.sol";

/**
 * @notice Example Law contract. 
 * 
 * @dev This law allows anyone to propose adding their account to agDAO, and to accept this proposal without vote. 
 * It is an example of a law that does not have any access restrictions and that does not require a vote. 
 * When executed, it simply assigns the member role to the account. 
 */
contract Member_assignRole is Law {
    error Member_assignRole__IncorrectRequiredStatement(); 
    error Member_assignRole__AccountBlacklisted(); 

    string private requiredStatement = "I request membership to agDAO.";
    address public agDao;  
    
    constructor(address payable agDao_) // can take a address parentLaw param. 
      Law(
        "Member_assignRole", // = name
        "Any account can become member of the agDAO by sending keccak256(bytes('I request membership to agDAO.') to the agDAO. Blacklisted accounts cannot become members.", // = description
        type(uint64).max, // = access PUBLIC_ROLE
        agDao_, // = SeparatedPower.sol derived contract. Core of protocol.   
        0, // = no quorum, means no vote. 
        0, // = succeedAt
        0, // votingPeriod_ in blocks, On arbitrum each block is about .5 (half) a second. This is about half an hour. 
        address(0) // = parent Law 
    ) {
      agDao = agDao_;
    } 

    function executeLaw(
      bytes memory lawCalldata
      ) external override {  

      // step 0: note: access control absent. Any one can call this law. 

      // step 1: decode the calldata. Note: lawCalldata can have any format. 
      bytes32 requiredDescriptionHash = keccak256(bytes(requiredStatement)); 
      (bytes32 descriptionHash) = abi.decode(lawCalldata, (bytes32));
      if (requiredDescriptionHash != descriptionHash) {
        revert Member_assignRole__IncorrectRequiredStatement();
      }

      // check if account is blacklisted. 
      if (AgDAO(payable(agDao)).isAccountBlacklisted(msg.sender) == true) {
        revert Member_assignRole__AccountBlacklisted();
      }

      // step 3 : creating data to send to the execute function of agDAO's SepearatedPowers contract.
      address[] memory targets = new address[](1);
      uint256[] memory values = new uint256[](1); 
      bytes[] memory calldatas = new bytes[](1);

      // action 1: add membership role to applicant. 
      targets[0] = agDao;
      values[0] = 0;
      calldatas[0] = abi.encodeWithSelector(0xd2ab9970, 3, msg.sender, true); // = setRole(uint64 roleId, address account, bool access); 

      // step 4: call {SeparatedPowers.execute}
      // note, call goes in following format: (address proposer, bytes memory lawCalldata, address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash)
      SeparatedPowers(daoCore).execute(msg.sender, targets, values, calldatas);
  }
}
