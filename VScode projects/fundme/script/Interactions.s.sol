//SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script{

    uint256 constant private SEND_USD = 0.1 ether;
    function fundFundMe(address latestDeployedContract) public {
        FundMe fundMe = FundMe(payable(latestDeployedContract));
        fundMe.deposit{value: SEND_USD}();
        console.log("Contract funded by %s wei", SEND_USD);
    }   

    function run() external{
        address latestDeployedContract = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        vm.startBroadcast();
        FundFundMe(latestDeployedContract);
        vm.stopBroadcast();

    }
}

contract WithdrawFundMe is Script{
    
    function withdrawFundMe(address latestDeployedContract) public {
        FundMe fundMe = FundMe(payable(latestDeployedContract));
        vm.startBroadcast();
        fundMe.withdraw();
        vm.stopBroadcast();
        console.log("Contract withdrawn");
    }

    function run() external{
        address latestDeployedContract = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        vm.startBroadcast();
        FundFundMe(latestDeployedContract);
        vm.stopBroadcast();

    }
}