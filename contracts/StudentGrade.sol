// SPDX-License-Identifier: Unlicense

pragma solidity 0.8.0;

contract StructActivity{

    struct student{
        uint256 studentId;
        string studentName;
        string coursName;
        uint256 Grade1;
        uint256 Grade2;
        uint256 Grade3;
        uint256 Grade4;
        uint256 average;
        bool isExist;
    }

    mapping(string => student) public Student;
    uint256 public Sid;
    address public owner;

    constructor(){
        Sid= 1000;
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function registerStudent(string memory _studentName, string memory _coursName) public onlyOwner returns (bool){
        require(Student[_studentName].isExist == false, "User Already Exist");
        Student[_studentName] = student(Sid, _studentName, _coursName, 0, 0, 0, 0, 0, true);
        Sid ++;
        return true;
    }

    function insertGrades(string memory _studentName, uint256 _g1, uint256 _g2, uint256 _g3, uint256 _g4) public onlyOwner returns (bool){
        require(Student[_studentName].isExist == true, "Student Doesn't Exist");
        Student[_studentName].Grade1 = _g1;
        Student[_studentName].Grade2 = _g2;
        Student[_studentName].Grade3 = _g3;
        Student[_studentName].Grade4 = _g4;
        uint256 _average;
        _average = ((Student[_studentName].Grade1 + Student[_studentName].Grade2 + Student[_studentName].Grade3 + Student[_studentName].Grade4)/4);
        Student[_studentName].average = _average;
        return true;
    }

    function findAverageGrade (string memory _studentName) public view onlyOwner returns (uint256) {
        require(Student[_studentName].isExist == true, "Student Doesn't Exist");
        return Student[_studentName].average;
    }
}
