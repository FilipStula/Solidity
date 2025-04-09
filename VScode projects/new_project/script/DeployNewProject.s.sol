//SPDX-license-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
// this is used to deploy the contract
import {NewProject} from "../src/newProject.sol";

contract DeployNewProject is Script {
    function run() external returns (NewProject) {
        vm.startBroadcast();
        NewProject newProject = new NewProject();
        vm.stopBroadcast();
        return newProject;
    }
}
