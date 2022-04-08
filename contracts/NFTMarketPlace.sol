// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC1155 {
    function balanceOf(address account, uint256 id) external view returns (uint256);
    function isApprovedForAll(address account, address operator) external view returns (bool);
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;
}

contract NFTMarket {

    IERC1155 public token;

    struct listing {
        uint256 price;
        address seller;
    }

    constructor() {
        token = IERC1155(0xd9145CCE52D386f254917e481eB44e9943F39138);
    }

    // mapping(address => mapping(uint => listing)) public listings;
    mapping(uint256 => listing) public listings;
    mapping(address => uint256) public balances;

    function saleNFT (uint256 price, uint256 tokenId) public {
        require (token.balanceOf(msg.sender, tokenId) > 0, "You Dont Own the Given Token");
        require (token.isApprovedForAll(msg.sender, address(this)));

        listings[tokenId] = listing(price, msg.sender);
    }

    function purchaseNFT (uint256 tokenId, uint256 amount) public payable {
        require(token.balanceOf(listings[tokenId].seller, tokenId) >= amount, "Not Enought NFTs Available to Buy");
        require(msg.value > (listings[tokenId].price * amount), "Insuficient Funds");

        token.safeTransferFrom(listings[tokenId].seller, msg.sender, tokenId, amount, "");
        balances[listings[tokenId].seller] += msg.value;
    }

    function withdraw (uint256 amount, address payable desAdd) public {
        require (balances[msg.sender] >= amount, "Insuficient Funds");

        desAdd.transfer(amount);
        balances[msg.sender] -= amount;
    }
}
