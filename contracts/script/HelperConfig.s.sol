// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import { Script } from "forge-std/Script.sol";
import { MockV3Aggregator } from "../test/mocks/MockV3Aggregator.sol";
import { VRFCoordinatorV2Mock } from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import { LinkToken } from "../test/mocks/LinkToken.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        address priceFeed;
        uint256 interval;
        address vrfCoordinator;
        bytes32 gasLane;
        uint256 subscriptionId;
        uint32 callbackGasLimit;
        address link;
        uint256 deployerKey;
        uint256 minimumUsd;
    }

    // If we are on local anvil, deploy mocks otherwise
    // grab the existing address from the live network

    // lets take care of our magic constants
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    uint256 public constant DEFAULT_ANVIL_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    // set the variable that holds configuration for the 
    // active network
    NetworkConfig public activeNetworkConfig;

    constructor(){
        if(block.chainid == 11155111){
            activeNetworkConfig = getSepoliaEthConfig();
        } else if(block.chainid == 80002){
            activeNetworkConfig = getPolygonAmoyConfig();
        } else{
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public view returns(NetworkConfig memory){
        return NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306, 
            interval: 30,
            vrfCoordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,//from Chainlink
            gasLane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae, // the key hash from Chainlink
            subscriptionId: 40757340564120712736435854386380613541348256225674614166681054503045638503207,
            callbackGasLimit: 2_500_000, // 2,500,000 gas!
            link: 0x779877A7B0D9E8603169DdbD7836e478b4624789,
            deployerKey: vm.envUint("PRIVATE_KEY"),
            minimumUsd: 5e18
        });
    }

    function getPolygonAmoyConfig() public view returns(NetworkConfig memory){
        return NetworkConfig({
            priceFeed: 0x001382149eBa3441043c1c66972b4772963f5D43, // MATIC/USD 0xF0d50568e3A7e8259E16663972b11910F89BD8e7, // ETH/USD
            interval: 30,
            vrfCoordinator: 0x343300b5d84D444B2ADc9116FEF1bED02BE49Cf2,//from Chainlink 0x343300b5d84D444B2ADc9116FEF1bED02BE49Cf2
            gasLane: 0x816bedba8a50b294e5cbd47842baf240c2385f2eaf719edbd4f250a137a8c899, // the key hash from Chainlink
            subscriptionId: 6963410906148681671330769598823940006759907003658603586642213936043556887061,
            callbackGasLimit: 2_500_000, // 2,500,000 gas!
            link: 0x0Fd9e8d3aF1aaee056EB9e802c3A762a667b1904, // 0x0fd9e8d3af1aaee056eb9e802c3a762a667b1904
            deployerKey: vm.envUint("PRIVATE_KEY"),
            minimumUsd: 5e16
        });
    }

    function getOrCreateAnvilEthConfig() public returns(NetworkConfig memory){
        // we should only create the activeNetworkConfig once
        if(activeNetworkConfig.vrfCoordinator != address(0)){
            return activeNetworkConfig;
        }


        // 1. Deploy the mocks
        // 2. return the mock contract address

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS, INITIAL_PRICE
        );
        vm.stopBroadcast();

        uint96 baseFee = 0.25 ether; // i.e. 0.25 LINK
        uint96 gasPriceLink = 1e9;
        LinkToken link = new LinkToken();

        vm.startBroadcast();
        VRFCoordinatorV2Mock vrfCoordinatorMock = new VRFCoordinatorV2Mock(
            baseFee, gasPriceLink
        );
        vm.stopBroadcast();

        return NetworkConfig({
            priceFeed: address(mockPriceFeed), 
            interval: 30,
            vrfCoordinator: address(vrfCoordinatorMock),//from the mock
            gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c, // the key hash from Chainlink
            subscriptionId: 0,
            callbackGasLimit: 500_000, // 500,000 gas!
            link: address(link),
            deployerKey: DEFAULT_ANVIL_KEY,
            minimumUsd: 5e18
        });
    }
}


// 0x0fd9e8d3af1aaee056eb9e802c3a762a667b1904
// 0x0Fd9e8d3aF1aaee056EB9e802c3A762a667b1904
// 0x343300b5d84D444B2ADc9116FEF1bED02BE49Cf2