//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {Raffle} from "../src/Raffle.sol";
import {DeployRaffle} from "../script/raffleScript.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {DeployRaffle} from "../script/raffleScript.s.sol";
import {VrfMock} from "./mocks/vrfMock.sol";


contract testRaffle is Test{

    DeployRaffle deployRaffle;
    Raffle raffleInstance;
    VrfMock vrfCoordinatorMock;
    uint256 private constant SEND_VALUE = 1000000 wei; // same as in the deployRaffle
    address private immutable USER = makeAddr("user");
    uint256 private returned_Id;

     
   function setUp() external{
        vrfCoordinatorMock = new VrfMock();
        deployRaffle = new DeployRaffle();
        raffleInstance = deployRaffle.run(vrfCoordinatorMock.getSubId(), address(vrfCoordinatorMock.getMock()));
        vm.startPrank(address(vrfCoordinatorMock)); // i needed to start a prank here, not just call one instance of prank, since i am calling multiple funcitons in the line below
        vrfCoordinatorMock.getMock().addConsumer(vrfCoordinatorMock.getSubId(), address(raffleInstance));
        vm.stopPrank();
        vm.deal(USER, SEND_VALUE);
   } 

   // this test setUp is made exclusively for the mock contract,

   function testEnterRaffle() public{
    vm.prank(USER);
    raffleInstance.enterRaffle{value: USER.balance }();
    assertEq(USER, raffleInstance.returnRafflePlayerAdress(0));  
   }

   function testOwnerRevert() public{ // when normal user is calling the funciton
    vm.expectRevert();
    raffleInstance.pickWinner();
   }

   function testOwnerSucceed() public{
    hoax(msg.sender, 0.1 ether);
    returned_Id=raffleInstance.pickWinner(); //  this needed to be done to put it in the line of code below
    vrfCoordinatorMock.getMock().fulfillRandomWords(returned_Id , address(raffleInstance)); 
    // in the Raffle.sol, we have the same function that is given some functionality, but with this call, we are setting the id and the instance to be mock, and in that way we are actually
    // calling the one that is in the Raffle.sol
   }
}