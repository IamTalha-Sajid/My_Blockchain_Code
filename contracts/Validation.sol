// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
contract Validation {
    mapping(address => string) private _password;
    mapping(address => string) private _username;
    mapping(address => string) private _email;
    mapping(address => bool) private islogged;
    mapping(address => bool) private isForgot;
    mapping(address => uint) private _otp;
    function Signup(
        string memory Username,string memory Password, string memory Email)
        public {
        require(islogged[msg.sender] == false);
        _username[msg.sender] = Username;
        _password[msg.sender] = Password;
        _email[msg.sender] = Email;
    }
    function Login(string memory Username, string memory Password) public{
        require(islogged[msg.sender] == false);
        require(keccak256(abi.encodePacked((_username[msg.sender]))) == keccak256(abi.encodePacked((Username))));
        require(keccak256(abi.encodePacked((_password[msg.sender]))) == keccak256(abi.encodePacked((Password))));
        islogged[msg.sender] = true;
    }
    function CheckUser() public view returns (string memory) {
        if (islogged[msg.sender] == true)
            return _username[msg.sender];
        else
            return"No User, Please Login First";
    }
    function ForgotPassword(string memory Email) public {
        require (islogged[msg.sender] == false);
        require(keccak256(abi.encodePacked((_email[msg.sender]))) == keccak256(abi.encodePacked((Email))));
        _otp[msg.sender] = rand();
        isForgot[msg.sender] = true;
    }
    function checkOtp() public view returns(uint) {
        require(isForgot[msg.sender] == true);
        return _otp[msg.sender];
    }
    function ChangePassword(uint otp, string memory password, string memory confirmpassword) public{
        require(keccak256(abi.encodePacked((password))) == keccak256(abi.encodePacked((confirmpassword))));
        require(_otp[msg.sender] != 0);
        require(_otp[msg.sender] == otp);
        _password[msg.sender] = password;
    }
    function ResetPassword(string memory OldPassword, string memory NewPassword, string memory ConfirmPassword) public {
        require(keccak256(abi.encodePacked((NewPassword))) == keccak256(abi.encodePacked((ConfirmPassword))));
        require(keccak256(abi.encodePacked((_password[msg.sender]))) == keccak256(abi.encodePacked((OldPassword))));
        require(islogged[msg.sender] == true);
        _password[msg.sender] = NewPassword;
    }
    function Logout() public{
        require(islogged[msg.sender] == true);
        islogged[msg.sender] = false;
    }
    function rand() internal view returns(uint Ran){
        uint RanNum = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender))) % 999999;
        while(bytes(abi.encodePacked(RanNum)).length != 6){
            RanNum = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender))) % 999999;
            return RanNum;
        }
    }
}
