// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {SeparatedPowers} from "../SeparatedPowers.sol";
import "../../lib/openzeppelin-contracts/contracts/utils/ShortStrings.sol";

/**
 * @notice Example DAO contract based on the SeparatedPowers protocol.
 */
contract AgDao is SeparatedPowers {
  using ShortStrings for *;

  // naming uint64 roles at initiation. Optional.  
  uint64 public constant SENIOR_ROLE = 1; 
  uint64 public constant WHALE_ROLE = 2; 
  uint64 public constant MEMBER_ROLE = 3; 

  ShortString[] public coreRequirements; // description of short strings. have to be shorter than 31 characters.
  mapping(address => bool) public blacklistedAccounts; // description of short strings. have to be shorter than 31 characters.

  constructor( ) SeparatedPowers(
    'agDao'// name of the DAO. 
    ) {} 

  // a few functions that are specific to the AgDao.
  function addRequirement(ShortString requirement) public onlySeparatedPowers {
    coreRequirements.push(requirement);
  }

  function removeRequirement(uint256 index) public onlySeparatedPowers {
    coreRequirements[index] = coreRequirements[coreRequirements.length - 1]; 
    coreRequirements.pop();
  }

  function setBlacklistAccount(address account, bool isBlackListed) public onlySeparatedPowers {
    blacklistedAccounts[account] = isBlackListed;
  }

  function isAccountBlacklisted(address account) public returns (bool) {
    return blacklistedAccounts[account];
  } 

}
