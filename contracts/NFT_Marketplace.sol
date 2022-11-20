// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTMarket is Ownable{

    uint256 maxRoyaltyPercentage;
    uint256 ownerPercentage;
    address payable ownerFeesAccount;
    address owner;

    //Structs
    struct listingFixPrice {
        uint256 price;
        address seller;
    }

    struct royalty {
        address payable creator;
        uint256 percentageRoyalty;
    }

    struct nft {
        address contractAddress;
        uint256 amount;
        address creator;
    }

    //Constructor
    constructor() {}

    //Events
    event tokenListedFixPrice(address indexed seller, uint256 indexed tokenId, uint256 indexed price);
    event tokenUnlistedFixPrice(address indexed seller, uint256 indexed tokenId);
    event nftBoughtFixPrice(address indexed buyer, uint256 indexed tokenId, uint256 indexed price);

    //Mappings
    mapping(address => mapping(uint256 =>  listingFixPrice)) listingFixPrices;
    mapping(address => mapping(uint256 => royalty)) royalties;
    mapping(address => nft) nfts;
    mapping(address => uint256) balanceOf;

    function setMaxRoyaltyPercentage(uint256 _maxRoyaltyPercentage) public onlyOwner {
        maxRoyaltyPercentage = _maxRoyaltyPercentage;
    }

    function setOwnerPercentage(uint256 _ownerPercentage) public onlyOwner {
        ownerPercentage = _ownerPercentage;
    }

    function setOwnerAccount(address payable _ownerFeesAccount) public onlyOwner {
        ownerFeesAccount = _ownerFeesAccount;
    }

    function listNftFixPrice (uint256 _price, address _token, uint256 _tokenId, address payable _creator, uint256 _royalty) public {
        require(_token != address(0), "Token address cannot be 0");
        require (IERC721(_token).ownerOf(_tokenId) == msg.sender, "You Dont Own the Given Token");
        require (_price > 0, "Price Must Be Greater Than 0");
        require (IERC721(_token).isApprovedForAll(msg.sender, address(this)), "This Contract is not Approved");
        require(_royalty <= maxRoyaltyPercentage, "Royalty Percentage Must Be Less Than Or Equal To Max Royalty Percentage");

        listingFixPrices[_token][_tokenId] = listingFixPrice(_price, msg.sender);
        royalties[_token][_tokenId] = royalty(_creator, _royalty);
        emit tokenListedFixPrice(msg.sender, _tokenId, _price);

    }

    function unlistNftFixPrice (address _token, uint256 _tokenId) public {
        require(_token != address(0), "Token address cannot be 0");
        require (IERC721(_token).ownerOf(_tokenId) == msg.sender, "You Dont Own the Given Token");
        delete listingFixPrices[_token][_tokenId];
        delete royalties[_token][_tokenId];
        emit tokenUnlistedFixPrice(msg.sender, _tokenId);
    }

    function buyNftFixedPrice (address _token, uint256 _tokenId) public payable {
        require(_token != address(0), "Token address cannot be 0");
        require(msg.value >= listingFixPrices[_token][_tokenId].price, "You Must Pay At Least The Price");

        uint256 feesToPayOwner = listingFixPrices[_token][_tokenId].price * ownerPercentage / 100;
        uint256 royaltyToPay = listingFixPrices[_token][_tokenId].price * royalties[_token][_tokenId].percentageRoyalty / 100;
        uint256 totalPrice = msg.value - royaltyToPay - feesToPayOwner;
        IERC721(_token).safeTransferFrom(listingFixPrices[_token][_tokenId].seller, msg.sender, _tokenId);
        balanceOf[listingFixPrices[_token][_tokenId].seller] += totalPrice;
        royalties[_token][_tokenId].creator.transfer(royaltyToPay);
        ownerFeesAccount.transfer(feesToPayOwner);
        unlistNftFixPrice(_token, _tokenId);
        emit nftBoughtFixPrice(msg.sender, _tokenId, msg.value);
    }

    function withdraw (uint256 amount, address payable desAdd) public {
        require (balanceOf[msg.sender] >= amount, "Insuficient Funds");
        desAdd.transfer(amount);
        balanceOf[msg.sender] -= amount;
    }

}
