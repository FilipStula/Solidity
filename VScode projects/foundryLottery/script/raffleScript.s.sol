//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "../lib/forge-std/src/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {helperConfig} from "./helperConfig.s.sol";

contract DeployRaffle is Script {
    Raffle public raffleInstance;

    function deployRaffle() external returns (Raffle, helperConfig) {
        vm.startBroadcast();
        helperConfig helper = new helperConfig();
        raffleInstance = new Raffle(
            helper.getConfig().enteranceFee,
            helper.getConfig().interval,
            helper.getConfig().vrfCoordinator,
            helper.getConfig().subId,
            helper.getConfig().keyHash,
            helper.getConfig().callbackGasLimit
        );

        vm.stopBroadcast();
        return (raffleInstance, helper);
    }
    // this will create the raffle
}
