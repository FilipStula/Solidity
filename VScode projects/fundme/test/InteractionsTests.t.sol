//SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {Test} from "forge-std/Test.sol";
import {FundFundMe, WithdrawFundMe} from "../script/Interactions.s.sol";
import {deployFundMe} from "../script/FundMe.s.sol";
import {FundMe} from "../src/FundMe.sol";

contract InteractionsTest is Test{

    FundFundMe s_funder;
    FundMe s_FundMe;
    address private immutable USER = makeAddr("user");
    uint256 constant private SEND_VALUE = 0.1 ether; // this is the value that will be used to test the contract

    function setUp() external {
        deployFundMe deployer = new deployFundMe(); // creating a new instance of the deployer contract
        s_FundMe = deployer.run(); // calling the run function of the deployer contract to create a new FundMe contract, run() returns a new fundMe contract
        vm.deal(USER, SEND_VALUE);
    }

    function testFundFundMe() public {
        vm.prank(USER);
        s_FundMe.deposit{value: USER.balance}();
        assertEq(USER.balance, 0);
    }

    function testWithdrawFundMe() public{
        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(s_FundMe));
        assertEq(address(s_FundMe).balance, 0);

    }
}