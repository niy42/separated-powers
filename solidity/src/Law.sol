// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {ShortString} from "@openzeppelin/contracts/utils/ShortString.sol";
import {SeparatedPowers} from "../SeparatedPowers.sol"
import {EIP721} "@openzeppelin/contracts/utils/cryptography/EIP712.sol";

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
  uint8 public immutable quorum; // percentage of roleHolders that need to vote for quorum to pass. 
  uint8 public immutable SucceedAt; // percentage of yes votes for related vote to pass. 
  uint32 public immutable VotingPeriod;  // voting period in blocks 
  address public immutable separatedPowers; // address to related separatedPower contract. Laws cannot be shared between them. They have to be re-initialised through a constructor function.  
  string public description; 

  modifier checkAuthorized() {
     _checkAuthorized();
  }

  /**
     * @dev Sets the value for {name} and {version}
     */
  constructor(
    string memory name_, 
    string memory description_, 
    uint64 accessRole_, 
    uint8 quorum_, // if set to 0, any proposal to this law will automatically pass - without vote. 
    uint8 succeedAt_, // if quorum_ is set to 0, the value here is meaningless.  
    uint32 votingPeriod_, // voting period in blocks. if quorum_ is set to 0, the value here is meaningless.  
    address separatedPowers_
    ) EIP712(name_) {
      name = toShortString(name_);
      description = description_; 
      accessRole = accessRole_; 
      quorum = quorum_;
      succeedAt = succeedAt_; 
      separatedPowers = separatedPowers_; 
      votingPeriod = votingPeriod_;
  }

  function executeLaw(bytes memory callData) public checkAuthorized {
    revert Law__CallNotImplemented(); 
  }

  function executeLaw(bytes memory callData, uint256 proposalId) public checkAuthorized {
    revert Law__CallNotImplemented(); 

    // _proposals[proposalId].executed = true;

  }

  function _checkAuthorized() internal virtual {
    uint48 since = SeparatedPowers(separatedPowers).roles[accessRole].members[msg.sender]; 
    
    if (since == 0) {
      revert Law__AccessNotAuthorized(msg.sender);  
    }
  }
}



