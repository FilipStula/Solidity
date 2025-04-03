// get funds from users
// withdraw funds 
// set a minimal value user has to paid for the contract in USD

// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.0;


import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";


contract FundMe{
    
    uint256 numberUSD = 5e18;

    function fund() public payable{ // using payable keyword, we make this function able to receive eth

        require(getConversionRate(msg.value) > numberUSD, "didn't send enough USD"); // 1e18 is equal to 1 * 10 ** 18, where ** is equal to power
        // this line says that the minimum value user need to pay for this function to be executed is 10 to the power of 18 WEI
        // which is 1 ETH
        // msg.value is the amount of WEI used for this function to be called
        // the string after the check is the message that the user will get it the enough amount of value isnt deposited
        // it will be REVERTED

        // when a function is reveterd, then everything before require, wil not be executed, if in this case, user hasnt deposited the amount of ETH required
        // when the function is reverted, it gives back the amount of gas spent on the function
    }

    //0x694AA1769357215DE4FAC081bf1f309aDC325306 address for ETH/USD

    function withdraw() public {}

    function getPrice() public view returns(uint256){
        AggregatorV3Interface dataFeed;
        dataFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        (/* uint80 roundId */,int256 answer,/*uint256 startedAt*/,/*uint256 updatedAt*/,/*uint80 answeredInRound*/) = dataFeed.latestRoundData();
        // in the documentation the latestRoundData() is defined like this so this function return this many variables
        // we are only interested in answer, so every other variable is commented, but the commas remain
        // answer here will return the value with 8 decimal points, so because we are using WEI in msg.value, we need every value to be with 18 decimal points
        return uint256(answer*1e10); // this will make answer 18 decimal points
        // i needed to cast this to uint256, since msg.value return uint256, and i will be comparing the two
    }

    function getConversionRate(uint256 amount) public view returns(uint256) {
        uint256 ethPrice = getPrice();
        uint256 converted = (ethPrice * amount)/1e18;
        return converted;
        // explanation of this function:
        // firstly, i get the price of ETH in terms of USD
        // then converted value is actually getting the true value of USD, since the amount variable will be the user input
        // user input is in wei, ethPrice will be usd*1e18, so now, if the user sends one ETH, converted will be the same as ethPrice, so USDvalue*1e18
        // the reason i am using every digit, is because in solidity there is no floating point, only integers
    }
}