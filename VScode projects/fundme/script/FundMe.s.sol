//SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract deployFundMe is Script{
    function run() external returns(FundMe){

        HelperConfig helperConfig = new HelperConfig(); // creating a new instance of the HelperConfig contract
        (address networkAddress) = helperConfig.activeNetworkConfig(); 
        
        vm.startBroadcast(); //to start deploying
        FundMe newProject = new FundMe(networkAddress); // creating a new contract, and give the address of the chain we are on
        // passing of netwrokAddress here is telling the program to convert the vallues of the specified chain 
        // in EtheriumConverter, there will be passed the address which converts ether to USD
        vm.stopBroadcast(); // to finish deploying
        return newProject; //  to return the newly created contract
    }
}
