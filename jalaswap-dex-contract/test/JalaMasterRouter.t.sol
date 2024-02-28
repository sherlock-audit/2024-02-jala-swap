// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../contracts/JalaFactory.sol";
import "../contracts/JalaPair.sol";
import "../contracts/JalaRouter02.sol";
import "../contracts/interfaces/IJalaRouter02.sol";
import "../contracts/mocks/ERC20Mintable_decimal.sol";
import "../contracts/mocks/MockWETH.sol";
import "../contracts/JalaMasterRouter.sol";
import "../contracts/utils/ChilizWrapperFactory.sol";
import "../contracts/interfaces/IChilizWrapperFactory.sol";
import "../contracts/libraries/JalaLibrary.sol";

// @add assertions
contract JalaMasterRouter_Test is Test {
    address feeSetter = address(69);
    MockWETH public WETH;

    JalaRouter02 public router;
    JalaMasterRouter public masterRouter;
    JalaFactory public factory;
    IChilizWrapperFactory public wrapperFactory;

    ERC20Mintable public tokenA;
    ERC20Mintable public tokenB;
    ERC20Mintable public tokenC;

    address user0 = vm.addr(0x01);

    function setUp() public {
        WETH = new MockWETH();

        factory = new JalaFactory(feeSetter);
        router = new JalaRouter02(address(factory), address(WETH));
        wrapperFactory = new ChilizWrapperFactory();
        masterRouter = new JalaMasterRouter(address(factory), address(wrapperFactory), address(router), address(WETH));

        tokenA = new ERC20Mintable("Token A", "TKNA", 0);
        tokenB = new ERC20Mintable("Token B", "TKNB", 0);
        tokenC = new ERC20Mintable("Token C", "TKNC", 0);

        vm.deal(address(this), 100 ether);

        tokenA.mint(200 ether, address(this));
        tokenB.mint(200 ether, address(this));
        tokenC.mint(200 ether, address(this));
        tokenA.mint(10000, user0);
        tokenB.mint(10000, user0);
        tokenC.mint(10000, user0);
    }

    function encodeError(string memory error) internal pure returns (bytes memory encoded) {
        encoded = abi.encodeWithSignature(error);
    }

    function test_AddLiquidityCreatesPair() public {
        tokenA.approve(address(masterRouter), 10000000);
        tokenB.approve(address(masterRouter), 10000000);

        masterRouter.wrapTokensAndaddLiquidity(
            address(tokenA),
            address(tokenB),
            10000000,
            10000000,
            10000000,
            10000000,
            user0,
            block.timestamp
        );
        address pairAddress = factory.getPair(
            wrapperFactory.wrappedTokenFor(address(tokenA)),
            wrapperFactory.wrappedTokenFor(address(tokenB))
        );
        uint256 liquidity = JalaPair(pairAddress).balanceOf(user0);
        console.logUint(liquidity);
        assertEq(liquidity, 10000000 * 1e18 - 1000);
    }

    function test_AddLiquidityETH() public {
        tokenA.approve(address(masterRouter), 1 ether);

        masterRouter.wrapTokenAndaddLiquidityETH{value: 1 ether}(address(tokenA), 1, 1, 1, user0, block.timestamp);

        address pairAddress = factory.getPair(wrapperFactory.wrappedTokenFor(address(tokenA)), address(WETH));
        uint256 liquidity = JalaPair(pairAddress).balanceOf(user0);
        console.logUint(liquidity);
        assertEq(liquidity, 1 ether - 1000);
    }

    function test_RemoveLiquidity() public {
        tokenA.approve(address(masterRouter), 10000000);
        tokenB.approve(address(masterRouter), 10000000);

        masterRouter.wrapTokensAndaddLiquidity(
            address(tokenA),
            address(tokenB),
            10000000,
            10000000,
            10000000,
            10000000,
            user0,
            block.timestamp
        );

        address wrappedTokenA = wrapperFactory.wrappedTokenFor(address(tokenA));
        address wrappedTokenB = wrapperFactory.wrappedTokenFor(address(tokenB));
        address pairAddress = factory.getPair(address(wrappedTokenA), address(wrappedTokenB));
        JalaPair pair = JalaPair(pairAddress);
        uint256 liquidity = pair.balanceOf(user0);

        vm.startPrank(user0);
        pair.approve(address(masterRouter), liquidity);

        console.log(1, pair.balanceOf(user0));
        console.log(2, tokenA.balanceOf(user0));
        console.log(3, IERC20(wrappedTokenA).balanceOf(user0));

        masterRouter.removeLiquidityAndUnwrapToken(
            address(tokenA),
            address(tokenB),
            liquidity,
            liquidity,
            liquidity,
            user0,
            block.timestamp
        );
        vm.stopPrank();

        console.log(11, pair.balanceOf(user0));
        console.log(22, tokenA.balanceOf(user0));
        console.log(33, IERC20(wrappedTokenA).balanceOf(user0));

        // (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
        // assertEq(reserve0, 1000);
        // assertEq(reserve1, 1000);
        // assertEq(pair.balanceOf(address(this)), 0);
        // assertEq(pair.totalSupply(), 1000);
        // assertEq(tokenA.balanceOf(address(this)), 20 ether - 1000);
        // assertEq(tokenB.balanceOf(address(this)), 20 ether - 1000);
    }

    function test_removeLiquidityETH() public {
        tokenA.approve(address(masterRouter), 2000000);

        masterRouter.wrapTokenAndaddLiquidityETH{value: 1000000}(
            address(tokenA),
            2000000,
            2000000,
            2000000,
            user0,
            block.timestamp
        );

        address wrappedTokenA = wrapperFactory.wrappedTokenFor(address(tokenA));
        address pairAddress = factory.getPair(address(wrappedTokenA), address(WETH));
        JalaPair pair = JalaPair(pairAddress);
        uint256 liquidity = pair.balanceOf(user0);

        console.log(1, pair.balanceOf(user0));
        console.log(2, tokenA.balanceOf(user0));
        console.log(3, address(user0).balance);
        console.log(4, IERC20(wrappedTokenA).balanceOf(user0));

        vm.startPrank(user0);
        pair.approve(address(masterRouter), liquidity);
        masterRouter.removeLiquidityETHAndUnwrap(address(tokenA), liquidity, 0, 0, user0, type(uint40).max);
        vm.stopPrank();

        console.log(11, pair.balanceOf(user0));
        console.log(22, tokenA.balanceOf(user0));
        console.log(33, address(user0).balance);
        console.log(44, IERC20(wrappedTokenA).balanceOf(user0));
    }

    function test_SwapExactTokensForTokens() public {
        address wrappedTokenA = IChilizWrapperFactory(wrapperFactory).wrappedTokenFor(address(tokenA));
        address wrappedTokenB = IChilizWrapperFactory(wrapperFactory).wrappedTokenFor(address(tokenB));

        console.log(1, tokenA.balanceOf(address(this)));
        console.log(2, tokenB.balanceOf(address(this)));

        tokenA.approve(address(masterRouter), 10 ether);
        tokenB.approve(address(masterRouter), 10 ether);

        masterRouter.wrapTokensAndaddLiquidity(
            address(tokenA),
            address(tokenB),
            20000000,
            20000000,
            20000000,
            20000000,
            address(this),
            block.timestamp
        );

        address pairAddress = factory.getPair(
            wrapperFactory.wrappedTokenFor(address(tokenA)),
            wrapperFactory.wrappedTokenFor(address(tokenB))
        );
        uint256 a = JalaPair(pairAddress).balanceOf(address(this));
        (uint112 _reserve0, uint112 _reserve1, ) = JalaPair(pairAddress).getReserves();
        console.log(_reserve0, _reserve1);

        address[] memory path = new address[](2);
        path[0] = wrappedTokenA;
        path[1] = wrappedTokenB;

        vm.startPrank(user0);
        tokenA.approve(address(masterRouter), 1);
        masterRouter.swapExactTokensForTokens(address(tokenA), 1, 0, path, user0, block.timestamp);
        vm.stopPrank();

        (_reserve0, _reserve1, ) = JalaPair(pairAddress).getReserves();
        console.log(_reserve0, _reserve1);

        console.log(11, tokenA.balanceOf(address(this)));
        console.log(22, tokenB.balanceOf(address(this)));
        console.log(33, IERC20(wrappedTokenA).balanceOf(address(this)));
        console.log(44, IERC20(wrappedTokenB).balanceOf(address(this)));
        console.log(55, tokenA.balanceOf(user0));
        console.log(66, tokenB.balanceOf(user0));
        console.log(77, IERC20(wrappedTokenA).balanceOf(user0));
        console.log(88, IERC20(wrappedTokenB).balanceOf(user0));

        // assertEq(tokenA.balanceOf(address(this)), 20 ether - 1 ether - 0.3 ether);
        // assertEq(tokenB.balanceOf(address(this)), 20 ether - 2 ether);
    }

    // function test_SwapTokensForExactTokens() public {
    //     address wrappedTokenA = IChilizWrapperFactory(wrapperFactory).wrappedTokenFor(address(tokenA));
    //     address wrappedTokenB = IChilizWrapperFactory(wrapperFactory).wrappedTokenFor(address(tokenB));

    //     uint256 amount = 100000;
    //     uint256 wrappedAmount = 100000*1e18;

    //     wrapperFactory.createWrappedToken(address(tokenA));
    //     wrapperFactory.createWrappedToken(address(tokenB));

    //     tokenA.approve(address(wrapperFactory), amount);
    //     tokenB.approve(address(wrapperFactory), amount);

    //     wrapperFactory.wrap(address(this), address(tokenA), amount);
    //     wrapperFactory.wrap(address(this), address(tokenB), amount);

    //     IERC20(wrappedTokenA).approve(address(router), wrappedAmount);
    //     IERC20(wrappedTokenB).approve(address(router), wrappedAmount);

    //     router.addLiquidity(
    //         wrappedTokenA,
    //         wrappedTokenB,
    //         wrappedAmount,
    //         wrappedAmount,
    //         wrappedAmount,
    //         wrappedAmount,
    //         address(this),
    //         block.timestamp
    //     );

    //     address[] memory path = new address[](2);
    //     path[0] = address(wrappedTokenA);
    //     path[1] = address(wrappedTokenB);

    //     vm.startPrank(user0);
    //     tokenA.approve(address(masterRouter), 2000);
    //     masterRouter.swapTokensForExactTokens(address(tokenA), 1000, type(uint256).max, path, user0, block.timestamp);
    //     vm.stopPrank();
    // }

    function test_SwapExactETHForTokens() public {
        address wrappedTokenA = IChilizWrapperFactory(wrapperFactory).wrappedTokenFor(address(tokenA));

        tokenA.approve(address(wrapperFactory), type(uint256).max);
        wrapperFactory.wrap(address(this), address(tokenA), 100);

        IERC20(wrappedTokenA).approve(address(router), 100 ether);
        router.addLiquidityETH{value: 100 ether}(wrappedTokenA, 100 ether, 0, 0, address(this), type(uint40).max);

        address pairAddress = factory.getPair(address(WETH), wrapperFactory.wrappedTokenFor(address(tokenA)));
        uint256 a = JalaPair(pairAddress).balanceOf(address(this));
        (uint112 _reserve0, uint112 _reserve1, ) = JalaPair(pairAddress).getReserves();
        console.log(_reserve0, _reserve1);

        address[] memory path = new address[](2);
        path[0] = address(WETH);
        path[1] = wrappedTokenA;

        vm.startPrank(user0);
        vm.deal(user0, 5 ether);

        console.log(1, WETH.balanceOf(user0));
        console.log(2, tokenA.balanceOf(user0));
        console.log(3, IERC20(wrappedTokenA).balanceOf(user0));

        masterRouter.swapExactETHForTokens{value: 5 ether}(0, path, user0, type(uint40).max);
        vm.stopPrank();

        (_reserve0, _reserve1, ) = JalaPair(pairAddress).getReserves();
        console.log(_reserve0, _reserve1);

        console.log(11, WETH.balanceOf(user0));
        console.log(22, tokenA.balanceOf(user0));
        console.log(33, IERC20(wrappedTokenA).balanceOf(user0));
    }

    function test_swapExactTokensForETH() public {
        address wrappedTokenA = IChilizWrapperFactory(wrapperFactory).wrappedTokenFor(address(tokenA));
        address wrappedTokenB = IChilizWrapperFactory(wrapperFactory).wrappedTokenFor(address(tokenB));

        tokenA.approve(address(wrapperFactory), type(uint256).max);
        wrapperFactory.wrap(address(this), address(tokenA), 100);

        IERC20(wrappedTokenA).approve(address(router), 100 ether);
        router.addLiquidityETH{value: 100 ether}(wrappedTokenA, 100 ether, 0, 0, address(this), type(uint40).max);

        address pairAddress = factory.getPair(address(WETH), wrapperFactory.wrappedTokenFor(address(tokenA)));

        uint256 pairBalance = JalaPair(pairAddress).balanceOf(address(this));
        (uint112 _reserve0, uint112 _reserve1, ) = JalaPair(pairAddress).getReserves();
        console.log(_reserve0, _reserve1);

        address[] memory path = new address[](2);
        path[0] = wrappedTokenA;
        path[1] = address(WETH);

        vm.startPrank(user0);
        console.log(1, user0.balance);
        console.log(2, tokenA.balanceOf(user0));
        console.log(3, IERC20(wrappedTokenA).balanceOf(user0));

        tokenA.approve(address(masterRouter), 550);
        masterRouter.swapExactTokensForETH(address(tokenA), 550, 0, path, user0, type(uint40).max);
        vm.stopPrank();

        (_reserve0, _reserve1, ) = JalaPair(pairAddress).getReserves();
        console.log(_reserve0, _reserve1);

        // console.log(11, WETH.balanceOf(user0));
        console.log(11, user0.balance);
        console.log(22, tokenA.balanceOf(user0));
        console.log(33, IERC20(wrappedTokenA).balanceOf(user0));
    }
}

// forge test --match-path test/JalaMasterRouter.t.sol -vvvv
