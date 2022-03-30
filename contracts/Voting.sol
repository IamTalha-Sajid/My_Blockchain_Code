// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.0;

interface IERC721 {
    function mintNFT(address recipient) external returns (uint256);
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function mintReward(address _userAdd) external returns (bool);
    function voted(address _userAdd) external returns (bool);
    function reward(address _userAdd) external returns (bool);
}

contract Voting {

    IERC20 public token;
    IERC721 public NFT;
    address[] voters;

    struct option {
        address userId;
        string optionA;
        string optionB;
        string optionC;
        string optionD;
    }

    struct vote{
        address userId;
        string option;
        bool hasVoted;
    }

    address private owner;
    uint public deadline;
    bool public _timerstarted = false;
    bool public _optionsadded = false;
    mapping(address => option) options;
    mapping(address => vote) votes;

    constructor() {
        token = IERC20(0xC8f459782e3eD1DC403420b310743a19e401e665);
        NFT = IERC721(0xAE71D2e0026ebaf10185Af5b588a161FDCb78d25);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function startTimer (uint _minute) public onlyOwner {
        require (_optionsadded == true, "Add the Options First");
        uint _seconds = _minute * 60;
        deadline=block.timestamp + _seconds;
        _timerstarted = true;
    }

    function addOptions(address userId, string memory _optionA, string memory _optionB, string memory _optionC, string memory _optionD) public onlyOwner{
        require(_timerstarted == false, "Timer has Already Started You cannot Change Option Now");
        options[userId] = option(userId, _optionA, _optionB, _optionC, _optionD);
        _optionsadded = true;
    }

    function getOptions() public view returns (string memory, string memory, string memory, string memory){
        require(_optionsadded == true, "Options are Not Added Yet");
        address userId = owner;
        return (
        options[userId].optionA,
        options[userId].optionB,
        options[userId].optionC,
        options[userId].optionD
        );
    }

    uint voteCountA = 0;
    uint voteCountB = 0;
    uint voteCountC = 0;
    uint voteCountD = 0;

    function castVote(address _userId, string memory _option) public {
        require(_optionsadded == true, "Options are Not Added Yet");
        require( token.balanceOf(_userId) >= 20, "Token Balance is Less than 20");
        require(_timerstarted == true, "Voting Time haven't Started Yet");
        require(votes[_userId].hasVoted == false, "You Have Already Voted");
        if (keccak256(abi.encodePacked(_option)) == keccak256(abi.encodePacked("A"))){
            votes[_userId].hasVoted = true;
            voteCountA++;    
        }
        else if  (keccak256(abi.encodePacked(_option)) == keccak256(abi.encodePacked("B"))){
            votes[_userId].hasVoted = true;
            voteCountB++;   
        }
        else if (keccak256(abi.encodePacked(_option)) == keccak256(abi.encodePacked("C"))){
            votes[_userId].hasVoted = true;
            voteCountC++;
        }
        else if (keccak256(abi.encodePacked(_option)) == keccak256(abi.encodePacked("D"))){
            votes[_userId].hasVoted = true;
            voteCountD++;
        }
        votes[_userId] = vote(_userId, _option, true);
        token.voted(_userId);
        voters.push(_userId);
    }

    string winningOption;
    function checkWinner() public {
        require(block.timestamp > deadline, "Voting Still in Progress");
        if (voteCountA > voteCountB){
            if (voteCountA > voteCountC){
                if (voteCountA > voteCountD){
                    winningOption = "A";
                }
                else{
                    winningOption = "D";
                }
            }
        }
        else if (voteCountB > voteCountC){
            if (voteCountB > voteCountD){
                winningOption = "B";
            }
            else {
                winningOption = "C";
            }
        }
    }

    function checkResult() public view onlyOwner returns (uint, uint, uint, uint){
        return(voteCountA, voteCountB, voteCountC, voteCountD);
    }

    function claimReward(address _userId) public returns (string memory){
        require(block.timestamp > deadline, "Voting Still in Progress");
            if (keccak256(abi.encodePacked(votes[_userId].option)) == keccak256(abi.encodePacked(winningOption))){
                token.mintReward(_userId);
                token.reward(_userId);
                NFT.mintNFT(_userId);
            }
            else{
                token.reward(_userId);
            }
        return ("Reward Sent Successfully");
    }
}
