// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import { Script } from "forge-std/Script.sol";
import { ChainSphere } from "../src/ChainSphere.sol";
import { HelperConfig} from "./HelperConfig.s.sol";
import { CreateSubscription, FundSubscription, AddConsumer } from "./Interactions.s.sol";

contract DeployChainSphere is Script {
    function run() external returns(ChainSphere, HelperConfig){
        HelperConfig helperConfig = new HelperConfig();
        // Destructuring our struct
        (
            address priceFeed, 
            uint256 interval,
            address vrfCoordinator,
            bytes32 gasLane,
            uint256 subscriptionId,
            uint32 callbackGasLimit,
            address link,
            uint256 deployerKey,
            uint256 minimumUsd
        ) = helperConfig.activeNetworkConfig();

        if(subscriptionId == 0){
            CreateSubscription createSubscription = new CreateSubscription();
            subscriptionId = createSubscription.createSubscription(
                vrfCoordinator, deployerKey
            );

            FundSubscription fundSubscription = new FundSubscription();
            fundSubscription.fundSubscription(
                vrfCoordinator, subscriptionId, link, deployerKey
            );
        }
        
        vm.startBroadcast();
        ChainSphere chainSphere = new ChainSphere(
            priceFeed, 
            interval,
            vrfCoordinator,
            gasLane,
            subscriptionId,
            callbackGasLimit,
            minimumUsd
        );
        vm.stopBroadcast();

        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer(
            address(chainSphere), vrfCoordinator, subscriptionId, deployerKey
        );

        return (chainSphere, helperConfig);
    }
}