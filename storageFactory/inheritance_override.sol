
// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.24;

import {SimpleStorage} from "./simpleStorage.sol";

contract AnotherStorage is SimpleStorage{ // now everything defined inside SimpleStorage is also defined in AnotherStorage

    function addNumber(int256 number) public override //so this declaration is the same as in the imported file, just override is added
    {   
        super.addNumber(4); // this is a way to call the functionn before it has gotten overriden, so basically, this will return 4
        // now number in the declaration will be added to 4 and newNumber will be 4+number
        newNumber = newNumber+number;
    }
}



// when overriding, the function to be overriden needs to have virtual keywoard when defining the funciton
// the function that overrides, will have override keywoard in the function declaration