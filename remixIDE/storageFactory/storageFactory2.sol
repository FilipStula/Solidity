// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {SimpleStorage} from "./simpleStorage.sol";

contract storageFactory2{
    SimpleStorage[] public storageList;
    SimpleStorage newStorage;

    function addStorage() public{
        newStorage = new SimpleStorage();
        storageList.push(newStorage);   
    }

    function sfAddPerson(uint256 number, string memory personName, int256 personNumber) public{
        SimpleStorage storage1 = storageList[number];
        storage1.addPerson(personName, personNumber);
    }

    function sfGetPerson(uint256 number) public view returns(string memory, int256)
    {   
        SimpleStorage storage1 = storageList[number];
        return (storage1.getPersonName(number), storage1.getPersonNumber(number));
    }


}