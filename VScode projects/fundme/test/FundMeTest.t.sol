//SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {deployFundMe} from "../script/FundMe.s.sol";


contract fundMeTest is Test{
    FundMe fundMe;
    uint256 constant private SEND_VALUE = 100000000000000000 wei; // this is the value that will be used to test the contract
    address private immutable USER = makeAddr("user"); // this will create a new address that will be used as the user address, i will use this user to interact with the contract
    function setUp() external{ // this funciton is always the first function to be exrcuted, so i need to create a contract that will be used 
        deployFundMe deployer = new deployFundMe(); // creating a new instance of the deployer contract
        fundMe = deployer.run(); // calling the run function of the deployer contract to create a new FundMe contract, run() returns a new fundMe contract
        vm.deal(USER, SEND_VALUE); // 1e17 wei
        vm.deal(msg.sender, 1 wei);
    }

    modifier fundUser() {
        vm.prank(USER); // this will make the next command to be executed as if it was the USER who is calling it
        fundMe.deposit{value: SEND_VALUE}(); // this will deposit 10 ether to the contract, now 10 ether will be depositet to the fundMe contract
        _;
    }

    function testOwner() public{
        console.log(msg.sender);
        console.log(address(this));
        console.log(fundMe.getOwner());
        assertEq(msg.sender, fundMe.getOwner()); 
        // here, since this contract is acctually the one sending the request
        // then the owner will be this contract, not msg.sender
    }

    function testDeposit() public  {
        vm.expectRevert();
        fundMe.deposit{value: 10 wei}();
    }
    // this works like so: if the fundMe.deposit() reverts
    // this will be true and the test will pass, otherwise it will fail

    function testWithdraw() public fundUser{

        // i commented these lines, because i will use modifiers after this
        //vm.prank(USER); // this will make the next command to be executed as if it was the USER who is calling it
        //fundMe.deposit{value: 100000000000000000 wei}(); // this will deposit 10 ether to the contract, now 10 ether will be depositet to the fundMe contract
        vm.startPrank(msg.sender); // this will start a prank, which means that everything bettween startPrank and stopPrank will we executed as if it was the msg.sender who is calling these functions
        // there is also vm.prank() which will only execute the next command as the address specified
        // since i set msg.user to be the owner of the contract, only he can withdraw funds from it
        console.log(fundMe.getOwner().balance);
        fundMe.withdraw(); // this will withdraw everything from the contract,
        vm.stopPrank();
        assertEq(USER.balance, 0 ether); // this will check if the balance of the contract is 0
    }

    function testAddFundersToList() public fundUser{
        //vm.prank(USER);
        //fundMe.deposit{value: 100000000000000000 wei}();

        //console.log(fundMe.getFunder(0)); // will print the address of the first funder, in this case address of USER
        assertEq(fundMe.getFunder(0), USER); // this will check if the first funder is the same as the USER address
    }


    function testWithdrawFromMultipleFunders() public{
        uint160 numberOfAddresses = 10;
        uint160 startingIndex = 1;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 depositedBalance = 0;
        vm.txGasPrice(1 wei); // artificially estting the gas price for this transaction
        // this is not possible on the real netowrk
        console.log(gasleft()); // this function will tell us how much gas is left
        // so it will tell us how much gas we are willing to use to execute this transaction
        console.log(tx.gasprice); // this will print the gas price of the transaction
        for(uint160 i = startingIndex;i<numberOfAddresses;i++)
        {
            hoax(address(i),SEND_VALUE); // hoax is used like vm.prank+vm.deal, so prank will be the provided address will do the next tx, and with SEND_VALUE amount
            fundMe.deposit{value: SEND_VALUE}(); // this will deposit 10 ether to the contract, now 10 ether will be depositet to the fundMe contract
            depositedBalance += SEND_VALUE;
        }
        
        console.log(depositedBalance);
        console.log(fundMe.getOwner().balance);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        assertEq(fundMe.getOwner().balance, startingOwnerBalance + depositedBalance); 
        // this will check if the balance of the contract is 0


    }// IN HERE, ADDRESS IS UINT160, SO I NEED TO USE UINT160 TO BE ABLE TO ARTIFICIALLY CREATE ADDRESSES IN A LOOP
    //console works like in javacsript, but we need to run 
    // forge test --vv to see the output
}