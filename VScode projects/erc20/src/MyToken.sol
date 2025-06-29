// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

contract Token {

    mapping(address => uint256) private balances;

    function name() public pure returns (string memory) {
        return "My Token";
    }

    function symbol() public pure returns (string memory){
        return "MTK";
    }

    function decimals() public pure returns (uint8){
        return 18;
    }

    function totalSupply() public pure returns (uint256) {
        return 100 ether;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner]; // Example balance
    }

    function transfer(address _to, uint256 _value) public returns (bool success){
        
    }
}
