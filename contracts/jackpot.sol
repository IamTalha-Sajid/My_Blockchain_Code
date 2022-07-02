//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract jackpot {

    // struct jackpot{
    //     uint256 jackpotId;
    //     uint256 startingTime;
    //     uint256 endingTime;
    //     address[] refferals;
    // }

    struct referal{
        address referredAddress;
    }

    address payable _DevWalletAddress;
    address public owner;
    mapping(address => uint256) public balances;
    mapping(address => referal) public referals;
    address[] users;
    address[] winningRefAdd;
    uint256 totalFunds;
    bool jackpotIsActivated = false;
    uint256 endingTime;
    uint256 second;
    address winner;
    bool pickedWinner = false;

    constructor () {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function changeDevWallet (address payable devWallet)public onlyOwner{
        _DevWalletAddress = devWallet;
    }

    function startJackpot (uint256 _time) private {
        jackpotIsActivated = true;
        pickedWinner = false;
        second = _time * 60;
        endingTime = block.timestamp + second;
    }

    function transferFundToReferal (address payable walletAddress, uint256 amount) private returns (bool){
        walletAddress.transfer(amount);
        return true;
    }

    function transferFundToDev (address payable walletAddress, uint256 amount) private returns (bool){
        walletAddress.transfer(amount);
        return true;
    }

    function depositFunds (uint256 amount, address refferal) public payable {
        require (msg.value >= amount, "Insuficient Funds");
        require (msg.sender != owner, "Admin Cannot Participate");
        require (block.timestamp < endingTime);

        //Now Jackpot will be Started Automatically with 5 Minutes Time
        if(jackpotIsActivated == true){
            uint256 devFunds = (amount * 2)/100;
            uint256 withdrawalFunds = (amount * 3)/100;
            uint256 depositamount = (amount - (devFunds + withdrawalFunds));
            referals[msg.sender] = referal(refferal);

            totalFunds += depositamount;
            transferFundToDev(_DevWalletAddress, devFunds);
            balances[msg.sender] += withdrawalFunds;
            users.push(msg.sender);
        }
        else {
            startJackpot (5);
            uint256 devFunds = (amount * 2)/100;
            uint256 referalFunds = (amount * 3)/100;
            uint256 depositamount = (amount - (devFunds + referalFunds));

            totalFunds += depositamount;
            uint256 ReferalWinnings;
            ReferalWinnings += referalFunds;
            transferFundToDev(_DevWalletAddress, devFunds);
            users.push(msg.sender);
            jackpotIsActivated = true;
        }
    }

    function pickWinner() public returns (address){
        require (block.timestamp >= endingTime, "Jackpot Still in Progress");
        require (jackpotIsActivated == true, "Jackpot Not Started Yet");
        require (pickedWinner == false, "Winner Already Selected");

        uint256 winningOption;

        jackpotIsActivated = false;
        pickedWinner = true;
        winningOption = rand();
        winner = users[winningOption];
        balances[winner] += totalFunds;

        //Refferal Amount will be Given to the Users who Refered Winner
        for(uint256 i = 0; i<=users.length; i++){
            if (referals[users[i]].referredAddress == winner){
                winningRefAdd.push(users[i]);
            }
        }
        // uint256 referalReward;
        // referalReward = (ReferalWinnings / winningRefAdd.length);

        return (winner);
    }

    function withdraw (uint256 amount, address payable desAdd) public {
        require (balances[msg.sender] >= amount, "Insuficient Funds");

        desAdd.transfer(amount);
        balances[msg.sender] -= amount;
    }

    function rand() internal view returns(uint Ran){
        uint RanNum = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender))) % users.length;
        return RanNum;
    }
}
