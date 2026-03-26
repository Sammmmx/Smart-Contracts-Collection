//SPDX-License-Identifier:MIT

pragma solidity ^0.8.23;

contract MultiSig {

    address[] public Owners;
    uint256 public Threshold;

    constructor(address[] memory _Owners, uint256 _threshold) {
        require(_Owners.length >=2, "At least 2 Owners required");
        require(_threshold >= 2 && _threshold <= _Owners.length, "Invalid Threshold");
        for(uint256 i = 0; i<_Owners.length; i++) {
            Owners.push(_Owners[i]);
        }
        Threshold = _threshold;
    }

    enum States{None, Pending, Executed}

    uint256 length = Owners.length;

    struct TxDetails {
        address receiver;
        uint256 approvals;
        uint256 amount;
        States _state;
    }
    mapping(uint256 => TxDetails) public Transactions;

    mapping(uint256 => mapping(address => bool)) public hasApproved;

    modifier checkId(uint256 _ID) {
        require(Transactions[_ID]._state == States.Pending, "Invalid ID");
        _;
    }

    modifier checkOwner() {
        bool check;
        for(uint256 i = 0; i< Owners.length; i++){
            if(Owners[i] == msg.sender) {
                check = true;
            }
        }
        require(check, "You are not Authorized");
        _;
    }

    event Execute(address to, uint256 _amount, uint256 approvals, States state);

    uint256 IdCount= 1;

    function submitTransaction(address _to, uint256 _amount) checkOwner() public {
        require(_to != address(0), "Invalid address");
        require(_amount> 0, "Empty Transaction");
        hasApproved[IdCount][msg.sender] = true;
        Transactions[IdCount] = TxDetails(_to, 1, _amount, States.Pending);
        IdCount++;

    }

    function Approve(uint256 _txId) public 
    checkOwner()
    checkId(_txId) {
        require(!hasApproved[IdCount][msg.sender], "You are already approved");
        hasApproved[IdCount][msg.sender] = true;
        Transactions[IdCount].approvals++;
    }

    function execute(uint256 _txId) public 
    checkId(_txId) {
        require(Transactions[_txId].approvals >= Threshold, "Threshold not met");
        address _to = Transactions[_txId].receiver;
        uint256 Amount = Transactions[_txId].amount;
        uint256 approvals = Transactions[_txId].approvals;
        Transactions[_txId]._state = States.Executed;
        (bool success, ) = _to.call{value:Amount}("");
        require(success, "Transaction Failed");

        emit Execute(_to, Amount, approvals, States.Executed);
    }

    receive() external payable{}
}