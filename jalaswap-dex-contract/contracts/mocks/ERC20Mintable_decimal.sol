// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

import {ERC20} from "../libraries/ERC20.sol";

contract ERC20Mintable is ERC20 {
    uint8 public decimals_;

    constructor(string memory name_, string memory symbol_, uint8 _decimals) ERC20() {
        decimals_ = _decimals;
        name = name_;
        symbol = symbol_;
    }

    function mint(uint256 amount, address to) public {
        _mint(to, amount);
    }

    function decimals() public view override returns (uint8) {
        return decimals_;
    }
}
