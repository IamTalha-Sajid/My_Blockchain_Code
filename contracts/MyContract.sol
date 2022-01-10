// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract MyContract {
    uint data;

    function GetData() external view returns(uint) {
        return data;
    }

    function SetData(uint _data) external {
        data = _data;
    }

    function SetDataPrivate(uint _data) private {
        data = _data + 10;
    }
}