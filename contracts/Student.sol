// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Student{
    mapping(uint => StudentData) public data;
    uint256 StudentCount = 0;

    struct StudentData{
            string _rollno;
            string _name;
            string _marks;
        }

    function AddStudent(string memory _rollno, string memory _name, string memory _marks) public {
        StudentCount += 1;
        data[StudentCount] = StudentData(_rollno, _name, _marks);
    }
    function TotalStudent() public view returns(uint){
        return StudentCount;
    }
    function ViewStudent(uint index) public view returns(string memory){
        string memory TR = data[index]._rollno;
        string memory TN = data[index]._name;
        string memory TM = data[index]._marks;
        return string(abi.encodePacked("Roll No :",TR," Name :",TN," Marks :",TM));

    }
}