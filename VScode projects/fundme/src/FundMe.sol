// SPDC-licenase-Identifier: MIT
pragma solidity ^0.8.24;

import {etheriumConverter} from "src/EtheriumConverter.sol";

contract FundMe {
    using etheriumConverter for uint256;
    address immutable public owner;
    address[] funders;
    uint256 depositedValue;
    uint256 constant public MINIMUM_USD = 5 * 1e18;
    mapping(address=>uint256) mapAddressToDeposit;

    error OwnerOnly();
    constructor() {
        owner = msg.sender;
    }

    function deposit() public payable returns(bool){
        require(msg.value.getUsd() > MINIMUM_USD, "Minimum deposit is 5 dollars");
        funders.push(msg.sender);
        mapAddressToDeposit[msg.sender] = msg.value;
        return true;
    }

    function withdraw() public payable OnlyOwner(){
        (bool callSuccess,) = payable(owner).call{value: address(this).balance}("");
        require(callSuccess, "unable to send ETH");
        funders = new address[](0);
    }

    modifier OnlyOwner(){
        require(msg.sender == owner, OwnerOnly());
        _;
    }

    receive() external payable{
        deposit();
    }

    fallback() external payable{
        deposit();
    }
}
