//SPDX-License-Identifier

pragma solidity ^0.8.23;

contract vault {

    address public owner;
    uint256 Vault;

    constructor() {
        owner = msg.sender;
    }

    enum Roles {None, Manager, User}

    struct details {
        Roles role;
        uint256 limit;
        bool logged;
    }
    mapping(address => details) public Members;

    modifier checkOwner(address any) {
        require(any == owner, "You are not authorized");
        _;
    }

    modifier checkAddress(address any) {
        require(any != address(0), "Invalid Address");
        _;
    }

    function addManager(address _man) public 
    checkOwner(msg.sender)
    checkAddress(_man) {
        Members[_man].role = Roles.Manager;
    }

    function removeManager(address _man) public 
    checkOwner(msg.sender)
    checkAddress(_man) {
        require(Members[_man].role == Roles.Manager, "User was not a Manager");
        Members[_man].role = Roles.None;
    }

    function setWithdrawLimit(address user, uint256 _limit) public 
    checkAddress(user) {
        require(Members[msg.sender].role == Roles.Manager, "You are not Authorized");
        Members[user].limit = _limit;
    }

    function deposit() public payable {
        require(msg.value > 0, "Empty transactions is not allowed");
        Vault += msg.value;
        if(!Members[msg.sender].logged) {
            Members[msg.sender].role = Roles.User;
            Members[msg.sender].logged = true;
        }
        
    }

    function withdraw(uint256 amount) public {
        require(Members[msg.sender].limit >= amount && Vault >= amount, "Asking for outside the limit or vault has insufficient funds");
        Vault -= amount;
        Members[msg.sender].limit -= amount;
        (bool success, ) = (msg.sender).call{value: amount}("");
        require(success, "Transaction Failed");
    }

    function emergencyWithdraw() public 
    checkOwner(msg.sender) {
        uint256 amount = Vault;
        Vault = 0;
        (bool success, ) = owner.call{value: amount}("");
        require(success, "Transaction Failed");
    }
}