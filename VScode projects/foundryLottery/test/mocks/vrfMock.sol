//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19; 

import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

contract VrfMock{
    VRFCoordinatorV2_5Mock vrfCoordinatorMock;
    uint256 private immutable i_mock_subId;
    constructor() {
        vrfCoordinatorMock= new VRFCoordinatorV2_5Mock(0.001 ether, 1e9,  1e17); //creates a VRF mock instance
        // the values that are here need to be like this, othervise it wont work
        i_mock_subId=vrfCoordinatorMock.createSubscription();
        vrfCoordinatorMock.fundSubscription(i_mock_subId, 10000 ether); // funding the newly created subscription
    }

    function getSubId() external view returns (uint256){
        return i_mock_subId; // getting the subscription id
    }

    function getMock() external view returns (VRFCoordinatorV2_5Mock){
        return vrfCoordinatorMock; // returning the address of the mock instance
    }
}