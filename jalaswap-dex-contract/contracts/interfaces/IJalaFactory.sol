// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

interface IJalaFactory {
    error OnlyFeeSetter();
    error IdenticalAddresses();
    error PairExists();
    error ZeroAddress();

    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);
    event SetFeeTo(address indexed feeTo);
    event SetFeeToSetter(address indexed oldFeeToSetter, address indexed newFeeToSetter);
    event SetMigrator(address indexed migrator, bool state);
    event SetFlashOn(bool state);
    event SetFlashFee(uint fee);

    function flashOn() external view returns (bool);

    function flashFee() external view returns (uint);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function migrators(address migrator) external view returns (bool);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);
}
