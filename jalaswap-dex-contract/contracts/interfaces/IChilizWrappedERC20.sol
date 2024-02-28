// SPDX-License-Identifier: MIT
import {IERC20} from "./IERC20.sol";

pragma solidity ^0.8.0;

interface IChilizWrappedERC20 {
    error CannotDeposit();
    error InvalidDecimals();
    error CannotWithdraw();
    error Forbidden();
    error AlreadyExists();
    error NotInitialized();

    event Deposit(address indexed account, uint256 indexed amount);
    event Withdraw(address indexed account, uint256 indexed amount);

    function underlying() external view returns (IERC20);

    function depositFor(address account, uint256 amount) external returns (bool);

    function withdrawTo(address account, uint256 amount) external returns (bool);

    function getDecimalsOffset() external view returns (uint256);
}
