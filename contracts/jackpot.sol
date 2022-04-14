//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract jackpot {

    address payable _DevWalletAddress;
    address public owner;
    mapping(address => uint256) public balances;

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

    function transferFundToDev (address payable walletAddress, uint256 amount) private returns (bool){
        walletAddress.transfer(amount);
        return true;
    }

    function depositFunds (address payable walletAddress, uint256 amount) public payable {
        require (msg.value >= amount, "Insuficient Funds");

        uint256 devFunds = (amount * 2)/100;
        uint256 withdrawalFunds = (amount * 3)/100;
        uint256 depositamount = (amount - (devFunds + withdrawalFunds));

        walletAddress.transfer(depositamount);
        transferFundToDev(_DevWalletAddress, devFunds);
        balances[msg.sender] += withdrawalFunds;
    }

    function withdraw (uint256 amount, address payable desAdd) public {
        require (balances[msg.sender] >= amount, "Insuficient Funds");

        desAdd.transfer(amount);
        balances[msg.sender] -= amount;
    }
}
