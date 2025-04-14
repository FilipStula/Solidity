// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;


import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mock/MockV3Aggregator.sol"; // this is the mock contract that will be used to test the contract

contract HelperConfig is Script{ // this will be used like a middleeware for addresses of ETH/USD converters in different blockchains

    uint8 public constant DECIMALS = 8; // this is the number of decimals that will be used in the contract
    int256 public constant INITIAL_ANSWER = 2000e8; // this is the initial answer that will be used in the contract

    struct networkConfig{
        address dataFeed;
    }

    networkConfig public activeNetworkConfig;

    function getSepoliaEth() public pure returns(networkConfig memory){
        networkConfig memory sepoliaConfig = networkConfig({dataFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaConfig;
    }

    function getMainnetEth() public pure returns(networkConfig memory){
        networkConfig memory mainnetConfig = networkConfig({dataFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
        return mainnetConfig;
    }

    function getAnvilEth() public returns(networkConfig memory){
        if(activeNetworkConfig.dataFeed != address(0)){ // this means that the address is already set, and there is no need to set up a new one
            return activeNetworkConfig;
        }

        vm.startBroadcast();
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(DECIMALS, INITIAL_ANSWER);
        //
        vm.stopBroadcast();
        networkConfig memory anvilConfig = networkConfig({dataFeed: address(mockV3Aggregator)});
        return anvilConfig;
    } 

    constructor(){ 
        if(block.chainid == 11155111){ // block is a global variable that contains the chain id of the current network, and 11155111 is the chain id of sepolia
            activeNetworkConfig = getSepoliaEth();
        }
        else if(block.chainid == 1){ // 1 is the chain id of mainnet
            activeNetworkConfig = getMainnetEth();
        }else{
            activeNetworkConfig = getAnvilEth();
        }
        // we can add all the networks we want here, but the these do the job also
    }

}
