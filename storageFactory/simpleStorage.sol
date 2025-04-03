// SPDX-License-Identifirer MIT
pragma solidity ^0.8.24;


contract SimpleStorage{
    struct Person{
        int256 favouriteNumber;
        string name;
    }
    mapping(int256 => string) public mapNameToNumber;
    // this is a simpler way to get the data if only one argument is passed
    // this is called mappuing, where i defined that if i put a certain number, i will get the string associated with that string
    // calling the numbers in maps doesnt cost any gas when called
    Person[] people;
    Person person;
    int256 newNumber;

    function addNumber(int256 number) public virtual { // this means that his fucntion can be overriden, in the file inheritance_override.sol, there is an example of this
        newNumber = number;
    }

    function viewNumber() public view returns(int256){
        return newNumber;
    }

    function addPerson(string memory name, int256 number) public {
        people.push(Person(number, name));
        mapNameToNumber[number]= name;  //so whenever i add a new person to the array of people, i also associate that name to the number i provided
        // since the mapping is declared as public, i can access the name of the associated number i provide
        
    }
    function getPerson(uint256 number) public view returns(int256, string memory){
        return(people[number].favouriteNumber, people[number].name);
    }

    function getPersonName(uint256 number) public view returns(string memory){
        return(people[number].name);
    }

    function getPersonNumber(uint256 number) public view returns(int256){
        return (people[number].favouriteNumber);
    }
    // the issue i was encountering here is that, in [] brackets, uint is expected and i was forcing int
}