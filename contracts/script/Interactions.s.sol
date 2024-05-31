// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import { Script, console } from "forge-std/Script.sol";
import { HelperConfig } from "./HelperConfig.s.sol";
import { VRFCoordinatorV2Mock } from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import { LinkToken } from "../test/mocks/LinkToken.sol";
import { DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

contract CreateSubscription is Script{

    function createSubscriptionUsingConfig() public returns (uint256){
        HelperConfig helperConfig = new HelperConfig();
        ( , , address vrfCoordinator, , , , ,uint256 deployerKey, ) = helperConfig.activeNetworkConfig();
        return createSubscription(vrfCoordinator, deployerKey);
    }

    function createSubscription(
        address vrfCoordinator, uint256 deployerKey
    ) public returns (uint256) {
        console.log("Creating subscription on chain ID: ", block.chainid);
        vm.startBroadcast(deployerKey);
        uint256 subId = VRFCoordinatorV2Mock(vrfCoordinator).createSubscription();
        vm.stopBroadcast();
        console.log("Your sub Id is: ", subId);
        console.log("Please update subscription Id in HelperConfig.s.sol");
        return subId;
    }

    function run() external returns (uint256){
        return createSubscriptionUsingConfig();
    }
}

contract FundSubscription is Script{
    uint96 public constant FUND_AMOUNT = 3 ether;

    function fundSubscriptionUsingConfig() public{
        HelperConfig helperConfig = new HelperConfig();
        (
             , 
             , 
             address vrfCoordinator, 
             , 
             uint256 subId, 
             ,
             address link,
             uint256 deployerKey,

        ) = helperConfig.activeNetworkConfig();

        fundSubscription(vrfCoordinator, subId, link, deployerKey);
    }

    function fundSubscription(
        address vrfCoordinator, 
        uint256 subId, 
        address link,
        uint256 deployerKey
    ) public {
        console.log("Funding Subscription: ", subId);
        console.log("Using vrfCoordinator: ", vrfCoordinator);
        console.log("On ChainID: ", block.chainid);
        if(block.chainid == 31337){
            vm.startBroadcast(deployerKey);
            VRFCoordinatorV2Mock(vrfCoordinator).fundSubscription(
                subId, FUND_AMOUNT
            );
            vm.stopBroadcast();
        } else if(block.chainid == 80002){
            vm.startBroadcast(deployerKey);
            VRFCoordinatorV2Mock(vrfCoordinator).fundSubscription(
                subId, FUND_AMOUNT
            );
            vm.stopBroadcast();
        } else{
            vm.startBroadcast(deployerKey);
            LinkToken(link).transferAndCall(
                vrfCoordinator, FUND_AMOUNT, abi.encode(subId)
            );
            vm.stopBroadcast();
        }
    }

    function run() external{
        fundSubscriptionUsingConfig();
    }
}

contract AddConsumer is Script {
    function addConsumer(
        address chainSphere, 
        address vrfCoordinator, 
        uint256 subId, 
        uint256 deployerKey
    ) public {
        console.log("Adding Consumer: ", chainSphere);
        console.log("Using vrfCoordinator: ", vrfCoordinator);
        console.log("On ChainID: ", block.chainid);
        vm.startBroadcast(deployerKey);
        VRFCoordinatorV2Mock(vrfCoordinator).addConsumer(subId, chainSphere);
        vm.stopBroadcast();
    }

    function addConsumerUsingConfig(address chainSphere) public {
        HelperConfig helperConfig = new HelperConfig();
        (
             , 
             , 
             address vrfCoordinator, 
             , 
             uint256 subId, 
             ,
             ,
             uint256 deployerKey,

        ) = helperConfig.activeNetworkConfig();
        addConsumer(chainSphere, vrfCoordinator, subId, deployerKey);
    }

    function run() external{
        address chainSphere = DevOpsTools.get_most_recent_deployment(
            "ChainSphere", block.chainid
        );
        addConsumerUsingConfig(chainSphere);
    }
} 