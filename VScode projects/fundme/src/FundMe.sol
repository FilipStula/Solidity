// SPDC-licenase-Identifier: MIT
pragma solidity ^0.8.24;

import {etheriumConverter} from "./EtheriumConverter.sol";

contract FundMe {
    using etheriumConverter for uint256;
    address immutable private i_owner;
    address[] private funders;
    uint256 constant public MINIMUM_USD = 5 * 1e18;
    mapping(address=>uint256) mapAddressToDeposit;
    address immutable private dataFeed;

    error OwnerOnly();

    constructor(address _dataFeed) {
        i_owner = msg.sender;
        dataFeed = _dataFeed;
    }

    function getOwner() public view returns(address){
        return i_owner;
    }

    function getFunder(uint256 index) public view returns(address){
        return funders[index];
    }

    function getFunderDeposit(address funder) public view returns(uint256){
        return mapAddressToDeposit[funder];
    }

    function deposit() public payable returns(bool){
        require(msg.value.getUsd(dataFeed) > MINIMUM_USD, "Minimum deposit is 5 dollars");
        funders.push(msg.sender);
        mapAddressToDeposit[msg.sender] = msg.value;
        return true;
    }

    function withdraw() public payable OnlyOwner(){
        (bool callSuccess,) = payable(i_owner).call{value: address(this).balance}("");
        require(callSuccess, "unable to withdraw ETH");
        funders = new address[](0);
    }

    modifier OnlyOwner(){
        require(msg.sender == i_owner, OwnerOnly());
        _; // to execute everything after the above condition
    }

    receive() external payable{ // if there is no metadata, but there is some value passed
        deposit();
    }

    fallback() external payable{ // if there is metadata, or there is some value passed but no receive function is declared
        deposit();
    }
}
