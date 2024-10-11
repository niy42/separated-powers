// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import SeparatedPowers from "../SeparatedPowers.sol";

/**
 * @notice Example DAO contract based on the SeparatedPowers protocol.
 */
contract AgDAO is SeparatedPowers {

  constructor() SeparatedPowers('agDAO') {} // this constructor should actually take constitutional laws. 
  
}
