//SPDX-Licenese -Identifier: MIT
pragma solidity ^0.8.25;    


import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
contract NewToken is ERC20 {

    address private owner;

    event Owner(address indexed owner);
    modifier onlyOwner() {
        emit Owner(owner);
        require(msg.sender == owner, "Not the owner");
        _;
    }
    constructor(uint256 initialSupply) ERC20("Our Token", "OTK") {
        owner = msg.sender;
        _mint(msg.sender, initialSupply);
    }

    function mintTokens(uint256 value) external onlyOwner{
        _mint(msg.sender, value);
    }



}