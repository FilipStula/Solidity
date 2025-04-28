//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "../../lib/forge-std/src/Test.sol";
import {Raffle} from "../../src/Raffle.sol";
import {DeployRaffle} from "../../script/raffleScript.s.sol";
import {helperConfig} from "../../script/helperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

contract testRaffle is Test {
    DeployRaffle deployRaffle;
    Raffle raffleInstance;
    helperConfig helper;
    uint256 private constant SEND_VALUE_PASS = 2e10 wei; // same as in the helperConfig
    uint256 private constant SEND_VALUE_FAIL = 1e9 wei;
    address private immutable USER = makeAddr("user");
    uint256 private returned_Id;


    modifier mockVrfCoordinator() {
        if(helper.getConfig().chainId == 31337) {
            vm.startPrank(address(helper));
            helper.vrfCoordinatorMock().addConsumer(helper.getConfig().subId, address(raffleInstance));
            vm.stopPrank();
        }
        _;
    }
    function setUp() external {
        deployRaffle = new DeployRaffle();
        (raffleInstance, helper) = deployRaffle.deployRaffle();
    }

    function testInitialRaffleState() public {
        assert(raffleInstance.getRaffleState() == Raffle.RaffleState.OPEN);
    }

    function testEnterRafflePass() public {
        vm.deal(USER, SEND_VALUE_PASS);
        vm.prank(USER);
        raffleInstance.enterRaffle{value: USER.balance}();
        assertEq(USER, raffleInstance.returnRafflePlayerAdress(0));
    }

    function testEnterRaffleFail() public {
        vm.expectRevert();
        vm.deal(USER, SEND_VALUE_FAIL);
        vm.prank(USER);
        raffleInstance.enterRaffle{value: USER.balance}();
    }

    function testEnterRaffleEmit() public {
        vm.deal(USER, SEND_VALUE_PASS);
        vm.prank(USER);
        vm.expectEmit(true, false, false, false, address(raffleInstance));
        emit Raffle.RaffleEnter(USER);
        // event are called like so ContractName.EventName, you cant just call a event by its name and expect it to work
        // only if the contract is inherited, then this can work fine
        raffleInstance.enterRaffle{value: SEND_VALUE_PASS}();
    }

    function testDontAllowPlayersToEnterWhenRaffleIsCalculating() public mockVrfCoordinator(){
        console.log(msg.sender);
        console.log(USER);
        console.log(address(this));
        console.log(address(raffleInstance));
        vm.deal(USER, SEND_VALUE_PASS*2);
        vm.startPrank(address(helper));
        helper.vrfCoordinatorMock().addConsumer(helper.getConfig().subId, address(raffleInstance));
        vm.stopPrank();

        vm.prank(USER);
        raffleInstance.enterRaffle{value: SEND_VALUE_PASS}();
        vm.prank(USER);
        vm.warp(block.timestamp + 31 seconds); // here, we set the current time so that it passed 31 seconds, and in that way we can check if our contract works or not
        // i passed interval to be 30 seconds, so 31 needs to pass for this to work


        raffleInstance.performUpkeep(""); // this is the function that will change the state of the raffle to calculating
        // so after 31 seconds, we can perform this function, and after that, we will enter the raffle again, and it should not work, since raffle is not open at that time
        // and then we are trying to enter the raffle again, but it should revert
        vm.expectRevert(Raffle.enterRaffle_PickingWinnerInProgress.selector);
        vm.prank(USER);
        raffleInstance.enterRaffle{value: SEND_VALUE_PASS}();
    }
    /*
    function testOwnerRevert() public{ // when normal user is calling the funciton
    vm.expectRevert();
    raffleInstance.performUpkeep();
    }
     
    function testOwnerSucceed() public{
    hoax(msg.sender, 0.1 ether);
    returned_Id=raffleInstance.performUpkeep(); //  this needed to be done to put it in the line of code below
    vrfCoordinatorMock.getMock().fulfillRandomWords(returned_Id , address(raffleInstance)); 
    // in the Raffle.sol, we have the same function that is given some functionality, but with this call, we are setting the id and the instance to be mock, and in that way we are actually
    // calling the one that is in the Raffle.sol
    }
    */
}
