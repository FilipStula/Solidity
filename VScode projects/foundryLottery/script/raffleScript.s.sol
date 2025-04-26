//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {Script} from "../lib/forge-std/src/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {VrfMock} from "../test/mocks/vrfMock.sol";

contract DeployRaffle is Script {
    uint256 constant RAFFLE_ENTERANCE_FEE = 1000000 wei;
    uint256 constant INTERVAL = 1;
    address constant SEPOLIA_VRF_COORDINATOR = 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B;
    bytes32 constant MOCK_KEYHASH =0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae; 
    Raffle raffleInstance;
    VrfMock private vrfMock;
    function run(uint256 subId, address vrfCoordinator) external returns (Raffle) {
        vm.startBroadcast();
        raffleInstance = new Raffle(RAFFLE_ENTERANCE_FEE, INTERVAL, vrfCoordinator, subId, MOCK_KEYHASH);
        vm.stopBroadcast();
        return raffleInstance;
    }
    // this will create the raffle

    function getSubId() external view returns (uint256) {
        return vrfMock.getSubId();
    }
}