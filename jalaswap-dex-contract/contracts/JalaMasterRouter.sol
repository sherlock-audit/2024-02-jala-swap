// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./interfaces/IERC20.sol";
import "./interfaces/IJalaRouter02.sol";
import "./interfaces/IJalaMasterRouter.sol";
import "./interfaces/IChilizWrapperFactory.sol";
import "./interfaces/IChilizWrappedERC20.sol";
import "./interfaces/IWETH.sol";
import "./libraries/JalaLibrary.sol";
import "./libraries/TransferHelper.sol";

// This is a Master Router contract that wrap under 18 decimal token
// and interact with router to addliqudity and swap tokens.
contract JalaMasterRouter is IJalaMasterRouter {
    address public immutable factory;
    address public immutable WETH;
    address public immutable router;
    address public immutable wrapperFactory;

    constructor(address _factory, address _wrapperFactory, address _router, address _WETH) {
        factory = _factory;
        wrapperFactory = _wrapperFactory;
        router = _router;
        WETH = _WETH;
    }

    receive() external payable {
        require(msg.sender == WETH || msg.sender == router, "MS: !Wrong Sender"); // only accept ETH via fallback from the WETH and router contract
    }

    function wrapTokensAndaddLiquidity(
        // only use wrapTokensAndaddLiquidity to create pool.
        address tokenA, // origin token
        address tokenB, // origin token
        uint256 amountADesired, // unwrapped.
        uint256 amountBDesired, // unwrapped.
        uint256 amountAMin, // unwrapped
        uint256 amountBMin, // unwrapped
        address to,
        uint256 deadline
    ) public virtual override returns (uint256 amountA, uint256 amountB, uint256 liquidity) {
        // get token from user
        TransferHelper.safeTransferFrom(tokenA, msg.sender, address(this), amountADesired);
        TransferHelper.safeTransferFrom(tokenB, msg.sender, address(this), amountBDesired);

        address wrappedTokenA = _approveAndWrap(tokenA, amountADesired);
        address wrappedTokenB = _approveAndWrap(tokenB, amountBDesired);

        uint256 tokenAOffset = IChilizWrappedERC20(wrappedTokenA).getDecimalsOffset();
        uint256 tokenBOffset = IChilizWrappedERC20(wrappedTokenB).getDecimalsOffset();

        IERC20(wrappedTokenA).approve(router, IERC20(wrappedTokenA).balanceOf(address(this))); // no need for check return value, bc addliquidity will revert if approve was declined.
        IERC20(wrappedTokenB).approve(router, IERC20(wrappedTokenB).balanceOf(address(this)));

        // add liquidity
        (amountA, amountB, liquidity) = IJalaRouter02(router).addLiquidity(
            wrappedTokenA,
            wrappedTokenB,
            amountADesired * tokenAOffset,
            amountBDesired * tokenBOffset,
            amountAMin * tokenAOffset,
            amountBMin * tokenBOffset,
            to,
            deadline
        );
        _unwrapAndTransfer(wrappedTokenA, to);
        _unwrapAndTransfer(wrappedTokenB, to);
    }

    function wrapTokenAndaddLiquidityETH(
        // only use wrapTokenAndaddLiquidityETH to create pool.
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable virtual override returns (uint256 amountToken, uint256 amountETH, uint256 liquidity) {
        TransferHelper.safeTransferFrom(token, msg.sender, address(this), amountTokenDesired);
        address wrappedToken = _approveAndWrap(token, amountTokenDesired);

        uint256 tokenOffset = IChilizWrappedERC20(wrappedToken).getDecimalsOffset();

        IERC20(wrappedToken).approve(router, IERC20(wrappedToken).balanceOf(address(this))); // no need for check return value, bc addliquidity will revert if approve was declined.

        (amountToken, amountETH, liquidity) = IJalaRouter02(router).addLiquidityETH{value: msg.value}(
            wrappedToken,
            amountTokenDesired * tokenOffset,
            amountTokenMin * tokenOffset,
            amountETHMin,
            to,
            deadline
        );

        // refund dust eth, if any
        if (msg.value > amountETH) TransferHelper.safeTransferETH(msg.sender, msg.value - amountETH);
        _unwrapAndTransfer(wrappedToken, to);
    }

    function removeLiquidityAndUnwrapToken(
        address tokenA, // token origin addr
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external virtual override returns (uint256 amountA, uint256 amountB) {
        address wrappedTokenA = IChilizWrapperFactory(wrapperFactory).wrappedTokenFor(tokenA);
        address wrappedTokenB = IChilizWrapperFactory(wrapperFactory).wrappedTokenFor(tokenB);
        address pair = JalaLibrary.pairFor(factory, wrappedTokenA, wrappedTokenB);
        TransferHelper.safeTransferFrom(pair, msg.sender, address(this), liquidity);

        IERC20(pair).approve(router, liquidity);

        (amountA, amountB) = IJalaRouter02(router).removeLiquidity(
            wrappedTokenA,
            wrappedTokenB,
            liquidity,
            amountAMin,
            amountBMin,
            address(this),
            deadline
        );

        uint256 tokenAOffset = IChilizWrappedERC20(wrappedTokenA).getDecimalsOffset();
        uint256 tokenBOffset = IChilizWrappedERC20(wrappedTokenB).getDecimalsOffset();
        uint256 tokenAReturnAmount = (amountA / tokenAOffset) * tokenAOffset;
        uint256 tokenBReturnAmount = (amountB / tokenBOffset) * tokenBOffset;

        IERC20(wrappedTokenA).approve(wrapperFactory, tokenAReturnAmount); // no need for check return value, bc addliquidity will revert if approve was declined.
        IERC20(wrappedTokenB).approve(wrapperFactory, tokenBReturnAmount); // no need for check return value, bc addliquidity will revert if approve was declined.

        if (tokenAReturnAmount > 0) {
            IChilizWrapperFactory(wrapperFactory).unwrap(to, wrappedTokenA, tokenAReturnAmount);
        }
        if (tokenBReturnAmount > 0) {
            IChilizWrapperFactory(wrapperFactory).unwrap(to, wrappedTokenB, tokenBReturnAmount);
        }

        // transfer dust as wrapped token
        if (amountA - tokenAReturnAmount > 0) {
            TransferHelper.safeTransfer(wrappedTokenA, to, amountA - tokenAReturnAmount);
        }
        if (amountB - tokenBReturnAmount > 0) {
            TransferHelper.safeTransfer(wrappedTokenB, to, amountB - tokenBReturnAmount);
        }
    }

    function removeLiquidityETHAndUnwrap(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) public virtual override returns (uint256 amountToken, uint256 amountETH) {
        address wrappedToken = IChilizWrapperFactory(wrapperFactory).wrappedTokenFor(token);
        address pair = JalaLibrary.pairFor(factory, wrappedToken, address(WETH));
        TransferHelper.safeTransferFrom(pair, msg.sender, address(this), liquidity);

        IERC20(pair).approve(router, liquidity);

        (amountToken, amountETH) = IJalaRouter02(router).removeLiquidityETH(
            wrappedToken,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );

        uint256 tokenOffset = IChilizWrappedERC20(wrappedToken).getDecimalsOffset();
        uint256 tokenReturnAmount = (amountToken / tokenOffset) * tokenOffset;

        IERC20(wrappedToken).approve(wrapperFactory, tokenReturnAmount); // no need for check return value, bc addliquidity will revert if approve was declined.

        if (tokenReturnAmount > 0) {
            IChilizWrapperFactory(wrapperFactory).unwrap(to, wrappedToken, tokenReturnAmount);
        }
        // transfer dust as wrapped token
        if (amountToken - tokenReturnAmount > 0) {
            TransferHelper.safeTransfer(wrappedToken, to, amountToken - tokenReturnAmount);
        }

        (bool success, ) = to.call{value: address(this).balance}("");
        require(success);
    }

    function swapExactTokensForTokens(
        address originTokenAddress,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external virtual override returns (uint256[] memory amounts, address reminderTokenAddress, uint256 reminder) {
        address wrappedTokenIn = IChilizWrapperFactory(wrapperFactory).wrappedTokenFor(originTokenAddress);

        require(path[0] == wrappedTokenIn, "MS: !path");

        TransferHelper.safeTransferFrom(originTokenAddress, msg.sender, address(this), amountIn);
        _approveAndWrap(originTokenAddress, amountIn);
        IERC20(wrappedTokenIn).approve(router, IERC20(wrappedTokenIn).balanceOf(address(this)));

        amounts = IJalaRouter02(router).swapExactTokensForTokens(
            IERC20(wrappedTokenIn).balanceOf(address(this)),
            amountOutMin,
            path,
            address(this),
            deadline
        );
        (reminderTokenAddress, reminder) = _unwrapAndTransfer(path[path.length - 1], to);
    }

    // function swapTokensForExactTokens(
    //     address originTokenAddress,
    //     uint256 amountOut,
    //     uint256 amountInMax,
    //     address[] calldata path,
    //     address to,
    //     uint256 deadline
    // ) external virtual returns (uint256[] memory amounts, address reminderTokenAddress, uint256 reminder) {
    //     address wrappedTokenIn = IChilizWrapperFactory(wrapperFactory).wrappedTokenFor(originTokenAddress);

    //     require(path[0] == wrappedTokenIn, "MS: !path");
    //     address wrappedTokenOut = path[path.length - 1];
    //     uint256 tokenOutOffset = IChilizWrappedERC20(wrappedTokenOut).getDecimalsOffset();

    //     amounts = JalaLibrary.getAmountsIn(factory, amountOut*tokenOutOffset, path);

    //     TransferHelper.safeTransferFrom(originTokenAddress, msg.sender, address(this), amounts[0]);
    //     IERC20(originTokenAddress).approve(wrapperFactory, amounts[0]); // no need for check return value, bc addliquidity will revert if approve was declined.
    //     IChilizWrapperFactory(wrapperFactory).wrap(address(this), originTokenAddress, amounts[0]);
    //     IERC20(wrappedTokenIn).approve(router, IERC20(wrappedTokenIn).balanceOf(address(this)));

    //     IJalaRouter02(router).swapTokensForExactTokens( // no need to get return value
    //         amountOut*tokenOutOffset,
    //         amountInMax,
    //         path,
    //         address(this),
    //         deadline
    //     );

    //     uint256 balanceOut = IERC20(wrappedTokenOut).balanceOf(address(this));
    //     uint256 tokenOutReturnAmount = (balanceOut / tokenOutOffset) * tokenOutOffset;

    //     IERC20(wrappedTokenOut).approve(wrapperFactory, tokenOutReturnAmount); // no need for check return value, bc addliquidity will revert if approve was declined.

    //     if (tokenOutReturnAmount > 0) {
    //         IChilizWrapperFactory(wrapperFactory).unwrap(to, wrappedTokenOut, tokenOutReturnAmount);
    //     }

    //     // transfer dust as wrapped token
    //     if (IERC20(wrappedTokenOut).balanceOf(address(this)) > 0) {
    //         reminderTokenAddress = address(wrappedTokenOut);
    //         reminder = IERC20(wrappedTokenOut).balanceOf(address(this));
    //         TransferHelper.safeTransfer(wrappedTokenOut, to, IERC20(wrappedTokenOut).balanceOf(address(this)));
    //     }
    // }

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    )
        external
        payable
        virtual
        override
        returns (uint256[] memory amounts, address reminderTokenAddress, uint256 reminder)
    {
        amounts = IJalaRouter02(router).swapExactETHForTokens{value: msg.value}(
            amountOutMin,
            path,
            address(this),
            deadline
        );
        (reminderTokenAddress, reminder) = _unwrapAndTransfer(path[path.length - 1], to);
    }

    function swapExactTokensForETH(
        address originTokenAddress,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external virtual override returns (uint256[] memory amounts) {
        address wrappedTokenIn = IChilizWrapperFactory(wrapperFactory).wrappedTokenFor(originTokenAddress);

        require(path[0] == wrappedTokenIn, "MS: !path");

        TransferHelper.safeTransferFrom(originTokenAddress, msg.sender, address(this), amountIn);
        _approveAndWrap(originTokenAddress, amountIn);
        IERC20(wrappedTokenIn).approve(router, IERC20(wrappedTokenIn).balanceOf(address(this)));

        amounts = IJalaRouter02(router).swapExactTokensForETH(amountIn, amountOutMin, path, to, deadline);
    }

    function _unwrapAndTransfer(
        address wrappedTokenOut,
        address to
    ) private returns (address reminderTokenAddress, uint256 reminder) {
        // address wrappedTokenOut = path[path.length - 1];
        uint256 balanceOut = IERC20(wrappedTokenOut).balanceOf(address(this));
        if (balanceOut == 0) return (reminderTokenAddress, reminder);

        uint256 tokenOutOffset = IChilizWrappedERC20(wrappedTokenOut).getDecimalsOffset();
        uint256 tokenOutReturnAmount = (balanceOut / tokenOutOffset) * tokenOutOffset;

        IERC20(wrappedTokenOut).approve(wrapperFactory, tokenOutReturnAmount); // no need for check return value, bc addliquidity will revert if approve was declined.

        if (tokenOutReturnAmount > 0) {
            IChilizWrapperFactory(wrapperFactory).unwrap(to, wrappedTokenOut, tokenOutReturnAmount);
        }

        // transfer dust as wrapped token
        if (IERC20(wrappedTokenOut).balanceOf(address(this)) > 0) {
            reminderTokenAddress = address(wrappedTokenOut);
            reminder = IERC20(wrappedTokenOut).balanceOf(address(this));
            TransferHelper.safeTransfer(wrappedTokenOut, to, IERC20(wrappedTokenOut).balanceOf(address(this)));
        }
    }

    function _approveAndWrap(address token, uint256 amount) private returns (address wrappedToken) {
        IERC20(token).approve(wrapperFactory, amount); // no need for check return value, bc addliquidity will revert if approve was declined.
        wrappedToken = IChilizWrapperFactory(wrapperFactory).wrap(address(this), token, amount);
    }
}
