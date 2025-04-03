// get funds from users
// withdraw funds 
// set a minimal value user has to paid for the contract in USD

// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.24;

contract FundMe{
    
    int256 public number;

    function fund() public payable{ // using payable keyword, we make this function able to receive eth

        number=1;
        require(msg.value > 1e18, "didn't send enough ETH"); // 1e18 is equal to 1 * 10 ** 18, where ** is equal to power
        // this line says that the minimum value user need to pay for this function to be executed is 10 to the power of 18 WEI
        // which is 1 ETH
        // msg.value is the amount of WEI used for this function to be called
        // the string after the check is the message that the user will get it the enough amount of value isnt deposited
        // it will be REVERTED

        // when a function is reveterd, then everything before require, wil not be executed, if in this case, user hasnt deposited the amount of ETH required
        // when the function is reverted, it gives back the amount of gas spent on the function
    }

    function withdraw() public {}
}