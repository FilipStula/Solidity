// get funds from users
// withdraw funds 
// set a minimal value user has to paid for the contract in USD

// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.0;


import "./conversion.sol";


contract FundMe{
    
    using conversion for uint256;
    uint256 constant numberUSD = 5e18;

    address immutable i_owner;

    address[] funders;
    mapping (address => uint256) public fundersWithAmount;


    // Errors 
    error OwnerOnly(); // this is a more gas efficient way of throwing error, because there will not be a string that will be stored inside memory when this is called
    constructor(){
        i_owner = msg.sender;
    }

    function fund() public payable{ // using payable keyword, we make this function able to receive eth

        require(msg.value.getConversionRate() > numberUSD, "didn't send enough USD"); // 1e18 is equal to 1 * 10 ** 18, where ** is equal to power
        // this line says that the minimum value user need to pay for this function to be executed is 10 to the power of 18 WEI
        // which is 1 ETH
        // msg.value is the amount of WEI used for this function to be called
        // the string after the check is the message that the user will get it the enough amount of value isnt deposited
        // it will be REVERTED

        // when a function is reverted, then everything before require, wil not be executed, if in this case, user hasnt deposited the amount of ETH required
        // when the function is reverted, it gives back the amount of gas spent on the function

        funders.push(msg.sender);
        fundersWithAmount[msg.sender]=fundersWithAmount[msg.sender]+msg.value;
    }

    //0x694AA1769357215DE4FAC081bf1f309aDC325306 address for ETH/USD

    function withdraw() public payable OnlyOwner{
        for(uint256 i = 0; i < funders.length; i++)
        {
            address currentAddress = funders[i];
            fundersWithAmount[currentAddress]=0;
        }
        funders = new address[](0);
        // the code above is setting every address to 0, so then we dont have any funders for our contract, because we will be withdrawing money from the contract



         // Different ways to transfer ETH to addressese
    // First step is to make the address payable, after that line, the address is able to send/receive ETH
    // transfer, send, call
    // https://www.cyfrin.io/glossary/sending-ether-transfer-send-call-solidity-code-example
    //transfer
    //payable(msg.sender).transfer(address(this).balance); // if wasnt successful, thows error
    // send
    //require(payable(msg.sender).send(address(this).balance), "unable to send ETH"); // if wasnt successful, becomes false, and then this will revert
    // call
    (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
    require(callSuccess, "unable to send ETH");


    }

    modifier OnlyOwner(){
        //require(msg.sender == i_owner, OwnerOnly());
        if(msg.sender != i_owner){revert OwnerOnly();} // more gas efficient method than using require
        _;
    }


    // RECEIVE AND FALLBACK
    // In this example, i created fund() function that is ment to let the user be able to deposit ETH to my contract
    // In case user doesnt know how to fund, or wants to send ETH to the contract address, fund() function wont be called
    // We need to make sure that fund() is called
    // receive() and fallback() are the ones that make this happends
    // receive() is the function that is called whenever there is some type of deposit going through in the contract, with empty CALLDATA
    // On the other hand, fallback() is similar to receive(), the difference being that fallback() is called if there is something inside calldata
    // If there is no receive(), but fallback() exists, then fallback will be executed, which is not true for the other way around
    // If there is no fallback function, calls with populated calldata will throw an error, and wont be executed

    receive() external payable {
        fund();
     }

    fallback() external payable { 
        fund();
    }

}