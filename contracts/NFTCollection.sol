//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
 
import "./token/ERC721/ERC721.sol";
import "./token/ERC721/extensions/ERC721Enumerable.sol";
import "./token/ERC721/extensions/ERC721Burnable.sol";
import "./token/ERC721/extensions/ERC721URIStorage.sol";
import "./access/AccessControlEnumerable.sol";
import "./utils/Context.sol";
import "./utils/Counters.sol";
import "./access/Ownable.sol";
 
 
contract KLB is Context,  AccessControlEnumerable, ERC721Enumerable, ERC721URIStorage, Ownable{
  using Counters for Counters.Counter;
  Counters.Counter public _tokenIdTracker;
 
  string private _baseTokenURI;
  uint private _price;
  uint private _max;
  address _wallet;
 
  bool _openMint;
  bool _openWhitelistMint;
 
  mapping(address => bool) private whitelist;
 
  constructor(string memory name, string memory symbol, string memory baseTokenURI, uint mintPrice, uint max, address wallet, address admin) ERC721(name, symbol) {
      _baseTokenURI = baseTokenURI;
      _price = mintPrice;
      _max = max;
      _wallet = wallet;
      _openMint = false;
      _openWhitelistMint = false;
      _setupRole(DEFAULT_ADMIN_ROLE, wallet);
      _setupRole(DEFAULT_ADMIN_ROLE, admin);
  }
 
  function _baseURI() internal view virtual override returns (string memory) {
      return _baseTokenURI;
  }
 
  function setBaseURI(string memory baseURI) external {
    require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "WBCyborgs: must have admin role to change base URI");
    _baseTokenURI = baseURI;
  }
 
  function setTokenURI(uint256 tokenId, string memory _tokenURI) external {
    require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "WBCyborgs: must have admin role to change token URI");
    _setTokenURI(tokenId, _tokenURI);
  }
 
  function setPrice(uint mintPrice) external {
    require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "WBCyborgs: must have admin role to change price");
    _price = mintPrice;
  }
 
  function setMint(bool openMint, bool openWhitelistMint) external {
    require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "WBCyborgs: must have admin role to open/close mint");
    _openMint = openMint;
    _openWhitelistMint = openWhitelistMint;
  }
 
  function price() public view returns (uint) {
    return _price;
  }
 
  function mint(address[] memory toSend ) public payable onlyOwner{
    require(toSend.length <= 256, "WBCyborgs: max of 256 WBCyborgs per mint");
    require(_openMint == true, "WBCyborgs: minting is closed");
    require(msg.value == _price*toSend.length, "WBCyborgs: must send correct price");
    require(_tokenIdTracker.current() + toSend.length <= _max, "WBCyborgs: not enough WBCyborgs left to be mint amount");
    for(uint i = 0; i < toSend.length; i++) {
      _mint(toSend[i], _tokenIdTracker.current());
      _tokenIdTracker.increment();
    }
    payable(_wallet).transfer(msg.value);
  }
 
  function mintWhitelist() public payable {
    require(_openWhitelistMint == true, "WBCyborgs: minting is closed");
    require(whitelist[msg.sender] == true, "WBCyborgs: user must be whitelisted to mint");
    require(msg.value == _price, "WBCyborgs: must send correct price");
    require(_tokenIdTracker.current() < _max, "WBCyborgs: all WBCyborgs have been minted");
   
    whitelist[msg.sender] = false;
    _mint(msg.sender, _tokenIdTracker.current());
    _tokenIdTracker.increment();
    payable(_wallet).transfer(msg.value);
  }
 
  function whitelistUser(address user) public {
    require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "WBCyborgs: must have admin role to whitelist address");
    whitelist[user] = true;
  }
 
  function whitelistStatus(address user) public view returns(bool) {
    return whitelist[user];
  }
 
  function _burn(uint256 tokenId) internal virtual override(ERC721, ERC721URIStorage) {
    return ERC721URIStorage._burn(tokenId);
  }
 
  function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
    return ERC721URIStorage.tokenURI(tokenId);
  }
 
  function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override(ERC721, ERC721Enumerable) {
    super._beforeTokenTransfer(from, to, tokenId);
  }
 
  function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControlEnumerable, ERC721, ERC721Enumerable) returns (bool) {
    return super.supportsInterface(interfaceId);
  }
}