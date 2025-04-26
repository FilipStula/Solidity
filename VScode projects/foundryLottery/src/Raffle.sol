//Contract layout
/* Pragma statements
Import statements
Events
Errors
Interfaces
Libraries
Contracts
 
//Layout of funcitons
/* constructor
receive function (if exists)
fallback function (if exists)
external
public
internal
private */




//SPDX-Licence-Identifier: MIT
pragma solidity ^0.8.19; //using slightly older version because the majority of helper contract here are good on this specified version of solidity

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {IVRFMigratableConsumerV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/interfaces/IVRFMigratableConsumerV2Plus.sol";
import {IVRFCoordinatorV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/interfaces/IVRFCoordinatorV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {console} from "lib/forge-std/src/console.sol";
/**
    * @title Raffle
    * @author Filip Stula
    * @notice Simple raffle contract 
 */
 contract Raffle is VRFConsumerBaseV2Plus {

    // Errors
    error enterRaffle_NotEnoughEthSent(); // naming convection, always put the function in where the error will be used then the description of the error
    error pickWinner_NotEnoughTimePassed(); // this is the error that will be used in the pickWinner function
    error fulfillRandomWords_FundsNotTransfered(); // if the winner isnt paid
    error enterRaffle_PickingWinnerInProgress(); // if the raffle is not open, we cant enter

    /**Type declarations */
    enum RaffleState{
        OPEN, // 0
        CALCULATING // 1
        // every enum is basicallt an integer
    } // this is the state of the raffle, if it is open or calculating the winner



    /**Sate variables */
    address payable[] private s_players; // array of players, needed the payable, because, whoever wins, will get paid
    uint256 private s_players_length;
    address private s_owner;
    uint256 private s_timeStamp;
    uint256 private s_requestId; // request id for the Chainlink VRF
    address private[] winners; // list of winners
    uint256 immutable i_raffleEnteranceFee; //0.01 ether
    uint256 private immutable i_interval;
    /** Below are the arguments for the s_requestId and the pickWinner function**/
    bytes32 immutable i_keyHash;
    uint256 immutable i_subId;
    uint16 constant REQUEST_CONFIRMATIONS = 3; // how many blocks we want to wait before we get the random number
    uint32 constant CALLBACK_GAS_LIMIT = 1000000; // how much gas we want to use for the callback function
    uint32 constant NUM_WORDS = 1; // number of random words we want to get back
    RaffleState private s_raffleState; // state of the raffle, if it is open or calculating the winner


    // Events

    event RaffleEnter(address indexed player); // indexed means that we can filter the events in the logs, so we can find the event easier
    // indexed is used, when this transaction, 
    

    constructor(uint256 raffleEnteranceFee, uint256 interval, address vrfCoordinator, uint256 subId, bytes32 keyHash) VRFConsumerBaseV2Plus(vrfCoordinator){ // this whole contract is inheriting another contract that has its own contrsuctor
        // to add the constructor of that other contract, we need to write that in here an so we can assign values to both the other contrutor and this one
        // in this example, we passed vrfCoorrinator of thr constructor of Raffle ocntract, and passed it to the VRFCOnsumerBaseV2Plus constructor
        i_raffleEnteranceFee = raffleEnteranceFee;
        i_interval = interval;
        s_timeStamp = block.timestamp;
        i_keyHash = keyHash;
        i_subId = subId;
        s_owner = msg.sender;

        s_raffleState = RaffleState.OPEN; // set the state of the raffle to open
    }

    modifier OnlyOwner{
        if(msg.sender != s_owner){
            revert("Only owner can call this function");
        }
        _;
    }

    function enterRaffle() public payable{
        // require(msg.value => i_raffleEnteranceFee, "Not enough ether sent"); // not gas efficient because of storing the string
        // require(msg.value >= i_raffleEnteranceFee, NotEnoughEthSent()); // only available on newer verisons
        if(msg.value < i_raffleEnteranceFee){ // this is the best way
            revert enterRaffle_NotEnoughEthSent();
        }
        if(s_raffleState != RaffleState.OPEN){ // if the raffle is not open, we cant enter
            revert enterRaffle_PickingWinnerInProgress();
        }

        s_players.push(payable(msg.sender)); // add the player to the array
        emit RaffleEnter(msg.sender); // emit the event, the same address that was we pushed to the array
    }


    function pickWinner() external OnlyOwner() returns(uint256){
        /*if(block.timestamp - s_timeStamp < i_interval){
            revert pickWinner_NotEnoughTimePassed();
        }*/
        console.log("Inside pickWinner function");
        s_requestId = s_vrfCoordinator.requestRandomWords( //Requesting random words from Chainlink VRF
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: i_keyHash,
                subId: i_subId,
                requestConfirmations: REQUEST_CONFIRMATIONS,
                callbackGasLimit: CALLBACK_GAS_LIMIT,
                numWords: NUM_WORDS,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            })
        );

        return s_requestId;
    }

    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal pure override {
        s_raffleState = RaffleState.CALCULATING; // set the state of the raffle to calculating, in this case,, noone can enter the raffle
        console.log("Request ID: ", requestId);
        address winner = s_players[randomWords[0] % s_players.length]; // this is the address of the winner
        // mod here is working as in every other programming language
        winners.push(winner); // add the winner to the array
        (bool success, ) = winner.call{value: address(this).balance}(""); // send the balance of the contract to the winner
        if(!success){ // if the transaction fails, we need to revert
            revert fulfillRandomWords_FundsNotTransfered();
        }
        s_raffleState = RaffleState.OPEN; // after the winner is picked, we can open the raffle again
    }



    function getEnteranceFee() external view returns(uint256){ // gets the enterace fee of the lottery
        return i_raffleEnteranceFee;
    }

    function returnRafflePlayerAdress(uint256 number) public view returns (address){ // return the address of the player inside the raffle, number is the position in which the player is
        return s_players[number];
    }
}