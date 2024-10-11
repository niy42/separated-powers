// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {SeparatedPowers} from "../SeparatedPowers.sol";
import "../../lib/openzeppelin-contracts/contracts/utils/ShortStrings.sol";

/**
 * @notice Example DAO contract based on the SeparatedPowers protocol.
 */
contract AgDAO is SeparatedPowers {
  using ShortStrings for *;

  // naming uint64 roles at initiation. Optional.  
  uint64 public constant SENIOR_ROLE = 1; 
  uint64 public constant WHALE_ROLE = 2; 
  uint64 public constant MEMBER_ROLE = 3; 

  ShortString[] public coreRequirements; // description of short strings. have to be shorter than 31 characters.

  constructor(address[] memory constitutionalLaws, ConstituentRole[] memory constituentRoles ) SeparatedPowers(
    'agDAO', // name of the DAO. 
    constitutionalLaws, // list of laws that will be active at initiation.
    constituentRoles // a list of accounts that will be assigned roles at initiation. // NB! I need to assign at least one account to Senior role - otherwise the DAO will not work.
    ) {
      setRole(msg.sender, ADMIN_ROLE, true);
    } // this constructor should actually take constitutional laws. 

  function addRequirement(ShortString requirement) public onlySeparatedPowers {
    coreRequirements.push(requirement);
  }

  function removeRequirement(uint256 index) public onlySeparatedPowers {
    coreRequirements[index] = coreRequirements[coreRequirements.length - 1]; 
    coreRequirements.pop();
  }
}
