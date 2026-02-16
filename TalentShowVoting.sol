// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract DWGotTalent {

    address owner;
    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the Owner");
        _;
    }

    modifier checkAccess() {
        require(votingStarted == false && end == false, "Voting has started, can't modify now");
        _;
    }

    modifier checkAccess2() {
        require(votingStarted == true && end == false, "Voting has not started yet");
        _;
    }

    

    address[] public judges;
    mapping(address => uint) public finalistsPoints;
    address[] public finalists;
    uint public judgeVote;
    uint public audienceVote;
    bool public votingStarted;
    address[] public voted;
    bool public end;
    address[] public winner;

    //this function defines the addresses of accounts of judges
    function selectJudges(address[] memory arrayOfAddresses) public onlyOwner checkAccess {
        for(uint i = 0; i < arrayOfAddresses.length; i++) {
            require(arrayOfAddresses[i] != address(0), "Invalid address");
        }
        for(uint l = 0; l < arrayOfAddresses.length; l++) {
            for(uint k = 0; k < finalists.length; k++){
                require(arrayOfAddresses[l] != finalists[k], "Finalist can't be a judge");
            }
        }
        require(arrayOfAddresses.length > 0, "Value can't be zero");
        for(uint i = 0; i < arrayOfAddresses.length; i++) {
            judges.push(arrayOfAddresses[i]);
        }
    }

    //this function adds the weightage for judges and audiences
    function inputWeightage(uint judgeWeightage, uint audienceWeightage) public onlyOwner checkAccess {
        judgeVote = judgeWeightage;
        audienceVote = audienceWeightage;
    }

    //this function defines the addresses of finalists
    function selectFinalists(address[] memory arrayOfAddresses) public onlyOwner checkAccess{
        for(uint i = 0; i < arrayOfAddresses.length; i++) {
            require(arrayOfAddresses[i] != address(0), "Invalid address");
        }
        require(arrayOfAddresses.length > 0, "Values can't be zero");
        for(uint i = 0; i < arrayOfAddresses.length; i++) {
            finalists.push(arrayOfAddresses[i]);
        }
    }

    //this function strats the voting process
    function startVoting() public onlyOwner checkAccess {
        require(judges.length > 0 && judgeVote > 0 && audienceVote > 0 && finalists.length > 0, "Please fill the details first!");
        votingStarted = true;
    }

    //this function is used to cast the vote 
    function castVote(address finalistAddress) public checkAccess2 {
        for(uint f = 0; f < voted.length; f++) {
            require(msg.sender != voted[f], "You have already voted");
        }
        bool valid;
        for(uint i = 0; i < finalists.length; i++) {
            if(finalists[i] == finalistAddress) {
                valid = true;
                break;
            }
        }
        require(valid == true, "Invalid Address");
        uint voteWeight = audienceVote;
        for(uint j = 0; j < judges.length; j++) {
            if(msg.sender == judges[j]) {
                voteWeight = judgeVote;
            }
        }
        finalistsPoints[finalistAddress] += voteWeight;
        voted.push(msg.sender);
    }   

    //this function ends the process of voting
    function endVoting() public checkAccess2 onlyOwner {
        end = true;
        address[] memory result = new address[](finalists.length);
        uint count = 1;
        uint maxPoints = 0;
        for(uint i = 0; i < finalists.length; i++) {
            if(finalistsPoints[finalists[i]] > maxPoints) {
                result = new address[](finalists.length);  
                result[0] = finalists[i];
                maxPoints = finalistsPoints[finalists[i]];
                count = 1;
            } else if (finalistsPoints[finalists[i]] == maxPoints) { 
                result[count] = finalists[i];
                count++;
            }
        }

        assembly {
            mstore(result, count)
        }

        winner = result;
    }

    //this function returns the winner/winners
    function showResult() public view returns (address[] memory) {
        require(end == true, "Voting has not ended yet");
        return winner;
    }

}