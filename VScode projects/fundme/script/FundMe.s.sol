//SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";

contract deployFundMe is Script{
    function run() external returns(FundMe){
        vm.startBroadcast(); //to start deploying
        FundMe newProject = new FundMe(); // creating a new contract
        vm.stopBroadcast(); // to finish deploying
        return newProject; //  to return the newly created contract
    }
}
