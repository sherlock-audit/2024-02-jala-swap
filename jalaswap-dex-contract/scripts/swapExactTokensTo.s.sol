// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {JalaMasterRouter} from "../contracts/JalaMasterRouter.sol";
import {ChilizWrapperFactory} from "../contracts/utils/ChilizWrapperFactory.sol";
import {JalaFactory} from "../contracts/JalaFactory.sol";
import {ERC20Mintable} from "../contracts/mocks/ERC20Mintable_decimal.sol";

// Depending on the nature of your oasys blockchain, deployment scripts are not used in production
contract swapExactToken is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        JalaMasterRouter masterRouter = JalaMasterRouter(payable(0x36524bc7269E07561C8219f9b3300E899f83F458));
        ERC20Mintable TT0 = ERC20Mintable(0x2DB5e3707B2cdaAE26592bDF5F604b120ff8712E);
        ERC20Mintable TT1 = ERC20Mintable(0x4EFbbAE904d7bea13D0b4216E73C1F1Ba5AC5796);

        ChilizWrapperFactory wapperFactory = ChilizWrapperFactory(0xF7084F8B0e73DC329EF03CD53f0f32090A4c0ff9);

        TT0.approve(address(masterRouter), 1000);

        uint256 balanceTT0 = TT0.balanceOf(0x86d36bd2EEfB7974B9D0720Af3418FC7Ca5C8897);
        uint256 balanceTT1 = TT0.balanceOf(0x86d36bd2EEfB7974B9D0720Af3418FC7Ca5C8897);
        uint256 balanceWTT1 = TT0.balanceOf(0x86d36bd2EEfB7974B9D0720Af3418FC7Ca5C8897);

        address[] memory path = new address[](2);
        path[0] = 0x177A87c2C9db840Bf7CB24dAf598a8C4Af327A0E;
        path[1] = 0x4fc6a635D333D7b70E059c219E0c95A29B8790A7;
        masterRouter.swapExactTokensForTokens(
            address(TT0),
            1000,
            0,
            path,
            0x86d36bd2EEfB7974B9D0720Af3418FC7Ca5C8897,
            type(uint40).max
        );

        vm.stopBroadcast();
    }
}

// forge script scripts/swapExactTokensTo.s.sol:swapExactToken --rpc-url $SPICY_TESTNET --broadcast --legacy
