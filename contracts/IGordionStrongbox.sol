//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface GordionStrongbox {
    /*--------------USER MANAGEMENT--------------*/

    function newMemberRequest(address _member) external;

    function acceptNewUser(uint256 id) external;

    function revokeNewUser(uint256 id) external;

    function addNewUser(uint256 id) external;

    /*--------------CONFIRMATION NUMBER MANAGEMENT--------------*/

    function requestNewConfNo(uint8 newNo) external;

    function acceptNewConfNo(uint256 id) external;

    function revokeNewConf(uint256 id) external;

    function executeNewConf(uint256 id) external;

    /*--------------PAYMENT MANAGEMENT--------------*/
    function depositAvax() external payable;

    function depositToken(address _token, uint256 _value) external;

    function sendPaymentOrder(
        address _to,
        address _token,
        uint256 _value,
        bytes memory _data
    ) external;

    function acceptOrder(uint256 id) external;

    function revokeVote(uint256 id) external;

    function executePayment(uint256 id) external;

    function checkPayment(uint256 id) external view returns (bool);

    /*--------------TRADING MANAGEMENT--------------*/
    function swapRequest(
        address _from,
        address _to,
        uint256 _amount,
        uint8 _slippage
    ) external;

    function acceptSwapRequest(uint256 id) external;

    function revokeSwapRequest(uint256 id) external;

    function executeSwapRequest(uint256 id) external;

    function addLiquidityRequest(
        address _tokenA,
        address _tokenB,
        uint256 _amountA,
        uint256 _amountB,
        bool _adding
    ) external;

    function acceptLiquidityRequest(uint256 id) external;

    function revokeLiquidityRequest(uint256 id) external;

    function executeLiquidityRequest(uint256 id) external;
}
