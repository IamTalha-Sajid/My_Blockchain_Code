// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract airDrop{

    address owner;
    address tokenAddress;
    address[] addresses;

    constructor(address _owner){
        owner = _owner;
    }

    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }

    function setTokenAddress (address _tokenAddress) public onlyOwner {
        tokenAddress = _tokenAddress;
    }

    function addAddresses (address[] memory _addresses) public onlyOwner {
        require(addresses.length <= 10, "Maximum number of addresses is 10");
        addresses = _addresses;
    }


}