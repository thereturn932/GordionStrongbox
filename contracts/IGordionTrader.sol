//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IGordionTrader {
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
        );

    function addLiquidityNative(
        address token,
        uint256 amountTokenDesired
    )
        external
        returns (
            uint256 amountToken,
            uint256 amountNative,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityNative(
        address token,
        uint256 liquidity
    ) external returns (uint256 amountToken, uint256 amountNative);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint8 slippage,
        address[] calldata path
    ) external returns (uint256[] memory amounts);

    function swapExactAVAXForTokens(
        uint256 amountIn,
        uint8 slippage,
        address[] calldata path
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForAVAX(
        uint256 amountIn,
        uint8 slippage,
        address[] calldata path
    ) external returns (uint256[] memory amounts);
}
