//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Vm} from "forge-std/Vm.sol";
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

    function setUp() external {
        deployRaffle = new DeployRaffle();
        (raffleInstance, helper) = deployRaffle.deployRaffle();
    }

    function testInitialRaffleState() public view {
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

    // vm.expectEmit(true, false, false, false, address(raffleInstance));
    // so after this, we need an emit like in the above
    // address(raffleInstance) is the address from which the emit is expected
    // we can have 3 indexed events, and in this expect revert i am saying that
    // the event that is being expected has ONLY 1 indexed valur
    // so true, false, false means that out of 3 indexed values, only 1 is expected
    // false and the end, before address(raffleInstance) means that there are no non-indexed values at all and are not expected in the emit

    function testCheckUpkeepNewPlayersCantEnter() public {
        console.log(msg.sender);
        console.log(USER);
        console.log(address(this));
        console.log(address(raffleInstance));
        vm.deal(USER, SEND_VALUE_PASS * 2);

        vm.prank(USER);
        raffleInstance.enterRaffle{value: SEND_VALUE_PASS}();
        vm.prank(USER);
        vm.warp(block.timestamp + 31 seconds); // here, we set the current time so that it passed 31 seconds, and in that way we can check if our contract works or not
        // i passed interval to be 30 seconds, so 31 needs to pass for this to work
        vm.roll(block.number + 1); // this is needed to make the block timestamp to be updated, so that it can be used in the upkeep function

        raffleInstance.performUpkeep(""); // this is the function that will change the state of the raffle to calculating
        // so after 31 seconds, we can perform this function, and after that, we will enter the raffle again, and it should not work, since raffle is not open at that time
        // and then we are trying to enter the raffle again, but it should revert
        vm.expectRevert(Raffle.enterRaffle_PickingWinnerInProgress.selector);
        vm.prank(USER);
        raffleInstance.enterRaffle{value: SEND_VALUE_PASS}();

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

    function testCheckUpkeepTimeRevert() public {
        vm.deal(USER, SEND_VALUE_PASS * 2);

        vm.prank(USER);
        raffleInstance.enterRaffle{value: SEND_VALUE_PASS}();
        vm.prank(USER);
        vm.warp(block.timestamp + 29 seconds); // time is set to 30, so not enough time has passed

        vm.roll(block.number + 1);

        (bool upkeepNeeded,) = raffleInstance.checkUpkeep(""); // this is the function that will change the state of the raffle to calculating
        console.log(upkeepNeeded);
        assertEq(upkeepNeeded, false);
    }

    function testCheckUpkeepNoPlayers() public {
        vm.warp(block.timestamp + 31 seconds); // time is set to 30, so not enough time has passed

        vm.roll(block.number + 1);

        (bool upkeepNeeded,) = raffleInstance.checkUpkeep(""); // this is the function that will change the state of the raffle to calculating
        console.log(upkeepNeeded);
        assertEq(upkeepNeeded, false);
    }

    function testPerformUpkeepCheckUpkeepPass() public {
        bytes memory test;
        vm.deal(USER, SEND_VALUE_PASS * 2);

        vm.prank(USER);
        raffleInstance.enterRaffle{value: SEND_VALUE_PASS}();
        vm.prank(USER);
        vm.warp(block.timestamp + 31 seconds); // time is set to 30, so not enough time has passed

        vm.roll(block.number + 1);

        raffleInstance.performUpkeep(test);
        assert(raffleInstance.getRaffleState() == Raffle.RaffleState.CALCULATING);
    }

    function testPerformUpkeepCheckUpkeepFail() public {
        bytes memory test;
        vm.deal(USER, SEND_VALUE_PASS * 2);

        vm.prank(USER);
        raffleInstance.enterRaffle{value: SEND_VALUE_PASS}();

        //vm.warp(block.timestamp + 31 seconds);
        //vm.roll(block.number + 1);
        // I will omit the time passing and then this wont work

        vm.expectRevert(abi.encodeWithSelector(Raffle.performUpkeep__AutomaticCallFailed.selector, 2e10, 0, 1, false));
        // we need to always tell EXPLICITLY what we want to be reverted, othervise this wont work
        // by that i mean i need to tell exactly what are the condifions that the revert will happend
        // or what the values will be when the test reverts
        raffleInstance.performUpkeep(test);
    }

    function testPerformUpkeepUpdatesRaffleStateAndEmitsRequestId() public {
        vm.deal(USER, SEND_VALUE_PASS);
        vm.prank(USER);

        raffleInstance.enterRaffle{value: SEND_VALUE_PASS}();
        vm.warp(block.timestamp + 31 seconds); // time is set to 30, enough time has passed
        vm.roll(block.number + 1);

        vm.recordLogs();
        raffleInstance.performUpkeep("");
        Vm.Log[] memory logs = vm.getRecordedLogs();
        console.log(logs[0].topics.length);
    }

    function testFullfillRandomWordsCanOnlyBeCalledAfterPerformUpkeep(uint256 randomSubId) public {
        address vrfCoordinator = helper.getConfig().vrfCoordinator;
        vm.deal(USER, SEND_VALUE_PASS + 5);
        vm.prank(USER);

        raffleInstance.enterRaffle{value: SEND_VALUE_PASS}();
        vm.warp(block.timestamp + 50);
        vm.roll(block.number + 1);

        // NOTE to self: NEVER DO FUNCTION CALLS INSIDE A FUNCTION, since then, the revert will try to get the first funciton call, and not the one i expect
        vm.expectRevert(VRFCoordinatorV2_5Mock.InvalidRequest.selector);
        VRFCoordinatorV2_5Mock(vrfCoordinator).fulfillRandomWords(randomSubId, address(raffleInstance));
    }

    function testFulfillRandomWordsPicksAWinnerAndResetsTheArray() public {
        address vrfCoordinator = helper.getConfig().vrfCoordinator;
        uint256 numberOfPlayers = 5;
        uint256 startingIndex = 1;

        for (startingIndex; startingIndex <= numberOfPlayers; startingIndex++) {
            address player = address(uint160(startingIndex));
            hoax(player, SEND_VALUE_PASS + 3);
            vm.expectEmit(true, false, false, false, address(raffleInstance));
            emit Raffle.RaffleEnter(player);
            raffleInstance.enterRaffle{value: SEND_VALUE_PASS}();
        }
        vm.warp(block.timestamp + 31 seconds); // set time to pass so i can call checkUpkeeps
        vm.roll(block.number + 1);

        raffleInstance.checkUpkeep("");
        vm.recordLogs();
        raffleInstance.performUpkeep("");
        Vm.Log[] memory logs = vm.getRecordedLogs();
        bytes32 requestId = logs[1].topics[1];

        VRFCoordinatorV2_5Mock(vrfCoordinator).fulfillRandomWords(uint256(requestId), address(raffleInstance));

        assert(raffleInstance.getRaffleState() == Raffle.RaffleState.OPEN);
    }

    // function testFulfillRandomWordsAlreadyPickingAWinner() public
    // {
    //     address vrfCoordinator = helper.getConfig().vrfCoordinator;
    //     vm.deal(USER, SEND_VALUE_PASS + 5);
    //     vm.prank(USER);
    //     raffleInstance.enterRaffle{value: SEND_VALUE_PASS}();

    //     vm.warp(block.timestamp + 31 seconds); // time is set to 30, enough time has passed
    //     vm.roll(block.number + 1);

    //     raffleInstance.checkUpkeep("");
    //     vm.recordLogs();
    //     raffleInstance.performUpkeep("");
    //     Vm.Log[] memory logs = vm.getRecordedLogs();
    //     bytes32 requestId = logs[1].topics[1];
    //     VRFCoordinatorV2_5Mock(vrfCoordinator).fulfillRandomWords(uint256(requestId), address(raffleInstance));

    //     vm.expectRevert(Raffle.fulfillRandomWords_ContractAlreadyPickingAWinner.selector);
        
    //     VRFCoordinatorV2_5Mock(vrfCoordinator).fulfillRandomWords(uint256(requestId), address(raffleInstance));

    // }
}
