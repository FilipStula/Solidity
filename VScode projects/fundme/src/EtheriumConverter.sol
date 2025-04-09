// SPDC-licenase-Identifier: MIT
pragma solidity ^0.8.24;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library etheriumConverter {
    AggregatorV3Interface constant dataFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    function getConverted() public view returns (int256) {
        // prettier-ignore
        (
            /* uint80 roundId */
            ,
            int256 answer,
            /*uint256 startedAt*/
            ,
            /*uint256 updatedAt*/
            ,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return answer * 1e10;
    }

    function getUsd(uint256 number) public view returns (uint256) {
        require(getConverted() > 0, "eth is negative");
        uint256 convertedValue = uint256(getConverted());
        return (number * convertedValue) / 1e18;
    }
}
