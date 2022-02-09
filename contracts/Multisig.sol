//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "hardhat/console.sol";

contract GordionStrongbox { 
    /**
    Events
     */
    event Deposit(address indexed sender, uint256 amount);
    event SubmitPaymentOrder(
        uint256 indexed id,
        address to,
        address token,
        uint256 value
    );
    event AcceptPaymentOrder(address indexed sender, uint256 indexed id);
    event RevokePaymentVote(address indexed sender, uint256 indexed id);
    event ExecutePayment(uint256 indexed id);

    modifier onlyOwners() {
        require(isOwner[msg.sender], "0x03");
        _;
    }

    struct Payment {
        uint256 id;
        address token;
        address to;
        uint256 value;
        bytes info;
        uint256 noConfirmations;
        mapping(address => bool) isConfirmed;
        bool executed;
    }

    struct RateOffer {
        uint256 id;
        uint256 rate;
        uint256 noConfirmations;
        mapping(address => bool) isConfirmed;
        bool executed;
    }

    struct NewMember {
        uint256 id;
        address owner;
        uint256 noConfirmations;
        mapping(address => bool) isConfirmed;
        bool executed;
    }

    Payment[] public orders;
    RateOffer[] public rateOffers;
    NewMember[] public memberOffers;
    uint256 public reqConfNo;
    address[] owners;

    mapping(address => bool) public isOwner;
    mapping(address => uint256) public depositedAVAX;

    constructor(address[] memory ownerArray, uint8 rate) {
        require(rate <= 100, "0x00");
        require(ownerArray.length != 0, "0x01");
        for (uint256 i = 0; i < ownerArray.length; i++) {
            require(ownerArray[i] != address(0x0), "0x02");
            isOwner[ownerArray[i]] = true;
        }

        owners = ownerArray;
        calculateConfirmationNumber(rate);
    }

    function newUserOffer(address _member) external onlyOwners {
        require(_member != address(0), "0x02");
        require(!isOwner[_member], "0x12");
        NewMember storage newMember = memberOffers.push();
        newMember.id = rateOffers.length;
        newMember.owner = _member;
        newMember.isConfirmed[msg.sender] = true;
        newMember.noConfirmations++;
    }

    function acceptNewUser(uint256 id) external onlyOwners {
        NewMember storage newMember = memberOffers[id - 1];
        require(!newMember.isConfirmed[msg.sender], "0x10");
        newMember.isConfirmed[msg.sender] = true;
        newMember.noConfirmations++;
    }

    function revokeNewUser(uint256 id) external onlyOwners {
        NewMember storage newMember = memberOffers[id - 1];
        require(newMember.isConfirmed[msg.sender], "0x12");
        newMember.isConfirmed[msg.sender] = false;
        newMember.noConfirmations--;
    }

    function addNewUser(uint256 id) external onlyOwners {
        NewMember storage newMember = memberOffers[id - 1];
        require(newMember.noConfirmations >= reqConfNo, "0x11");
        owners.push(newMember.owner);
        isOwner[newMember.owner] = true;
        newMember.executed = true;
    }

    function calculateConfirmationNumber(uint256 rate) internal {
        reqConfNo = (owners.length * rate) / 100;
    }

    function offerNewRate(uint8 rate) external onlyOwners {
        RateOffer storage newRate = rateOffers.push();
        newRate.id = rateOffers.length;
        newRate.rate = rate;
        newRate.isConfirmed[msg.sender] = true;
        newRate.noConfirmations++;
    }

    function acceptNewRate(uint256 id) external onlyOwners {
        RateOffer storage newRate = rateOffers[id - 1];
        require(!newRate.isConfirmed[msg.sender], "0x10");
        newRate.isConfirmed[msg.sender] = true;
        newRate.noConfirmations++;
    }

    function revokeNewRate(uint256 id) external onlyOwners {
        RateOffer storage newRate = rateOffers[id - 1];
        require(newRate.isConfirmed[msg.sender], "0x12");
        newRate.isConfirmed[msg.sender] = false;
        newRate.noConfirmations--;
    }

    function executeNewRate(uint256 id) external onlyOwners {
        RateOffer storage newRate = rateOffers[id - 1];
        require(newRate.noConfirmations >= reqConfNo, "0x11");
        calculateConfirmationNumber(newRate.rate);
        newRate.executed = true;
    }

    function depositAvax() external payable onlyOwners {
        depositedAVAX[msg.sender] += msg.value;

        emit Deposit(msg.sender, msg.value);
    }

    function sendPaymentOrder(
        address _to,
        address _token,
        uint256 _value,
        bytes memory _info
    ) external onlyOwners {
        require(_to != address(0), "0x05");
        Payment storage order = orders.push();
        order.id = orders.length;
        order.to = _to;
        order.token = _token;
        order.value = _value;
        order.info = _info;
        order.isConfirmed[msg.sender] = true;
        order.noConfirmations++;

        emit SubmitPaymentOrder(order.id, order.to, order.token, order.value);
    }

    function acceptOrder(uint256 id) external onlyOwners {
        Payment storage order = orders[id - 1];
        require(order.isConfirmed[msg.sender] != true, "0x04");
        order.isConfirmed[msg.sender] = true;
        order.noConfirmations++;

        emit AcceptPaymentOrder(msg.sender, id);
    }

    function revokeVote(uint256 id) external {
        Payment storage order = orders[id - 1];
        require(order.isConfirmed[msg.sender], "0x06");
        order.isConfirmed[msg.sender] = false;
        order.noConfirmations--;

        emit RevokePaymentVote(msg.sender, id);
    }

    function executePayment(uint256 id) external {
        require(checkPayment(id), "0x07");
        Payment storage order = orders[id - 1];
        require(!order.executed, "0x09");
        if (order.token == address(0)) {
            avaxPayment(order);
        } else {
            tokenPayment(order);
        }

        emit ExecutePayment(id);
    }

    function avaxPayment(Payment storage order) internal {
        order.executed = true;
        (bool sent, ) = order.to.call{value: order.value}("");
        require(sent, "0x08");
    }

    function tokenPayment(Payment storage order) internal {
        order.executed = true;
        IERC20 _token = IERC20(order.token);
        _token.transfer(order.to, order.value);
    }

    function checkPayment(uint256 id) public view returns (bool) {
        Payment storage order = orders[id - 1];
        return order.noConfirmations >= reqConfNo;
    }
}
