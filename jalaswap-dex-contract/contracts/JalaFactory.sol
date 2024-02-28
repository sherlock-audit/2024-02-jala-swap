// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "./interfaces/IJalaFactory.sol";
import "./libraries/SafeERC20.sol";
import "./JalaPair.sol";

contract JalaFactory is IJalaFactory {
    using SafeERC20 for IERC20;

    address public constant DEAD = 0x000000000000000000000000000000000000dEaD;

    bool public override flashOn;
    uint public override flashFee;
    address public override feeTo;
    address public override feeToSetter;
    mapping(address => bool) public override migrators;

    mapping(address => mapping(address => address)) public override getPair;
    address[] public override allPairs;

    constructor(address _feeToSetter) {
        feeToSetter = _feeToSetter;
        flashOn = false;
        feeTo = DEAD;
    }

    modifier onlyFeeToSetter() {
        if (msg.sender != feeToSetter) revert OnlyFeeSetter();
        _;
    }

    function allPairsLength() external view override returns (uint256) {
        return allPairs.length;
    }

    function pairCodeHash() external pure returns (bytes32) {
        return keccak256(type(JalaPair).creationCode);
    }

    function createPair(address tokenA, address tokenB) external override returns (address pair) {
        if (tokenA == tokenB) revert IdenticalAddresses();
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        if (token0 == address(0)) revert ZeroAddress();
        if (getPair[token0][token1] != address(0)) revert PairExists();
        bytes memory bytecode = type(JalaPair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        JalaPair(pair).initialize(token0, token1);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);

        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setFeeTo(address _feeTo) external onlyFeeToSetter {
        feeTo = _feeTo;
        emit SetFeeTo(feeTo);
    }

    function setFeeToSetter(address _feeToSetter) external onlyFeeToSetter {
        address oldFeeToSetter = feeToSetter;
        feeToSetter = _feeToSetter;
        emit SetFeeToSetter(oldFeeToSetter, _feeToSetter);
    }

    function setMigrator(address _migrator, bool _state) external onlyFeeToSetter {
        migrators[_migrator] = _state;
        emit SetMigrator(_migrator, _state);
    }

    function setFlashOn(bool _flashOn) external onlyFeeToSetter {
        flashOn = _flashOn;
        emit SetFlashOn(_flashOn);
    }

    function setFlashFee(uint _flashFee) external onlyFeeToSetter {
        flashFee = _flashFee;
        emit SetFlashFee(_flashFee);
    }
}
