// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract productManagement {

    //Variables
    address destinationWallet;
    address owner;
    IERC20 token;
    address tokenAddress;

    //Structs
    struct product{
        uint8 id;
        string name;
        uint8 price;
        uint8 quantity;
        bool isExist;
        bool onSale;
    }

    //Mappings
    mapping (uint8 => product) products;
    mapping (address => uint8) balanceCredited;

    //Events
    event productAdded(uint8 id, string name, uint8 price, uint8 quantity);
    event productRemoved(uint8 id);
    event productUpdated(uint8 id, string name, uint8 price, uint8 quantity, bool onSale);
    event productBought(uint8 id, uint8 quantity);

    //Constructor
    constructor () {
        owner = msg.sender;
    }

    //Modifiers
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    //Functions to Manage Products
    function addProduct (uint8 _id, string memory _name, uint8 _price, uint8 _quantity) public {
        require(_price > 0, "Price should be greater than 0");
        require(_quantity > 0, "Quantity should be greater than 0");
        require(products[_id].isExist == false, "Product already exist");

        products[_id] = product(_id, _name, _price, _quantity, true, false);
        emit productAdded(_id, _name, _price, _quantity);
    }

    function checkProduct (uint8 _id) public view returns (bool) {
        return products[_id].isExist;
    }

    function removeProduct (uint8 _id) public {
        require(products[_id].isExist == true, "Product does not exist");

        delete products[_id];
        emit productRemoved(_id);

    }

    //Function to set the Wallet to Recieve USDT Funds
    function setDestinationWallet (address _destinationWallet) public onlyOwner {
        destinationWallet = _destinationWallet;
    }

    function getDestinationWallet () public view returns (address) {
        return destinationWallet;
    }

    //Fuction to set Token Address (USDT Address)
    function setUSDTAddress(address _tokenAddress) public onlyOwner {
        tokenAddress = _tokenAddress;
        token = IERC20(_tokenAddress);
    }

    function getUSDTAddress() public view returns (address) {
        return tokenAddress;
    }

    //Function to List Product on Sale
    function putOnSale(uint8 _id) public onlyOwner {
        require(products[_id].isExist == true, "Product does not exist");
        require(products[_id].onSale == false, "Product is already on sale");

        products[_id].onSale = true;
        emit productUpdated(_id, products[_id].name, products[_id].price, products[_id].quantity, products[_id].onSale);
    }

    //Function to Remove Product from Sale
    function removeFromSale (uint8 _id) public onlyOwner {
        require(products[_id].isExist == true, "Product does not exist");
        require(products[_id].onSale == true, "Product is not put on sale");

        products[_id].onSale = false;
        emit productUpdated(_id, products[_id].name, products[_id].price, products[_id].quantity, products[_id].onSale);
    }

    //Function to Buy Product
    function buyProduct (uint8 _id, uint8 _quantity) public {
        require(products[_id].isExist == true, "Product does not exist");
        require(products[_id].quantity > 0, "Product is out of stock");
        require(products[_id].onSale == true, "Product is not on sale");
        require(products[_id].quantity >= _quantity, "Not Enought Quantity Available");
        require(token.balanceOf(msg.sender) >= (products[_id].price * _quantity), "Insuficient USDT Funds");
        require(token.allowance(msg.sender, address(this)) >= (products[_id].price * _quantity), "USDT Tokens not Approved to the Smart Contract");

        //Transferring Tokens from the Wallet
        token.transferFrom(msg.sender, destinationWallet, products[_id].price * _quantity);
        // emiting an event
        emit productBought(_id, _quantity);
        //Quantity change occurs
        products[_id].quantity -= _quantity;
        // emiting an event
        emit productUpdated(_id, products[_id].name, products[_id].price, products[_id].quantity, products[_id].onSale);

        //Removing Product from Sale if Quantity is 0
        if (products[_id].quantity == 0) {
            removeFromSale(_id);
        }

        //Keeping Track of Balance Credited
        balanceCredited[msg.sender] += products[_id].price * _quantity;
    }

    //Function to Get Product Details
    function getProductDetails (uint8 _id) public view returns (string memory, uint8, uint8, bool) {
        require(products[_id].isExist == true, "Product does not exist");
        return (products[_id].name, products[_id].price, products[_id].quantity, products[_id].onSale);
    }

    //Function to Get Balances Credited
    function getBalanceCredited (address _address) public view returns (uint8) {
        return balanceCredited[_address];
    }

    //Function to Get Total Balance Credited


}