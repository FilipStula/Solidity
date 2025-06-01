// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {Script, console} from "../lib/forge-std/src/Script.sol";
import {helperConfig} from "./helperConfig.s.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {Raffle} from "../src/Raffle.sol";

contract CreateSubscription is Script {
    function createSubscriptionUsingConfig() public returns (uint256, address) {
        helperConfig helper = new helperConfig();
        address vrfCoordinator = helper.getConfig().vrfCoordinator;

        uint256 subId = createSubscription(vrfCoordinator);

        return (subId, vrfCoordinator);
    }

    function createSubscription(address vrfCoordinator) public returns (uint256 subId) {
        console.log(msg.sender);
        console.log("Creating subscription...");
        vm.startBroadcast();
        subId = VRFCoordinatorV2_5Mock(vrfCoordinator).createSubscription();
        vm.stopBroadcast();
        console.log("Subscription created with ID:", subId);
        return subId;
    }

    function run() public {
        createSubscriptionUsingConfig();
    }
}

contract FundSubscription is Script {
    uint256 public constant FUND_AMOUNT = 3 * 1e18; // this will be 3 LINK when tokens are implemented

    function fundSubscriptionUsingConfig() public {
        helperConfig helper = new helperConfig();
        uint256 subId = helper.getConfig().subId;
        address vrfCoordinator = helper.getConfig().vrfCoordinator;
        address linkToken = helper.getConfig().link;

        fundSubscription(vrfCoordinator, subId, linkToken);
        vm.stopBroadcast();
    }

    function fundSubscription(address vrfCoordinator, uint256 subId, address linkToken) public {
        console.log("Funding subscription...", subId);
        console.log("Using VRF Coordinator:", vrfCoordinator);
        console.log("On chain", block.chainid);
        console.log("With link token:", linkToken);

        if (block.chainid == 31337) {
            console.log("Funding subscription with mock tokens...");
            vm.startBroadcast();
           VRFCoordinatorV2_5Mock(vrfCoordinator).fundSubscription(subId, FUND_AMOUNT); // just fund it with some fake ether, it doesnt matter that much
            vm.stopBroadcast();
        } else {
            console.log("Funding subscription with LINK...");
            vm.startBroadcast();
            LinkToken(linkToken).transferAndCall(vrfCoordinator, FUND_AMOUNT, abi.encode(subId));
            // this is needed to fund LIVE subscription with TOKENS, not ether
            vm.stopBroadcast();
        }
    }

    function run() public {
        fundSubscriptionUsingConfig();
    }
}

contract AddConsumer is Script {
    function addConsumerUsingConfig(address consumer) public {
        helperConfig helper = new helperConfig();
        uint256 subId = helper.getConfig().subId;
        address vrfCoordinator = helper.getConfig().vrfCoordinator;

        addConsumer(vrfCoordinator, subId, consumer);

    }

    function addConsumer(address vrfCoordinator, uint256 subId, address consumer) public {
        console.log(msg.sender);
        console.log("Adding consumer to subscription...", subId);
        console.log("Using VRF Coordinator:", vrfCoordinator);
        console.log("On chain", block.chainid);
        console.log("Consumer to be added:", consumer);

        if (block.chainid == 31337) {
            console.log("Adding consumer on local chain");
            vm.startBroadcast();
            VRFCoordinatorV2_5Mock(vrfCoordinator).addConsumer(subId, consumer);
            vm.stopBroadcast();
        } else {
            console.log("Adding consumer on SEPOLIA");
            vm.startBroadcast();
            VRFCoordinatorV2_5Mock(vrfCoordinator).addConsumer(subId, consumer);
            vm.stopBroadcast();
        }
    }

    function run() public {
        address raffleInstance = DevOpsTools.get_most_recent_deployment("Raffle", block.chainid);
        Raffle raffle = Raffle(raffleInstance);
        addConsumerUsingConfig(address(raffle));
    }
}
/*
 function createSubscription(address vrfCoordinator) public returns (uint256 subId) {
        subId = VRFCoordinatorV2_5Mock(vrfCoordinator).createSubscription();
        return subId;
    }
}

contract FundSubscription{
    function fundSubscription(address vrfCoordinator, uint256 subId) public {
        VRFCoordinatorV2_5Mock(vrfCoordinator).fundSubscription(subId, 1e18);
    }
    */
