// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {

    // All functions in a library should be internal

    // Create a function that gets the price of the token
    function getPrice(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        // Get the Address and ABI of the Contract the stores the price of ETH
        // on ChainLink website. From Sepolia TestNet we have
        // Address 0x694AA1769357215DE4FAC081bf1f309aDC325306 
        // ABI 
        // AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        // The 'latestRoundData' method returns five values. 
        // However, we are only interested in 'price'
        (, int256 price, , , ) = priceFeed.latestRoundData();
        // price of ETH in terms of USD
        // We employ a technique call type-casting to change a variable type
        // from int256 to uint256
        return uint256(price * 1e10);
    }

    // Create a function that converts the 'msg.value' base on the price
    function getConversionRate(uint ethAmount, AggregatorV3Interface priceFeed) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed);
        uint256 ethAmountInUsd = (ethAmount * ethPrice)/ 1e18;
        return ethAmountInUsd;

    }

    
}