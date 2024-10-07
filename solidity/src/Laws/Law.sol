// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {ShortString} from "@openzeppelin/contracts/utils/ShortString.sol";
import {SeparatedPowers} from "../SeparatedPowers.sol"

/**
 * @dev TBI: contract Law. 
 *  
 */
contract Law {
  using ShortStrings for *;

  error Law__NotAuthorized(address caller, address to);  

  ShortString public immutable name;
  ShortString public immutable shortDescription;
  string memory description; 
  uint64 accessRole; // note: still single role. If multiple accessroles needed, create mutliple laws. For now.
  address separatedPowers; // note: a law is linked to a specific SeparatedPower contract. Laws cannot be shared between them. They have to be re-initialised through a constructor function.  

  modifier checkAuthorized(address to) {
     _checkAuthorized(to);
  }

  function _checkAuthorized(address to) internal virtual {
    uint48 since = SeparatedPowers(separatedPowers).roles[accessRole].members[msg.sender]; 
    
    if (since == 0 || to != separatedPowers) {
      revert Law__NotAuthorized(msg.sender, to);  
    }
  }

}



