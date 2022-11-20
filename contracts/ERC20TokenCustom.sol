// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract JUSD is ERC20, ERC20Burnable, Pausable, Ownable {

    address payable destinationWallet;
    uint256 buyFees;
    address owner;
    constructor() ERC20("JUSD", "JUSD") {
        _mint(msg.sender, 50000000 * 10 ** decimals());
        owner = msg.sender;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function buyToken(address to, uint256 amount, address currencyToken) public {
        IERC20 token = IERC20(currencyToken);
        require(token.balanceOf(msg.sender) >= (amount + ((amount*buyFees)/100)), "Not enough funds");
        require(allowance(owner, address(this)) >= amount, "Not enough allowance from the Owner");
        require(token.allowance(msg.sender, address(this)) >= (amount + ((amount*buyFees)/100)), "Not enough allowance from the sender");

        //Transferring Tokens from the sender to the destination wallet
        token.transferFrom(msg.sender, address(this), (amount + ((amount*buyFees)/100)));
        //Transferring Tokens from the Owner to the Sender
        transferFrom(owner, msg.sender, amount);
    }

    function setDestinationWallet (address payable _destinationWallet) public onlyOwner {
        destinationWallet = _destinationWallet;
    }

    function withdraw(address currencyToken) public onlyOwner {
        IERC20 token = IERC20(currencyToken);
        require(token.balanceOf(address(this)) > 0, "No tokens to withdraw");
        require(token.allowance(msg.sender, address(this)) >= token.balanceOf(address(this)), "Not enough tokens to withdraw");
        token.transferFrom(address(this), destinationWallet, token.balanceOf(address(this)));
    }

    function checkAvaiableBalace (address currencyToken) public view onlyOwner returns (uint256){
        IERC20 token = IERC20(currencyToken);
        return token.balanceOf(address(this));
    }

    function setBuyFeesPercentage (uint256 _buyFees) public onlyOwner {
        buyFees = _buyFees;
    }

    function getBuyFeesPercentage () public view returns (uint256){
        return buyFees;
    }

    function getDestinationWallet () public view returns (address payable){
        return destinationWallet;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, amount);
    }
}