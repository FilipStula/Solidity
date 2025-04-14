// SPDC-licenase-Identifier: MIT
pragma solidity ^0.8.24;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library etheriumConverter {

    function getConverted(address _dataFeed) public view returns (int256) {
        AggregatorV3Interface dataFeed = AggregatorV3Interface(_dataFeed);
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

    function getUsd(uint256 number, address dataFeed) public view returns (uint256) {
        require(getConverted(dataFeed) > 0, "eth is negative");
        uint256 convertedValue = uint256(getConverted(dataFeed));
        return (number * convertedValue) / 1e18;
    }
}
