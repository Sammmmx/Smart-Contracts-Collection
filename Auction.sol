// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Auction {

    address owner;
    uint totalbidders;

    constructor() {
        owner = msg.sender;
    }

    struct details {
        uint _startingPrice;
        uint _duration;
        uint high;
        address highbid;
        bool status;
    }
    mapping(uint => details) itemlist;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only accessible to owner");
        _;
    }
    
    modifier itemCheck(uint256 itemNumber) {
        require(itemlist[itemNumber]._duration > 0, "Item does not exists");
        _;
    }

    modifier checkActive(uint256 itemNumber) {
        require(itemlist[itemNumber]._duration > block.timestamp && itemlist[itemNumber].status == true ,"Auction cancelled or duration ended");
        _;
    }

    modifier checkStatus(uint256 itemNumber) {
        require(itemlist[itemNumber].status == true, "Auction Cancelled");
        _;
    }


	function createAuction(uint256 itemNumber,uint256 startingPrice,uint256 duration) public onlyOwner  {
        require(itemlist[itemNumber]._duration == 0, "Item already exists");
        require(startingPrice > 0 && duration > 0, "The values either price or duration is 0");
        itemlist[itemNumber]._startingPrice = startingPrice;
        itemlist[itemNumber]._duration = block.timestamp + duration;
        itemlist[itemNumber].high = startingPrice;
        itemlist[itemNumber].status = true;
    }

	function bid(uint256 itemNumber, uint256 bidAmount) public payable checkStatus(itemNumber) {
        require(itemlist[itemNumber]._duration > 0 && itemlist[itemNumber]._duration > block.timestamp, "Item does not exist or auction duration has ended"); 
        require(bidAmount > itemlist[itemNumber].high,"Your bid is lower than the highest");
        require(msg.value == bidAmount, "Please pay exact amount");
        itemlist[itemNumber].high = bidAmount;
        itemlist[itemNumber].highbid = msg.sender;

    }

	function checkAuctionActive(uint256 itemNumber) public view returns (bool) { 
        if(itemlist[itemNumber]._duration > block.timestamp && itemlist[itemNumber].status == true) {
            return true;
        } else {
            return false;
        }
    }

	function cancelAuction(uint256 itemNumber) public onlyOwner itemCheck(itemNumber) checkActive(itemNumber) {
        itemlist[itemNumber].status = false;
    }

	function timeLeft(uint256 itemNumber) public view returns (uint256) { 
        uint timeleft = itemlist[itemNumber]._duration - block.timestamp;
        require(timeleft > 0 || itemlist[itemNumber]._duration > 0, "Auction hasn't started or has ended already");
        return timeleft;
    }

	function checkHighestBidder(uint256 itemNumber) public view returns (address) {
        if(itemlist[itemNumber]._duration == 0 || itemlist[itemNumber].status == false) {
            return address(0);
        } else {
            return itemlist[itemNumber].highbid;
        }
    }

	function checkActiveBidPrice(uint256 itemNumber) public itemCheck(itemNumber) checkActive(itemNumber) view returns (uint256){ 
        return itemlist[itemNumber].high;
    }

}