// SPDX-License-Identifier: UNLICENSED
pragma solidity ^ 0.8.0;
//KYC Verify Contract
contract kycVerification {

    address public RBI;

    constructor () {
        RBI=msg.sender; // Initialising RBI as owner of the smart contract
    }

    modifier onlyOwner () {
        require(msg.sender == RBI, "Only RBI can perform this action"); // access modifier to add Bank details only by RBI,else error.
        _;
    }

    struct Bank {
        string bankName;
        address bankAddress;
        bool kycPermission;
        bool blocked;
    }

    mapping (address => Bank) banks; // mapping unique address to bank

    function addNewBankbyRBI (string memory _bankName, address _bankAddress) public onlyOwner returns (bool) {
        banks[_bankAddress].bankName=_bankName;
        banks[_bankAddress].bankAddress=_bankAddress;
        return true;
    }
    
    function blockBankFromAddingCustomer (address _bankAddress) public onlyOwner{
        banks[_bankAddress].blocked=true;
    }

    function allowBanktoAddCustomer (address _bankAddress) public onlyOwner{
        banks[_bankAddress].blocked=false;
    }

    function allowBankToDoKYC (address _bankAddress) public onlyOwner{
        banks[_bankAddress].kycPermission=true;
    }

    function blockBankToDoKYC (address _bankAddress) public onlyOwner{
        banks[_bankAddress].kycPermission=false;
    }

    function kycStatus (address _bankAddress) public view returns (string memory){
        if(banks[_bankAddress].blocked==false){
            if(banks[_bankAddress].kycPermission==true){
            return ("Banks are Allowed to Add Customer and Allowed to do KYC");
            }
            else{
                return ("Banks are Allowed to Add Customer but Not Allowed to do KYC");
            }
        }
        else {
            return ("Banks are Not Allowed to Add Customer");
        }
    }

    struct Customer {
        string bankName;
        address bankAddress;
        uint32 customerID;
        uint64 aadhaarNumber; //aadhaarNumber can be unique customerID.Take call
        string customerName;
    }

    mapping(uint256 => Customer) customers;
    uint256 customerCount = 0;

    function addNewCustomerbyBank (string memory _bankName, address _bankAddress, uint32 _customerID, uint64 _aadhaarNumber, string memory _customerName) public returns (bool){
        require(banks[_bankAddress].blocked==false, "You do not Have the Permission to Add Customer");
        customers[_customerID] = Customer(_bankName, _bankAddress, _customerID, _aadhaarNumber, _customerName);
        customerCount++;
        return true;
    }

    function queryCustomerByID(uint64 _customerID) public view returns ( string memory _customerName, string memory _bankName, uint64 _aadhaarNumber, address _bankAddress ){
        return (
            customers[_customerID].customerName,
            customers[_customerID].bankName,
            customers[_customerID].aadhaarNumber,
            customers[_customerID].bankAddress
        );
    }
}