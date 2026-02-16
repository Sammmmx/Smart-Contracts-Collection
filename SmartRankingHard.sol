// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract SmartRanking {

    struct exam {
        uint rollNumber;
        uint marks;
        uint rank;
    }
    mapping(uint => exam) student;

    uint count = 0;

    event StudentList (uint roll, uint Rmarks);

    //this function insterts the roll number and corresponding marks of a student
    function insertMarks(uint _rollNumber, uint _marks) public {
        student[count].rollNumber = _rollNumber;
        student[count].marks = _marks;
        count++;

        emit StudentList(_rollNumber, _marks);
    }



    //this function returnsthe marks obtained by the student as per the rank
    function scoreByRank(uint rank) public view returns(uint) {
        uint[] memory ranks = new uint[](count);
        require(count > 0, "No data");
        uint rankcount = 0;
        uint max_marks = 0;
        for(uint i = 0; i < count; i++) {
            if(student[i].marks > max_marks) {
                max_marks = student[i].marks;
                ranks[rankcount] = student[i].marks;
            }
        }
        rankcount++;
        for(uint j = max_marks-1; j > 0; j--) {
            for(uint t = 0; t < count; t++) {
                if(student[t].marks == j) {
                    max_marks = student[t].marks;
                    ranks[rankcount] = student[t].marks;
                    rankcount++;
                }
            }
        }
        return ranks[rank-1];
    }

    //this function returns the roll number of a student as per the rank
    function rollNumberByRank(uint rank) public view returns(uint) {
        uint[] memory ranks = new uint[](count);
        require(count > 0, "No data");
        uint rankcount = 0;
        uint max_marks = 0;
        for(uint i = 0; i < count; i++) {
            if(student[i].marks > max_marks) {
                max_marks = student[i].marks;
                ranks[rankcount] = student[i].rollNumber;
            }
        }
        rankcount++;
        for(uint j = max_marks-1; j > 0; j--) {
            for(uint t = 0; t < count; t++) {
                if(student[t].marks == j) {
                    max_marks = student[t].marks;
                    ranks[rankcount] = student[t].rollNumber;
                    rankcount++;
                }
            }
        }
        return ranks[rank-1];
    }

}