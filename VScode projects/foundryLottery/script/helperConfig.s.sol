// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";

contract helperConfig {
    struct NetworkConfig {
        uint256 enteranceFee;
        uint256 interval;
        address vrfCoordinator;
        bytes32 keyHash;
        uint256 subId;
        uint32 callbackGasLimit;
        address link;
    }

    NetworkConfig public config;
    VRFCoordinatorV2_5Mock public vrfCoordinatorMock;
    address public constant SEPOLIA_VRF_COORDINATOR = 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B;
    address public constant SEPOLIA_LINK_TOKEN_FAUCET = 0x779877A7B0D9E8603169DdbD7836e478b4624789;
    bytes32 public constant VRF_KEYHASH = 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae;

    constructor() {
        config = block.chainid == 11155111 ? getSepoliaConfig() : getOrCreateMockConfig();
    }

    function getSepoliaConfig() private pure returns (NetworkConfig memory) {
        return NetworkConfig({
            enteranceFee: 1e10,
            interval: 30 seconds,
            vrfCoordinator: SEPOLIA_VRF_COORDINATOR,
            keyHash: VRF_KEYHASH,
            subId: 32008119771176468897711766039513295420481410895500955993081283012182731217213, // my subId which i created on chainlink, this really exists
            callbackGasLimit: 500000,
            link: SEPOLIA_LINK_TOKEN_FAUCET
        });
    }

    function getOrCreateMockConfig() private returns (NetworkConfig memory) {
        vrfCoordinatorMock = new VRFCoordinatorV2_5Mock(0.25 ether, 1e9, 4e15);

        LinkToken linkToken = new LinkToken(); // creating mock tokens to fund subscription with
        return NetworkConfig({
            enteranceFee: 1e10,
            interval: 30 seconds,
            vrfCoordinator: address(vrfCoordinatorMock),
            keyHash: VRF_KEYHASH,
            subId: 0,
            callbackGasLimit: 500000,
            link: address(linkToken)
        });
    }

    function getConfig() external view returns (NetworkConfig memory) {
        return config;
    }

    function setSubId(uint256 subId) external {
        config.subId = subId;
    }
}
