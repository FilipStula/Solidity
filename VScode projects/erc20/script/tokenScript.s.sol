//SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;


import {Script, console} from "lib/forge-std/src/Script.sol";
import {Vm} from "lib/forge-std/src/Vm.sol";
import {NewToken} from "../src/NewToken.sol";

contract tokenScript is Script{
    uint256 public constant INITIAL_SUPPLY = 100 ether;
    function deployToken() public{
       vm.startBroadcast();
       NewToken token = new NewToken(INITIAL_SUPPLY);
       
       vm.stopBroadcast();

    }

    function run() external{
        deployToken();
    }
}