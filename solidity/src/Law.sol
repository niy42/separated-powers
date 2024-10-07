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

  error Law__AccessNotAuthorized(address caller);  
  error Law__CallNotImplemented(); 

  string private _nameFallback;

  ShortString public immutable name;
  uint64 public immutable accessRole; // note: still single role. If multiple accessroles needed, create mutliple laws. For now.
  address public immutable separatedPowers; // note: a law is linked to a specific SeparatedPower contract. Laws cannot be shared between them. They have to be re-initialised through a constructor function.  
  string public description; 

  modifier checkAuthorized() {
     _checkAuthorized(to);
  }

  /**
     * @dev Sets the value for {name} and {version}
     */
  constructor(string memory name_, string memory description_, uint64 accessRole_, address _separatedPowers) EIP712(name_) {
      name = toShortString(name_);
      description = description_; 
      accessRole = accessRole_; 
      separatedPowers = _separatedPowers;
  }

  function executeLaw(bytes memory callData) public checkAuthorized {
    revert Law__CallNotImplemented(); 
  }

  function executeLaw(bytes memory callData, uint256 proposalId) public checkAuthorized {
    revert Law__CallNotImplemented(); 
  }

  function _checkAuthorized() internal virtual {
    uint48 since = SeparatedPowers(separatedPowers).roles[accessRole].members[msg.sender]; 
    
    if (since == 0) {
      revert Law__AccessNotAuthorized(msg.sender);  
    }
  }
}



