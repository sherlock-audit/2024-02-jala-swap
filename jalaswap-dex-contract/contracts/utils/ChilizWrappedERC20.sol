// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "../interfaces/IERC20.sol";
import {IChilizWrappedERC20} from "../interfaces/IChilizWrappedERC20.sol";
import {ERC20} from "../libraries/ERC20.sol";
import {SafeERC20} from "../libraries/SafeERC20.sol";

contract ChilizWrappedERC20 is ERC20, IChilizWrappedERC20 {
    address public factory;
    IERC20 private underlyingToken;
    uint256 private decimalsOffset;

    constructor() ERC20() {
        factory = msg.sender;
    }

    function initialize(IERC20 _underlyingToken) external {
        if (msg.sender != factory) revert Forbidden();
        if (_underlyingToken.decimals() >= 18) revert InvalidDecimals();
        if (address(underlyingToken) != address(0)) revert AlreadyExists();

        underlyingToken = _underlyingToken;
        decimalsOffset = 10 ** (18 - _underlyingToken.decimals());
        name = string(abi.encodePacked("Wrapped ", _underlyingToken.name()));
        symbol = string(abi.encodePacked("W", _underlyingToken.symbol()));
    }

    function underlying() public view returns (IERC20) {
        return underlyingToken;
    }

    function depositFor(address account, uint256 amount) public virtual returns (bool) {
        if (address(underlyingToken) == address(0)) revert NotInitialized();
        address sender = _msgSender();
        if (sender == address(this)) revert CannotDeposit();
        SafeERC20.safeTransferFrom(underlyingToken, sender, address(this), amount);
        _mint(account, amount * decimalsOffset);

        emit Deposit(account, amount);

        return true;
    }

    function withdrawTo(address account, uint256 amount) public virtual returns (bool) {
        if (address(underlyingToken) == address(0)) revert NotInitialized();
        uint256 unwrapAmount = amount / decimalsOffset;
        if (unwrapAmount == 0) revert CannotWithdraw();
        address msgSender = _msgSender();
        uint256 burntAmount = unwrapAmount * decimalsOffset;
        _burn(msgSender, burntAmount);
        SafeERC20.safeTransfer(underlyingToken, account, unwrapAmount);
        if (msgSender != account) {
            _transfer(msgSender, account, amount - burntAmount);
        }

        emit Withdraw(account, amount);

        return true;
    }

    function getDecimalsOffset() public view returns (uint256) {
        return decimalsOffset;
    }
}
