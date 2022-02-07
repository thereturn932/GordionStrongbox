//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract GordionStrongbox {
    /**
    Events
     */
    event Deposit(address indexed sender, uint amount);
    event SubmitPaymentOffer(uint indexed id, address to, address token, uint value);
    event AcceptPaymentOffer(address indexed owner, uint indexed id);
    event RevokePaymentVote(address indexed owner, uint indexed id);
    event ExecutePayment(uint indexed id);

    modifier onlyOwner() {
        require(isOwner[msg.sender], "0x03");
        _;
    }

    uint8 passRate;
    address[] owners;

    struct Payment {
        uint id;
        address token;
        address to;
        uint value;
        bytes info;
        uint noConfirmations;
        mapping(address => bool) isConfirmed;
        bool executed;
    }

    Payment[] public payments;
    
    // mapping(address => bool) rateOffer;
    mapping(address => bool) public isOwner;

    constructor(address[] memory ownerArray, uint8 rate) {
        require(passRate <=100, "0x00");
        require(ownerArray.length != 0, "0x01");
        for(uint i = 0; i<ownerArray.length; i++){
            require(ownerArray[i] != address(0x0), "0x02");
            isOwner[ownerArray[i]] = true;
        }

        owners = ownerArray;
        passRate = rate;
    }

    // function setPassRate(uint8 rate) internal {
    //     passRate = rate;
    // }

    // function offerNewRate(uint8 rate) external {
        
    // }

    function sendPaymentOffer(
        address _to,
        address _token,
        uint _value,
        bytes memory _info
    ) external onlyOwner{

        Payment storage offer = payments.push();
        offer.id = payments.length;
        offer.to = _to;
        offer.token = _token;
        offer.value = _value;
        offer.info = _info;

        emit SubmitPaymentOffer(offer.id, offer.to, offer.token, offer.value);
    }

    function acceptOffer() external {

    }

    function revokeVote() external {

    }

    function executePayment() external {

    }

    function checkPayment() external view returns (bool){

    }
}