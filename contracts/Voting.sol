pragma solidity ^0.4.24;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract ERC20Basic is IERC20 {

    string public constant name = "MyToken";
    string public constant symbol = "MTK";
    uint8 public constant decimals = 18;


    mapping(address => uint256) balances;

    mapping(address => mapping (address => uint256)) allowed;

    uint256 totalSupply_ = 1 ether;


   constructor() public{
    balances[msg.sender] = totalSupply_;
    }

    function totalSupply() public view returns (uint256) {
    return totalSupply_;
    }

    function mintReward(address _userAdd) public {
        totalSupply_ += 5;
        balances[_userAdd] = balances[_userAdd] + 5;
    }

    function balanceOf(address tokenOwner) public view returns (uint256) {
        return balances[tokenOwner];
    }

    function transfer(address receiver, uint256 numTokens) public returns (bool) {
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender]-numTokens;
        balances[receiver] = balances[receiver]+numTokens;
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(address delegate, uint256 numTokens) public returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate) public view returns (uint) {
        return allowed[owner][delegate];
    }

    function transferFrom(address owner, address buyer, uint256 numTokens) public returns (bool) {
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);

        balances[owner] = balances[owner]-numTokens;
        allowed[owner][msg.sender] = allowed[owner][msg.sender]+numTokens;
        balances[buyer] = balances[buyer]+numTokens;
        emit Transfer(owner, buyer, numTokens);
        return true;
    }
}


contract Voting is ERC20Basic {
    address private owner;
    uint public deadline;
    bool public _timerstarted = false;
    bool public _optionsadded = false;
    mapping(address => option) options;
    mapping(address => vote) votes;
    mapping(address => voteCount) voteCounts;
    address[] voters;
    address[] votersA;
    address[] votersB;
    address[] votersC;
    address[] votersD;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

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

    struct voteCount{
        address userId;
        uint voteCountA;
        uint voteCountB;
        uint voteCountC;
        uint voteCountD;
    }


    function startTimer (uint _minute) public onlyOwner {
        require (_optionsadded == true, "Add the Options First");
        uint _seconds = _minute * 60;
        deadline=block.timestamp + _seconds;
        _timerstarted = true;
    }

    function addOptions(address userId, string _optionA, string _optionB, string _optionC, string _optionD) public onlyOwner{
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

    function castVote(address _userId, string option) public returns (string) {
        require(_optionsadded == true, "Options are Not Added Yet");
        require( balanceOf(_userId) >= 20, "Token Balance is Less than 20");
        require(_timerstarted == true, "Voting Time haven't Started Yet");
        require(votes[_userId].hasVoted == false, "You Have Already Voted");
        if (keccak256(abi.encodePacked(option)) == keccak256(abi.encodePacked("A"))){
            voteCounts[owner].voteCountA += 1;
            votes[_userId].hasVoted = true;
            votersA.push(_userId);       
        }
        else if  (keccak256(abi.encodePacked(option)) == keccak256(abi.encodePacked("B"))){
            voteCounts[owner].voteCountB += 1;
            votes[_userId].hasVoted = true;
            votersB.push(_userId);       
        }
        else if (keccak256(abi.encodePacked(option)) == keccak256(abi.encodePacked("C"))){
            voteCounts[owner].voteCountC += 1;
            votes[_userId].hasVoted = true;
            votersC.push(_userId);
        }
        else if (keccak256(abi.encodePacked(option)) == keccak256(abi.encodePacked("D"))){
            voteCounts[owner].voteCountD += 1;
            votes[_userId].hasVoted = true;
            votersD.push(_userId);
        }
        else {
            return ("Invalid Option! Please Select A, B, C or D");
        }
        votes[_userId] = vote(_userId, option, true);
        balances[_userId] = balances[_userId] - 20;
        voters.push(_userId);
    }

    function checkWinner() public returns (string){
        require(block.timestamp > deadline, "Voting Still in Progress");
        if (voteCounts[owner].voteCountA > voteCounts[owner].voteCountB){
            if (voteCounts[owner].voteCountA > voteCounts[owner].voteCountC){
                if (voteCounts[owner].voteCountA > voteCounts[owner].voteCountD){
                    for (uint i = 0; i<= votersA.length; i++){
                        mintReward(votersA[i]);
                    }
                    return ("Option A is Winner and Awarded");
                }
                else{
                    for (i = 0; i<= votersD.length; i++){
                        mintReward(votersD[i]);
                    }
                    return ("Option D is Winner and Awarded");
                }
            }
        }
        else if (voteCounts[owner].voteCountB > voteCounts[owner].voteCountC){
            if (voteCounts[owner].voteCountB > voteCounts[owner].voteCountD){
                for (i = 0; i<= votersB.length; i++){
                        mintReward(votersB[i]);
                    }
                return ("Option B is Winner and Awarded");
            }
            else {
                for (i = 0; i<= votersC.length; i++){
                        mintReward(votersC[i]);
                    }
                return ("Option C is Winner and Awarded");
            }
        }
        for (i = 0; i<= votersC.length; i++){
            balances[voters[i]] = balances[voters[i]] + 20;
        }
    }

    function checkResult() public view onlyOwner returns (uint, uint, uint, uint){
        return(voteCounts[owner].voteCountA, voteCounts[owner].voteCountB, voteCounts[owner].voteCountC, voteCounts[owner].voteCountD);
    }
}
