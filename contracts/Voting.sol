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
    uint[4] voteCount;
    string[4] options;

    struct vote{
        address userId;
        uint option;
        bool hasVoted;
    }

    address private owner;
    uint public deadline;
    bool public _timerstarted = false;
    bool public _optionsadded = false;
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

    function addOptions(string memory _optionA, string memory _optionB, string memory _optionC, string memory _optionD) public onlyOwner{
        require(_timerstarted == false, "Timer has Already Started You cannot Change Option Now");
        options[0] = _optionA;
        options[1] = _optionB;
        options[2] = _optionC;
        options[3] = _optionD;
        _optionsadded = true;
    }

    function getOptions() public view returns (string memory, string memory, string memory, string memory){
        require(_optionsadded == true, "Options are Not Added Yet");
        return (
        options[0],
        options[1],
        options[2],
        options[3]
        );
    }

    function castVote(address _userId, uint _option) public {
        require(_optionsadded == true, "Options are Not Added Yet");
        require( token.balanceOf(_userId) >= 20, "Token Balance is Less than 20");
        require(_timerstarted == true, "Voting Time haven't Started Yet");
        require(votes[_userId].hasVoted == false, "You Have Already Voted");
        if (_option == 1){
            voteCount[0]++;    
        }
        else if  (_option == 2){
            voteCount[1]++;   
        }
        else if (_option == 3){
            voteCount[2]++; 
        }
        else if (_option == 4){
            voteCount[3]++; 
        }
        votes[_userId].hasVoted = true;
        votes[_userId] = vote(_userId, _option, true);
        token.voted(_userId);
        voters.push(_userId);
    }

    uint winningOption;
    
    function checkWinner() public {
        require(block.timestamp > deadline, "Voting Still in Progress");
        uint largest = 0;
        for (uint i = 0; i <= 3; i++) {
            if (voteCount[i] > largest) {
                largest = voteCount[i];
                winningOption = i+1;
            }
        }
    }

    function checkResult() public view onlyOwner returns (uint, uint, uint, uint){
        return(voteCount[0], voteCount[1], voteCount[2], voteCount[3]);
    }

    function claimReward(address _userId) public returns (string memory){
        require(block.timestamp > deadline, "Voting Still in Progress");
            if (votes[_userId].option == winningOption){
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
