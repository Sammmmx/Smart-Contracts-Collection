// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ShipmentService {

    enum Status {Pending, Shipped, Delivered}

    address owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    modifier checkPin(uint pin) {
        bytes memory _pin = new bytes(pin);
        require(pin > 999 && pin < 10000, "Incorrect Pin");
        if(_pin[0] == 0) {
            revert ("Pin cannot start with 0");
        }
        _;
    }

    modifier checkAddress(address user) {
        require(user != owner, "Incorrect Address");
        _;
    }

    struct details {
        Status _status;
        uint8 completedDeliveries;
    }
    mapping(address => details) orders;
    

    //This function inititates the shipment
    function shipWithPin(address customerAddress, uint pin) public checkPin(pin) checkAddress(customerAddress) onlyOwner{
        if(orders[customerAddress]._status != Status.Shipped) {
            orders[customerAddress]._status == Status.Pending;
        }
        require(orders[customerAddress]._status == Status.Pending, "This Order has already been Shipped/Delivered");
        orders[customerAddress]._status = Status.Shipped; 
    }

    //This function acknowlegdes the acceptance of the delivery
    function acceptOrder(uint pin) public checkPin(pin) checkAddress(msg.sender) {
        require(orders[msg.sender]._status == Status.Shipped, "No orders Placed");
        orders[msg.sender]._status = Status.Delivered;
        orders[msg.sender].completedDeliveries++;
    }

    //This function outputs the status of the delivery
    function checkStatus(address customerAddress) public checkAddress(customerAddress) view returns (string memory){
        if(orders[customerAddress]._status != Status.Shipped && orders[customerAddress]._status != Status.Delivered){
            return "No orders Placed";
        } else if (orders[customerAddress]._status == Status.Shipped){
            return "Shipped";
        } else {
            return "Delivered";
        }
    }

    //This function outputs the total number of successful deliveries
    function totalCompletedDeliveries(address customerAddress) public checkAddress(customerAddress) view returns (uint) {
        return orders[customerAddress].completedDeliveries;
    }
}