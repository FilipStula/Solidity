//SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";


contract fundMeTest is Test{
    FundMe fundMe;
    function setUp() external{ // this funciton is always the first function to be exrcuted, so i need to create a contract that will be used 
        fundMe = new FundMe();
    }

    function testDemo() public{
        console.log(msg.sender);
        console.log(address(this));
        console.log(fundMe.owner());
        assertEq(address(this), fundMe.owner());
    }

    function testDeposit() public  {
        vm.expectRevert("Minimum deposit is 5 dollars");
        fundMe.deposit{value: 100000 wei}();
    }
    //console works lkke in javacsript, but we need to run 
    // forge test --vv to see the output
}