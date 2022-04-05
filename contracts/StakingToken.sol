// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function mint(address _userAdd, uint _amount) external returns (bool);
    function burn(address _userAdd, uint _amount) external returns (bool);
}

contract Staking {

    struct stake{
        address userId;
        uint amount;
        uint _stakingtime;
        uint totaltime;
    }

    IERC20 public token;
    mapping (address => stake) stakes;
    address[] stakeHolders;

    constructor() {
        token = IERC20(0x32f99155646d147b8A4846470b64a96dD9cBa414);
    }

    function addStake (address _userId, uint _amount) public returns (bool){
        require (_amount <= token.balanceOf(_userId), "You can't Stake More than You Own");
        token.burn(_userId, _amount);
        stakes[_userId] = stake(_userId, _amount, block.timestamp, 0);
        stakeHolders.push(_userId);
        return true;
    }

    function checkStakedToken (address _userId) public view returns (uint){
        return stakes[_userId].amount;
    }

    function removeStake (address _userId, uint _amount) public returns (bool){
        require (_amount <= stakes[_userId].amount, "You cannot UnStake more than you have Staked");
        token.mint(_userId, _amount);
        stakes[_userId].totaltime = ((block.timestamp - stakes[_userId]._stakingtime) * 60);
        stakes[_userId].amount = stakes[_userId].amount - _amount;
        stakeHolders.push(_userId);
        return true;
    }

    function checkStakeHolders() public view returns (address[] memory){
        return stakeHolders;
    }

    function checkStakedTime(address _userId) public view returns(uint){
        return stakes[_userId].totaltime;
    }

}
