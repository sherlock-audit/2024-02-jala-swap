// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IChilizWrapperFactory {
    error WrappedTokenExists();
    error WrappedTokenDoesNotExist();
    error AlreadyExists();

    event WrappedTokenCreated(address indexed underlyingToken, address indexed wrappedToken);
    event MappingChanged(
        address underlyingToken,
        address wrappedToken,
        address newUnderlyingToken,
        address newWrappedToken
    );

    function wrap(address account, address underlyingToken, uint256 amount) external returns (address wrappedToken);

    function unwrap(address account, address wrappedToken, uint256 amount) external;

    function createWrappedToken(address underlyingToken) external returns (address);

    function wrappedTokenFor(address underlyingToken) external view returns (address);

    function getUnderlyingToWrapped(address underlyingToken) external view returns (address);
}
