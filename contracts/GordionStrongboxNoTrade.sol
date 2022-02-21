//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol";

contract GordionStrongbox {
    /**
    Events
     */
    event DepositAVAX(address indexed sender, uint256 amount);
    event DepositToken(address indexed sender, uint256 amount, address tokenAddress);
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
        bytes data;
        uint256 noConfirmations;
        mapping(address => bool) isConfirmed;
        bool executed;
    }

    struct ConfNoRequest {
        uint256 id;
        uint256 newNo;
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
    ConfNoRequest[] public newConfNoReqs;
    NewMember[] public memberRequests;
    uint256 public reqConfNo;
    address[] owners;

    mapping(address => bool) public isOwner;
    mapping(address => uint256) public depositedAVAX;

    constructor(address[] memory ownerArray, uint8 noConf) {
        require(ownerArray.length != 0, "0x01");
        for (uint256 i = 0; i < ownerArray.length; i++) {
            require(ownerArray[i] != address(0x0), "0x02");
            isOwner[ownerArray[i]] = true;
        }
        owners = ownerArray;
        reqConfNo = noConf;
    }

    /*--------------USER MANAGEMENT--------------*/

    function newMemberRequest(address _member) external onlyOwners {
        require(_member != address(0), "0x02");
        require(!isOwner[_member], "0x13");
        NewMember storage newMember = memberRequests.push();
        newMember.id = newConfNoReqs.length;
        newMember.owner = _member;
        newMember.isConfirmed[msg.sender] = true;
        newMember.noConfirmations++;
    }

    function acceptNewUser(uint256 id) external onlyOwners {
        NewMember storage newMember = memberRequests[id - 1];
        require(!newMember.isConfirmed[msg.sender], "0x10");
        newMember.isConfirmed[msg.sender] = true;
        newMember.noConfirmations++;
    }

    function revokeNewUser(uint256 id) external onlyOwners {
        NewMember storage newMember = memberRequests[id - 1];
        require(newMember.isConfirmed[msg.sender], "0x12");
        newMember.isConfirmed[msg.sender] = false;
        newMember.noConfirmations--;
    }

    function addNewUser(uint256 id) external onlyOwners {
        NewMember storage newMember = memberRequests[id - 1];
        require(newMember.noConfirmations >= reqConfNo, "0x11");
        owners.push(newMember.owner);
        isOwner[newMember.owner] = true;
        newMember.executed = true;
    }

    /*--------------CONFIRMATION NUMBER MANAGEMENT--------------*/

    function requestNewConfNo(uint8 newNo) external onlyOwners {
        ConfNoRequest storage newConf = newConfNoReqs.push();
        newConf.id = newConfNoReqs.length;
        newConf.newNo = newNo;
        newConf.isConfirmed[msg.sender] = true;
        newConf.noConfirmations++;
    }

    function acceptNewConfNo(uint256 id) external onlyOwners {
        ConfNoRequest storage newConf = newConfNoReqs[id - 1];
        require(!newConf.isConfirmed[msg.sender], "0x10");
        newConf.isConfirmed[msg.sender] = true;
        newConf.noConfirmations++;
    }

    function revokeNewConf(uint256 id) external onlyOwners {
        ConfNoRequest storage newConf = newConfNoReqs[id - 1];
        require(newConf.isConfirmed[msg.sender], "0x12");
        newConf.isConfirmed[msg.sender] = false;
        newConf.noConfirmations--;
    }

    function executeNewConf(uint256 id) external onlyOwners {
        ConfNoRequest storage newConf = newConfNoReqs[id - 1];
        require(newConf.noConfirmations >= reqConfNo, "0x11");
        reqConfNo = newConf.newNo;
        newConf.executed = true;
    }

    /*--------------PAYMENT MANAGEMENT--------------*/
    function depositAvax() external payable onlyOwners {
        depositedAVAX[msg.sender] += msg.value;

        emit DepositAVAX(msg.sender, msg.value);
    }

    function depositToken(address _token, uint _value) external onlyOwners {
        IERC20 token = IERC20(_token);
        require(token.allowance(msg.sender, address(this))>= _value, "0x15");
        token.transferFrom(msg.sender, address(this), _value);
        emit DepositToken(msg.sender, _value, _token);
    }

    function sendPaymentOrder(
        address _to,
        address _token,
        uint256 _value,
        bytes memory _data
    ) external onlyOwners {
        require(_to != address(0), "0x05");
        Payment storage order = orders.push();
        order.id = orders.length;
        order.to = _to;
        order.token = _token;
        order.value = _value;
        order.data = _data;
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

    function revokeVote(uint256 id) external onlyOwners{

        Payment storage order = orders[id - 1];
        require(order.isConfirmed[msg.sender], "0x06");
        order.isConfirmed[msg.sender] = false;
        order.noConfirmations--;

        emit RevokePaymentVote(msg.sender, id);
    }

    function executePayment(uint256 id) external onlyOwners{

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
