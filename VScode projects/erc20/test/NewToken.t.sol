//SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test} from "lib/forge-std/src/Test.sol";
import {NewToken} from "../src/NewToken.sol";
import {tokenScript} from "../script/tokenScript.s.sol";

contract newTokenTests is Test{
    
    uint256 public constant STARTING_SUPPLY = 100 ether;
    uint256 public constant MINT_TOKENS = 50 ether;

    NewToken public token;
    tokenScript public script;

    address private user1 = makeAddr("user1");
    address private user2 = makeAddr("user2");


    function setUp() public {
        token = new NewToken(STARTING_SUPPLY);
        script = new tokenScript();
        script.run();
    }

    function testTransferTokens() public {

        token.transfer(user1, STARTING_SUPPLY);
        assertEq(token.balanceOf(user1), STARTING_SUPPLY);

    }


    function testMintTokensSuccess() public{
        token.mintTokens(MINT_TOKENS);
        assertEq(token.balanceOf(address(this)), STARTING_SUPPLY + MINT_TOKENS);
    }

    

}