// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

//Imports
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

//Contract of the NFTs
contract PowerUp is ERC721, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    mapping (address => uint) private _powerUps;

//Constructor of the Smart Contract
    constructor() ERC721("MyNFTs", "NFT") {}

//Function to mint the NFTs with a Custom URI
    function safeMint(address to, string memory uri) public payable{
        require(_powerUps[msg.sender] <= 5, "You can only mint upto 5 times");
        require(msg.value == 0, "You can only mint with 0.00 value");
        require(msg.value >= 1*10**17, "You can only mint with 0.1 BNBs");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _powerUps[msg.sender]++;
        _setTokenURI(tokenId, uri);
    }

    function transferOwnership(address newOwner) public virtual override onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    // The following functions are overrides required by Solidity.
    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}