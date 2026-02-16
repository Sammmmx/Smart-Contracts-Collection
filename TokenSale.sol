//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

contract TokenSale {

    uint public tokenPrice;
    uint public totalSupply;
    uint public saleDuration;
    uint public timePeriod;
    address public owner;

    constructor (uint256 _totalSupply, uint256 _tokenPrice, uint256 _saleDuration)  {
         tokenPrice = _tokenPrice;
         totalSupply = _totalSupply;
         saleDuration = _saleDuration;
         timePeriod = block.timestamp + saleDuration * 1 seconds;
         owner = msg.sender;
    }

    struct Purchase {
        uint tokens;
        bool purchase;
        uint tokensSold;
        uint transactionTime;
        uint tokenSellAllowed;
        uint referred;
        uint referCount;
        uint tokensAwarded;
    }

    mapping (address => Purchase) public purchases;

    function checkTokenPrice() public view returns (uint256) {
        return tokenPrice;
    }

    function purchaseToken(address referrer) public payable {
        require(timePeriod >= block.timestamp, "The sale Duration has ended");
        require(referrer != msg.sender, "Invalid referrer address");
        require(!purchases[msg.sender].purchase, "You already purchased tokens");
        require(msg.value >= tokenPrice, "Not enough wei");
        require(totalSupply > 0, "Sold out");

        uint eligibleTokens = msg.value / tokenPrice;

        purchases[msg.sender] = Purchase(eligibleTokens, true, purchases[msg.sender].tokensSold, block.timestamp, (eligibleTokens * 20) / 100, 5, 0, 0);
        

        // Update token price
        uint updatedPrice = (eligibleTokens * 100) / totalSupply;
        updatedPrice = updatedPrice / 2;
        tokenPrice = tokenPrice + (tokenPrice * updatedPrice) / 100;

        // Referral system
        uint tokensAwardedToReferrer = (eligibleTokens * purchases[msg.sender].referred) / 100;
        totalSupply -= tokensAwardedToReferrer;

        for (uint i = 5; i > 0; i--) {
            if (purchases[referrer].referred == i) {
                purchases[referrer].tokens += (eligibleTokens * i) / 100;
                purchases[referrer].referred--;
                purchases[referrer].referCount++;
                purchases[referrer].tokensAwarded += (eligibleTokens * i) / 100;
                totalSupply = totalSupply - (eligibleTokens * i) / 100;
            }
        }
    }

    function checkTokenBalance(address buyer) public view returns (uint256) {
        return purchases[buyer].tokens;
    }

    function saleTimeLeft() public view returns (uint256) {
        if (block.timestamp < timePeriod) {
            return timePeriod - block.timestamp;
        } else {
            revert("Sale time ended");
        }
    }

    function sellTokenBack(uint256 amount) public payable {
        uint sellDuration = purchases[msg.sender].transactionTime + 7 days;
        if(block.timestamp >= sellDuration) {
            sellDuration = sellDuration + 7 days;
            purchases[msg.sender].tokenSellAllowed = (purchases[msg.sender].tokens * 20) / 100;
            purchases[msg.sender].tokensSold = 0;
        }

        uint eligibleTokensToSell = purchases[msg.sender].tokenSellAllowed;
        require(amount <= eligibleTokensToSell, "Can't sell more than 20% of your tokens in a week");
        require(purchases[msg.sender].tokensSold + amount <= eligibleTokensToSell, "Max token sell for a week exhausted");

        // Update token price
        uint updatedPrice = (amount * 100) / totalSupply;
        tokenPrice = tokenPrice - (tokenPrice * updatedPrice) / 100;

        purchases[msg.sender].tokens -= amount;
        purchases[msg.sender].tokenSellAllowed -= amount;
        purchases[msg.sender].tokensSold += amount;

        uint sellPrice = amount * tokenPrice;

        (bool success, ) = payable(msg.sender).call{value: sellPrice}("");
        require(success, "Transfer failed");

        totalSupply += amount;
    }

    function getReferralCount(address referrer) public view returns (uint256) {
        return purchases[referrer].referCount;
    }

    function getReferralRewards(address referrer) public view returns (uint256) {
        return purchases[referrer].tokensAwarded;
    }
}