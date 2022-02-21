//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IJoeRouter.sol";

contract GordionTrader {
    address joeAddress = address(0x60aE616a2155Ee3d9A68541Ba4544862310933d4);
    IJoeRouter02 joeRouter = IJoeRouter02(joeAddress);

    constructor() {}

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        )
    {
        IERC20(tokenA).approve(joeAddress, amountA);
        IERC20(tokenB).approve(joeAddress, amountB);
        uint256 amountAMin = 0;
        uint256 amountBMin = 0;
        return
            joeRouter.addLiquidity(
                tokenA,
                tokenB,
                amountADesired,
                amountBDesired,
                amountAMin,
                amountBMin,
                address(this),
                (block.timestamp + 120)
            );
    }

    function addLiquidityNative(address token, uint256 amountTokenDesired)
        external
        returns (
            uint256 amountToken,
            uint256 amountNative,
            uint256 liquidity
        )
    {
        IERC20(token).approve(joeAddress, amountTokenDesired);
        uint256 amountTokenMin = 0;
        uint256 amountNativeMin = 0;
        return
            joeRouter.addLiquidityAVAX(
                token,
                amountTokenDesired,
                amountTokenMin,
                amountNativeMin,
                address(this),
                (block.timestamp + 120)
            );
    }

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity
    ) external returns (uint256 amountA, uint256 amountB) {
        uint256 amountAMin = 0;
        uint256 amountBMin = 0;
        return
            joeRouter.removeLiquidity(
                tokenA,
                tokenB,
                liquidity,
                amountAMin,
                amountBMin,
                address(this),
                (block.timestamp + 120)
            );
    }

    function removeLiquidityNative(address token, uint256 liquidity)
        external
        returns (uint256 amountToken, uint256 amountNative)
    {
        uint256 amountTokenMin = 0;
        uint256 amountNativeMin = 0;
        return
            joeRouter.removeLiquidityAVAX(
                token,
                liquidity,
                amountTokenMin,
                amountNativeMin,
                address(this),
                (block.timestamp + 120)
            );
    }

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint8 slippage,
        address[] calldata path
    ) external returns (uint256[] memory amounts) {
        IERC20(path[0]).approve(joeAddress, amountIn);
        uint256[] memory remAmounts = joeRouter.getAmountsOut(amountIn, path);
        uint256 amountOutMin = (remAmounts[remAmounts.length - 1] *
            (100 - slippage)) / 100;
        return
            joeRouter.swapExactTokensForTokens(
                amountIn,
                amountOutMin,
                path,
                address(this),
                (block.timestamp + 120)
            );
    }

    function swapExactAVAXForTokens(
        uint256 amountIn,
        uint8 slippage,
        address[] calldata path
    ) external returns (uint256[] memory amounts) {
        uint256[] memory remAmounts = joeRouter.getAmountsOut(amountIn, path);
        uint256 amountOutMin = (remAmounts[remAmounts.length - 1] *
            (100 - slippage)) / 100;
        return
            joeRouter.swapExactAVAXForTokens{value: amountIn}(
                amountOutMin,
                path,
                address(this),
                (block.timestamp + 120)
            );
    }

    function swapExactTokensForAVAX(
        uint256 amountIn,
        uint8 slippage,
        address[] calldata path
    ) external returns (uint256[] memory amounts) {
        IERC20(path[0]).approve(joeAddress, amountIn);
        uint256[] memory remAmounts = joeRouter.getAmountsOut(amountIn, path);
        uint256 amountOutMin = (remAmounts[remAmounts.length - 1] *
            (100 - slippage)) / 100;
        return
            joeRouter.swapExactTokensForAVAX(
                amountIn,
                amountOutMin,
                path,
                address(this),
                (block.timestamp + 120)
            );
    }
}
