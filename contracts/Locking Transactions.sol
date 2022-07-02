// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract transactionLocking {
    enum Status {
        Waiting, //0
        Pending, //1
        Approved //2
    }

    struct lock {
        address userId;
        uint256 amount;
        address token;
        address payable to;
        uint256 lockTime;
        bool locked;
        Status _status;
    }

    struct transaction {
        uint256 txId;
        address userId;
        uint256 amount;
        address token;
        address payable to;
        Status _status;
    }

    struct erc20token {
        address tokenAddress;
        bool isExist;
    }

    //Events
    event transactionCreated(
        uint256 txId,
        address userId,
        uint256 amount,
        address to,
        Status _status
    );
    event statusChanged(uint256 txId, uint256 _time, Status _status);

    //Variables
    mapping(address => lock) locks; //Manages Locked Transactions and Complete them
    mapping(address => mapping(uint256 => transaction)) transactions; //Records all the Transactions and their Status
    mapping(address => uint256[]) userTxIds; //Tracks Record of all the Transactions Performed by a Specific User
    mapping(address => erc20token) erc20tokens; //Track all the Tokens that are being used
    address owner;
    uint256 transactionId = 1;

    //Constructor
    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only Owner can do this");
        _;
    }

    /*    MANAGING TOKENS     */
    //Add a new token
    function addNewToken(address _token) public onlyOwner returns (bool) {
        erc20tokens[_token] = erc20token(_token, true);
        return true;
    }

    function deleteToken(address _token) public onlyOwner returns (bool) {
        delete erc20tokens[_token];
        return true;
    }

    function pauseToken(address _token) public onlyOwner returns (bool) {
        erc20tokens[_token].isExist = false;
        return true;
    }

    function unPauseToken(address _token) public onlyOwner returns (bool) {
        erc20tokens[_token].isExist = true;
        return true;
    }

    function checkToken(address _token) public view onlyOwner returns (bool) {
        return erc20tokens[_token].isExist;
    }

    //Function to send Tokens
    function sendTokenToSmartContract(
        address _token,
        address payable _to,
        uint256 _amount,
        uint256 _lockTime
    ) public returns (uint256) {
        require(
            IERC20(_token).allowance(msg.sender, address(this)) >= _amount,
            "Not Approved the Contract to use Tokens"
        );
        require(erc20tokens[_token].isExist == true, "Token does not exist");

        //Initiating the Transactions
        uint256 time = block.timestamp + _lockTime;
        locks[msg.sender] = lock(
            msg.sender,
            _amount,
            _token,
            _to,
            time,
            true,
            Status.Pending
        );
        recordTransaction(
            transactionId,
            msg.sender,
            _amount,
            _token,
            _to,
            Status.Pending
        );
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);

        //Managing Transactions
        uint256 txId = transactionId;
        emit transactionCreated(txId, msg.sender, _amount, _to, Status.Pending);
        transactionId += 1;

        return txId;
    }

    //Function to Approve Token Transaction Immediately
    function approveTokenTransaction(uint256 _txId)
        public
        returns (bool)
    {
        require(locks[msg.sender].locked == true, "No Tokens Locked");
        require(erc20tokens[(transactions[msg.sender][_txId].token)].isExist == true, "Token does not exist");
        locks[msg.sender]._status = Status.Approved;
        transactions[msg.sender][_txId]._status = Status.Approved;
        IERC20(transactions[msg.sender][_txId].token).transferFrom(
            address(this),
            locks[msg.sender].to,
            locks[msg.sender].amount
        );

        //Event of Changing Status
        emit statusChanged(_txId, block.timestamp, Status.Approved);

        return true;
    }

    //Perform Transaction after Time is Up
    function performTokenTransaction(uint256 _txId) public {
        require(erc20tokens[transactions[msg.sender][_txId].token].isExist == true, "Token does not exist");
        require(locks[msg.sender].locked == true, "No Tokens Locked");
        require(
            locks[msg.sender].lockTime < block.timestamp,
            "Locked Time Not Completed"
        );
        IERC20(transactions[msg.sender][_txId].token).transferFrom(
            address(this),
            transactions[msg.sender][_txId].to,
            transactions[msg.sender][_txId].amount
        );
    }

    //Function to Get Transaction Status
    function checkStatusOfTransaction(uint256 _txId)
        public
        view
        returns (Status)
    {
        require(locks[msg.sender].locked == true, "No Tokens Locked");
        return transactions[msg.sender][_txId]._status;
    }

    //Function to send Tokens
    function sendETHToSmartContract(address payable _to, uint256 _lockTime)
        public
        payable
        returns (uint256)
    {
        require(msg.value > 0, "Can't Lock 0 ETH");

        uint256 time = block.timestamp + _lockTime;
        locks[msg.sender] = lock(
            msg.sender,
            msg.value,
            0x000000000000000000000000000000000000dEaD,
            _to,
            time,
            true,
            Status.Pending
        );
        recordTransaction(
            transactionId,
            msg.sender,
            msg.value,
            0x000000000000000000000000000000000000dEaD,
            _to,
            Status.Pending
        );

        //Managing Transactions
        uint256 txId = transactionId;
        emit transactionCreated(
            txId,
            msg.sender,
            msg.value,
            _to,
            Status.Pending
        );
        transactionId += 1;

        return txId;
    }

    //Function to Approve Token Transaction Immediately
    function approveETHTransaction(uint256 _txId) public returns (bool) {
        require(locks[msg.sender].locked == true, "No Funds Locked");
        locks[msg.sender]._status = Status.Approved;
        transactions[msg.sender][_txId]._status = Status.Approved;
        (transactions[msg.sender][_txId].to).transfer(transactions[msg.sender][_txId].amount);

        //Event of Changing Status
        emit statusChanged(_txId, block.timestamp, Status.Approved);

        return true;
    }

    //Perform ETH Transaction after Time is Up
    function performETHTransaction(uint256 _txId) public {
        require(locks[msg.sender].locked == true, "No Funds Locked");
        require(
            locks[msg.sender].lockTime < block.timestamp,
            "Locked Time Not Completed"
        );
        (transactions[msg.sender][_txId].to).transfer(
            transactions[msg.sender][_txId].amount
        );
    }

    //Record Transactions
    function recordTransaction(
        uint256 _txId,
        address _user,
        uint256 _amount,
        address _token,
        address payable _to,
        Status _status
    ) internal {
        transactions[msg.sender][_txId] = transaction(
            _txId,
            _user,
            _amount,
            _token,
            _to,
            _status
        );
        userTxIds[msg.sender].push(_txId);
    }

    //Function to check Transaction Status
    function checkTransactionStatus(uint256 _txId)
        public
        view
        returns (Status)
    {
        return transactions[msg.sender][_txId]._status;
    }

    //Function to check all Transactions of a UserId
    function checkUserTransactions(address _userId)
        public
        view
        returns (uint256[] memory)
    {
        return userTxIds[_userId];
    }

    //Function to get Transaction Details
    function getTransactionDetails(uint256 _txId)
        public
        view
        returns (
            address,
            uint256,
            address,
            address,
            Status
        )
    {
        return (
            transactions[msg.sender][_txId].userId,
            transactions[msg.sender][_txId].amount,
            transactions[msg.sender][_txId].token,
            transactions[msg.sender][_txId].to,
            transactions[msg.sender][_txId]._status
        );
    }
}
