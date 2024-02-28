// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IChilizWrapperFactory} from "../interfaces/IChilizWrapperFactory.sol";
import {IChilizWrappedERC20} from "../interfaces/IChilizWrappedERC20.sol";
import {ChilizWrappedERC20} from "./ChilizWrappedERC20.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {SafeERC20} from "../libraries/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract ChilizWrapperFactory is IChilizWrapperFactory, Ownable {
    mapping(address => address) public underlyingToWrapped;
    mapping(address => address) public wrappedToUnderlying;

    function wrap(address account, address underlyingToken, uint256 amount) public returns (address wrappedToken) {
        wrappedToken = underlyingToWrapped[underlyingToken];
        if (wrappedToken == address(0)) {
            wrappedToken = _createWrappedToken(underlyingToken);
        }
        _transferTokens(IERC20(underlyingToken), wrappedToken, amount);
        IChilizWrappedERC20(wrappedToken).depositFor(account, amount);
    }

    function unwrap(address account, address wrappedToken, uint256 amount) public {
        _transferTokens(IERC20(wrappedToken), wrappedToken, amount);
        IChilizWrappedERC20(wrappedToken).withdrawTo(account, amount);
    }

    function createWrappedToken(address underlyingToken) public returns (address) {
        if (underlyingToWrapped[underlyingToken] != address(0)) revert AlreadyExists();
        return _createWrappedToken(underlyingToken);
    }

    function _createWrappedToken(address underlyingToken) internal returns (address wrappedToken) {
        bytes memory bytecode = type(ChilizWrappedERC20).creationCode;
        bytes32 salt = keccak256(abi.encode(underlyingToken));
        assembly {
            wrappedToken := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        ChilizWrappedERC20(wrappedToken).initialize(IERC20(underlyingToken));

        underlyingToWrapped[underlyingToken] = address(wrappedToken);
        wrappedToUnderlying[address(wrappedToken)] = underlyingToken;

        emit WrappedTokenCreated(underlyingToken, wrappedToken);
    }

    function wrappedTokenFor(address underlyingToken) public view returns (address wrappedToken) {
        wrappedToken = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            hex"ff",
                            address(this),
                            keccak256(abi.encode(underlyingToken)),
                            keccak256(type(ChilizWrappedERC20).creationCode)
                        )
                    )
                )
            )
        );
    }

    function getUnderlyingToWrapped(address underlying) public view returns (address) {
        return underlyingToWrapped[underlying];
    }

    function _transferTokens(IERC20 token, address approveToken, uint256 amount) internal {
        SafeERC20.safeTransferFrom(token, msg.sender, address(this), amount);
        if (token.allowance(address(this), approveToken) < amount) {
            token.approve(approveToken, amount);
        }
    }
}
