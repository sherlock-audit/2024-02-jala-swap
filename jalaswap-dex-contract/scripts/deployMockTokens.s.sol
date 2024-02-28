// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {JalaMasterRouter} from "../contracts/JalaMasterRouter.sol";
import {ChilizWrapperFactory} from "../contracts/utils/ChilizWrapperFactory.sol";
import {JalaFactory} from "../contracts/JalaFactory.sol";
import {ERC20Mintable} from "../contracts/mocks/ERC20Mintable_decimal.sol";

// Depending on the nature of your oasys blockchain, deployment scripts are not used in production
contract deployMockTokens is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        ERC20Mintable testToken0 = new ERC20Mintable("TestToken0", "TT0", 0);
        ERC20Mintable testToken1 = new ERC20Mintable("TestToken1", "TT1", 0);
        ERC20Mintable testToken2 = new ERC20Mintable("TestToken2", "TT2", 0);
        ERC20Mintable testToken3 = new ERC20Mintable("TestToken3", "TT3", 0);

        testToken0.mint(1000000, 0x88CDf7F91C0f6C27C4c6E5D4C3cc478504c3d45f);
        testToken1.mint(1000000, 0x88CDf7F91C0f6C27C4c6E5D4C3cc478504c3d45f);
        testToken2.mint(1000000, 0x88CDf7F91C0f6C27C4c6E5D4C3cc478504c3d45f);
        testToken3.mint(1000000, 0x88CDf7F91C0f6C27C4c6E5D4C3cc478504c3d45f);

        testToken0.mint(1000000, 0x86d36bd2EEfB7974B9D0720Af3418FC7Ca5C8897);
        testToken1.mint(1000000, 0x86d36bd2EEfB7974B9D0720Af3418FC7Ca5C8897);
        testToken2.mint(1000000, 0x86d36bd2EEfB7974B9D0720Af3418FC7Ca5C8897);
        testToken3.mint(1000000, 0x86d36bd2EEfB7974B9D0720Af3418FC7Ca5C8897);

        vm.stopBroadcast();
    }
}

// forge script scripts/deployMockTokens.s.sol:deployMockTokens --rpc-url $SPICY_TESTNET --broadcast --legacy
