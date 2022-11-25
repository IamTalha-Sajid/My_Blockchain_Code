// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
 
interface IERC1155 {
    function balanceOf(address account, uint256 id) external view returns (uint256);
    function isApprovedForAll(address account, address operator) external view returns (bool);
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;
}

contract NFTMarket {

    IERC1155 public token;
    IERC20 public ERC20;

    struct listing {
        uint256 price;
        address seller;
    }

    struct rent {
        uint256 price;
        address seller;
        uint256 maxTime;
        uint256 totalPrice;
    }

    struct rented {
        uint256 tokenId;
        uint256 returntime;
    }

    constructor() {
        token = IERC1155(0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8);
    }

    mapping(uint256 => listing) public listings;
    mapping(uint256 => rent) public rentlistings;
    mapping(address => uint256) public balances;
    mapping(address => rented) public rentedNFTs;

    function saleNFT (uint256 price, uint256 tokenId) public {
        require (token.balanceOf(msg.sender, tokenId) > 0, "You Dont Own the Token You have Provided");
        require (token.isApprovedForAll(msg.sender, address(this)));

        listings[tokenId] = listing(price, msg.sender);
    }

    function saleNftERC20 (uint256 price, uint256 tokenId, address contractadd) public {
        require (token.balanceOf(msg.sender, tokenId) > 0, "You Dont Own the Token You have Provided");
        require (token.isApprovedForAll(msg.sender, address(this)));
        require (ERC20.approve(address(this), price));

        ERC20 = IERC20(contractadd);
        listings[tokenId] = listing(price, msg.sender);
    }

    function purchaseNFT (uint256 tokenId, uint256 amount) public payable {
        require(token.balanceOf(listings[tokenId].seller, tokenId) >= amount, "Not Enought NFTs Available to Buy");
        require(msg.value >= (listings[tokenId].price * amount), "Insuficient Funds");

        token.safeTransferFrom(listings[tokenId].seller, msg.sender, tokenId, amount, "");
        balances[listings[tokenId].seller] += msg.value;
    }

    function purchaseNftERC20 (uint256 tokenId, uint256 amount) public payable {
        require(token.balanceOf(listings[tokenId].seller, tokenId) >= amount, "Not Enought NFTs Available to Buy");
        require(ERC20.balanceOf(msg.sender) > (listings[tokenId].price * amount), "Insuficient Funds");

        token.safeTransferFrom(listings[tokenId].seller, msg.sender, tokenId, amount, "");
        ERC20.transferFrom(msg.sender, listings[tokenId].seller, amount);
    }

    function withdraw (uint256 amount, address payable desAdd) public {
        require (balances[msg.sender] >= amount, "Insuficient Funds");

        desAdd.transfer(amount);
        balances[msg.sender] -= amount;
    }

    function rentNFT(uint256 _tokenId, uint256 maxtime, uint256 _amount, uint256 totalprice, uint256 unitprice) public payable {
        require (token.isApprovedForAll(msg.sender, address(this)));
        require (token.balanceOf(msg.sender, _tokenId) > 0, "You Dont Own the Given Token");

        rentlistings[_tokenId] = rent(unitprice, msg.sender, maxtime, totalprice);
        token.safeTransferFrom(msg.sender, address(this), _tokenId, _amount, "0x00");
    }

    function borrowNFT(uint256 _tokenId, uint256 _amount, uint256 time) public payable {
        require(token.balanceOf(rentlistings[_tokenId].seller, _tokenId) >= _amount, "Not Enought NFTs Available to Buy");
        require(msg.value >= ((rentlistings[_tokenId].price * _amount) * time), "Insuficient Funds");
        require(rentlistings[_tokenId].maxTime >= time, "NFTs Not Available to Buy for this Time Peiod");

        balances[rentlistings[_tokenId].seller] += msg.value;
        token.safeTransferFrom(address(this), msg.sender, _tokenId, _amount, "0x00");
        uint256 returntime = block.timestamp + time;
        rentedNFTs[msg.sender] = rented(_tokenId, returntime);
    }

    function returnNFT(uint256 _tokenId, uint256 _amount) public {
        require(token.balanceOf(msg.sender, _tokenId) >= _amount, "Not Enought NFTs Available to Buy");
        token.safeTransferFrom(msg.sender, address(this), _tokenId, _amount, "0x00");
    }

    function onERC1155Received(address operator, address from, uint256 id, uint256 value, bytes calldata data) external pure returns (bytes4) {
        return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
    }
}
