// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {JalaMasterRouter} from "../contracts/JalaMasterRouter.sol";
import {ChilizWrapperFactory} from "../contracts/utils/ChilizWrapperFactory.sol";
import {JalaFactory} from "../contracts/JalaFactory.sol";

// Depending on the nature of your oasys blockchain, deployment scripts are not used in production
contract deployAll is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        address testnet_WETH = 0x678c34581db0a7808d0aC669d7025f1408C9a3C6;
        address routerFactory = 0x5B14e2E332eC76A829F588b192C59437Ba19eA12;
        address router = 0xF4f858acf122d388EF5A603615087DaCa87A5773;
        // address wrapperFactory = 0x2B0471E418451aA33F543EF4160AFf1900A2D818;

        ChilizWrapperFactory wrapperFactory = new ChilizWrapperFactory();
        JalaMasterRouter masterRouter = new JalaMasterRouter(
            routerFactory,
            address(wrapperFactory),
            router,
            testnet_WETH
        );
        console2.log("wrapperFactory: ", address(wrapperFactory));
        console2.log("MasterRouter: ", address(masterRouter));

        vm.stopBroadcast();
    }
}
/**
CHILIZ Mainnet
    ROUTER_V2: '0x377d5e70c8fb649D7e2DbdaCCBefa1858EF4f973'
    PAIR_FACTORY: '0x7ef878CED132a7c3e3a56751DF3F7fD0F5AA0575'
    WRAPPER_FACTORY: '0x2066c5860F3ebE19Fa51544a54C40D6a8f5B965f'
    WETH: '0x677F7e16C7Dd57be1D4C8aD1244883214953DC47'
  
CHILIZ TESTNET
    ROUTER_V2: '0xF4f858acf122d388EF5A603615087DaCa87A5773'
    PAIR_FACTORY: '0x5B14e2E332eC76A829F588b192C59437Ba19eA12'
    WRAPPER_FACTORY: '0x447A6EF240084261183627c876460c5E6abB179b'
    WETH: '0x678c34581db0a7808d0aC669d7025f1408C9a3C6'
*/

// forge script scripts/deployMasterRouter.s.sol:deployAll --rpc-url $SPICY_TESTNET --broadcast --legacy
