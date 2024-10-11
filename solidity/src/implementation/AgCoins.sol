// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @dev Mock ERC20 contract for use in the agDAO example implementation of the SeparatedPowers protocol.
 *  
 */
contract AgCoins is ERC20 {
  constructor() ERC20("AgCoins", "AGC") {
        _mint(msg.sender, type(uint256).max);
  }

}
