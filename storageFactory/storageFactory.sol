// SPX-License-Identifier: MIT

pragma solidity ^0.8.24;
import "./simpleStorage.sol"; // importing every contract defined in the given file
// if i want  so specify which contract will be exported, i need so specify it like this
import {SimpleStorage} from "./simpleStorage.sol"; // in this way, onlt the contract named SimpleStorage will be inported in this contract
// if i want to impolt multiple contracts i just add them seperated by a comma , like so
// {SimpleStorage, SimpleStorage2}

contract storageFactory{
    // type visability name
    SimpleStorage public simpleStorage; // making a variable named 'simpleStorage' of type contract 'SimpleStorage' that is imported using import keyword

    function createSimpleStorage() public{ //function to create a simpleStorage contract
    // basically when i run this code, it will be like i ran the file i imported above, so like i call another contract in this contract
        simpleStorage = new SimpleStorage(); 
    }

    // when i run this contract and call this function, simpleStorage variable will get an address
    // if the function isnt called, the address of the variable will remain its default value 0x000000000


}
