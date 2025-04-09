//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract NewProject {
    string public name;
    uint256 public value;

    constructor() {
        name = "Goran";
        value = 5;
    }

    function setName(string memory _name) public {
        name = _name;
    }

    function setValue(uint256 _value) public {
        value = _value;
    }
}
