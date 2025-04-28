// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {Script} from "../lib/forge-std/src/Script.sol";

contract helperConfig is Script{
    struct NetworkConfig {
        uint256 enteranceFee;
        uint256 interval;
        address vrfCoordinator;
        bytes32 keyHash;
        uint256 subId;
        uint32 callbackGasLimit;
        uint256 chainId;
    }

    uint256 public constant ENTERANCE_FEE = 1e10 wei;
    uint256 public constant SEPOLIA_CHAIN_ID = 11155111;
    uint256 public constant LOCAL_CHAIN_ID = 31337;
    NetworkConfig public config;
    VRFCoordinatorV2_5Mock public vrfCoordinatorMock;
    uint256 public i_mock_subId;

    constructor() {
        if (block.chainid == 11155111) {
            // Sepolia
            config = getSepoliaConfig();
        } else {
            // Localhost
            config = getOrCreateMockConfig();
        }
    }

    function getSepoliaConfig() public returns (NetworkConfig memory) {
        return NetworkConfig({
            enteranceFee: ENTERANCE_FEE,
            interval: 30 seconds,
            vrfCoordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
            keyHash: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            subId: 0,
            callbackGasLimit: 500000,
            chainId: SEPOLIA_CHAIN_ID
        });
    }

    function getOrCreateMockConfig() public returns (NetworkConfig memory) {
        vrfCoordinatorMock = new VRFCoordinatorV2_5Mock(0.001 ether, 1e9, 1e17); //creates a VRF mock instance
        // the values that are here need to be like this, othervise it wont work
        i_mock_subId = vrfCoordinatorMock.createSubscription();
        vrfCoordinatorMock.fundSubscription(i_mock_subId, 10000 ether); // funding the newly created subscription

        return NetworkConfig({
            enteranceFee: ENTERANCE_FEE,
            interval: 30 seconds,
            vrfCoordinator: address(vrfCoordinatorMock),
            keyHash: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            subId: i_mock_subId,
            callbackGasLimit: 500000,
            chainId: LOCAL_CHAIN_ID
        });
    }

    function getConfig() public view returns (NetworkConfig memory) {
        return config;
    }
}
