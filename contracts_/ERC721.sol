// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract MyNFT is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721("MyNFT" , "NFT") {}

    function mintNFT(address recipient)
        external onlyOwner
        returns (uint256)
    {
        _tokenIds.increment();
        string memory tokenURI = "https://gateway.pinata.cloud/ipfs/QmPFpmfD8HaaozEfAWFysEQDcvPJSALGnNL2mUQYbNtgtS/MyPhoto.jpg";
        uint256 newItemId = _tokenIds.current();
        _mint(recipient, newItemId);
        _setTokenURI(newItemId, tokenURI);

        return newItemId;
    }
}
