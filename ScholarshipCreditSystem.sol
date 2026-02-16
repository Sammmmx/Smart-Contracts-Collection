// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract ScholarshipCreditContract {
    address owner;
    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the Owner");
        _;
    }

    modifier validAddress(address merchantAddress) {
        require(merchantAddress != address(0), "Invalid Address");
        _;
    }

    struct merchantDetails {
        uint credits;
    }

    struct studentDetails {
        uint creditsAvailable;
    }

    uint total_credits = 1000000;
    mapping(address => studentDetails) Students;
    mapping(address => merchantDetails) creditsMerchants;
    address[] merchants;
    address[] students;

    //This function assigns credits to student getting the scholarship
    function grantScholarship(address studentAddress, uint credits) public onlyOwner{
        for(uint i = 0; i < merchants.length; i++){
            require(studentAddress != merchants[i] , "This is a Merchant Address");
        }
        require(studentAddress != owner, "Owner can't be granted scholarship");
        require(credits > 0 && credits <= total_credits, "Amount can't be zero or out of balance");
        bool exists;
        for(uint i = 0; i < students.length; i++) {
            if(studentAddress == students[i]) {
                exists = true;
            }
        }
        if(exists == false) {
            students.push(studentAddress);
        } 
        Students[studentAddress].creditsAvailable += credits;
        total_credits -= credits;
        
    }


    //This function is used to register a new merchant who can receive credits from students
    function registerMerchantAddress(address merchantAddress) public onlyOwner validAddress(merchantAddress) {
        for(uint j = 0; j < students.length; j++) {
            require(merchantAddress != students[j], "This is a Student address");
        }
        require(merchantAddress != owner, "Owner can't be merchant");
        bool registered;
        for(uint8 i = 0; i < merchants.length; i++) {
            if(merchantAddress == merchants[i]){
                registered = true;
            }
        }
        require(registered == false, "This merchant is already registered");
        merchants.push(merchantAddress);
    }

    //This function is used to deregister an existing merchant
    function deregisterMerchantAddress(address merchantAddress) public onlyOwner validAddress(merchantAddress) {
        bool registered;
        for(uint8 i = 0; i < merchants.length; i++) {
            if(merchantAddress == merchants[i]){
                registered = true;
                merchants[i] = merchants[merchants.length-1];
                merchants.pop();
            }
        }
        require(registered == true, "You never registered this Merchant bro");
        total_credits += creditsMerchants[merchantAddress].credits;
        creditsMerchants[merchantAddress].credits = 0;
    }

    //This function is used to revoke the scholarship of a student
    function revokeScholarship(address studentAddress) public onlyOwner{
        require(studentAddress != address(0), "Invalid Address");
        bool registered;
        for(uint i = 0; i < students.length; i++) {
            if(studentAddress == students[i]){
                students[i] = students[students.length-1];
                students.pop();
                registered = true;
            }
        }
        require(registered == true, "Incorrect Address");
        total_credits += Students[studentAddress].creditsAvailable;
        Students[studentAddress].creditsAvailable = 0;

    }

    //Students can use this function to transfer credits only to registered merchants
    function spend(address merchantAddress, uint amount) public {
        bool Sregister;
        for(uint256 i = 0; i < students.length; i++) {
            if(msg.sender == students[i]) {
                Sregister = true;
            }
        }
        require(Sregister == true, "You are not a student with scholarship");
        bool Mregister;
        for(uint256 j = 0; j < merchants.length; j++) {
            if(merchantAddress == merchants[j]){
                Mregister = true;
            }
        }
        require(Mregister == true, "Incorrect merchant Address");
        require(merchantAddress != owner, "This is an owner Address");
        creditsMerchants[merchantAddress].credits += amount;
        Students[msg.sender].creditsAvailable -= amount;
    }

    //This function is used to see the available credits assigned.
    function checkBalance() public view returns (uint) {
        uint result;
        bool check;
        for(uint i = 0; i < students.length; i++) {
            if(msg.sender == students[i]) {
                result = Students[msg.sender].creditsAvailable;
                check = true;
                break;
            }
        }
        for(uint j = 0; j < merchants.length; j++) {
            if(msg.sender == merchants[j]) {
                result = creditsMerchants[msg.sender].credits;
                check = true;
                break;
            }
        }
        if(msg.sender == owner) {
            result = total_credits;
            check = true;
        }
        if(check == false) {
            revert("Incorrect address");
        }

        return result;
    }
}