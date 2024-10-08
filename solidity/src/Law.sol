// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "../lib/openzeppelin-contracts/contracts/utils/ShortStrings.sol";
import {ILaw} from "./interfaces/ILaw.sol"; 
import {EIP712} from "../lib/openzeppelin-contracts/contracts/utils/cryptography/EIP712.sol";
import {ERC165} from "lib/openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";
import {IERC165} from "lib/openzeppelin-contracts/contracts/utils/introspection/IERC165.sol";

/**
 * @dev TBI: contract Law. 
 *  
 */
contract Law is IERC165, ERC165, EIP712 {
  using ShortStrings for *;

  error Law__AccessNotAuthorized(address caller);  
  error Law__CallNotImplemented(); 

  string private _nameFallback;

  ShortString public immutable name;
  uint64 public immutable accessRole; // note: still single role. If multiple accessroles needed, create mutliple laws. For now.
  uint8 public immutable quorum; // percentage of roleHolders that need to vote for quorum to pass. 
  uint8 public immutable succeedAt; // percentage of yes votes for related vote to pass. 
  uint32 public immutable votingPeriod;  // voting period in blocks 
  address public immutable separatedPowers; // address to related separatedPower contract. Laws cannot be shared between them. They have to be re-initialised through a constructor function.  
  string public description; 
  string constant version = "1"; 

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
    ) EIP712(name_, version) {
      name = name_.toShortString();
      description = description_; 
      accessRole = accessRole_; 
      quorum = quorum_;
      succeedAt = succeedAt_; 
      separatedPowers = separatedPowers_; 
      votingPeriod = votingPeriod_;
  }

  function executeLaw(bytes memory callData) external virtual {
    revert Law__CallNotImplemented(); 
  }

  function executeLaw(bytes memory callData, uint256 proposalId) external virtual {
    revert Law__CallNotImplemented(); 

    // need to have a function in SeparatedPowers to set proposals to executed. 
    // a function that can only be called by the law that the proposal references. 
    // _proposals[proposalId].executed = true;

  }

  function supportsInterface(bytes4 interfaceId) public view override(ERC165, IERC165) returns (bool) {
     return interfaceId == type(ILaw).interfaceId || super.supportsInterface(interfaceId);
  }

}



