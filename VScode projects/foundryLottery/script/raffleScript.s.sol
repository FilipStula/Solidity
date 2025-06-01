//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "../lib/forge-std/src/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {helperConfig} from "./helperConfig.s.sol";
import {CreateSubscription, FundSubscription, AddConsumer} from "./Interactions.s.sol";

contract DeployRaffle is Script {
    Raffle public raffleInstance;
    function deployRaffle() public returns (Raffle, helperConfig) {
        helperConfig helper = new helperConfig();
        helperConfig.NetworkConfig memory config = helper.getConfig();

        if (config.subId == 0) {
            CreateSubscription createSub = new CreateSubscription();

            uint256 subId = createSub.createSubscription(config.vrfCoordinator);

            helper.setSubId(subId);

            FundSubscription fundSub = new FundSubscription();

            fundSub.fundSubscription(
                helper.getConfig().vrfCoordinator, helper.getConfig().subId, config.link
            );

        }
        raffleInstance = new Raffle(
            helper.getConfig().enteranceFee,
            helper.getConfig().interval,
            helper.getConfig().vrfCoordinator,
            helper.getConfig().subId,
            helper.getConfig().keyHash,
            helper.getConfig().callbackGasLimit
        );
        
        AddConsumer addConsumer = new AddConsumer();

        addConsumer.addConsumer(config.vrfCoordinator, helper.getConfig().subId, address(raffleInstance));


        return (raffleInstance, helper);
    }
    // this will create the raffle

    function run() external {
        deployRaffle();
    }
}
