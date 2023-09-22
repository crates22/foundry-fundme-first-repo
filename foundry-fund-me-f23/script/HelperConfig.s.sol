//SPDX-License-Identifier: MIT

// This contract will:
//1. Deploy Mocks when on a local anvil chain
//2. Keep track of contract addresses across different chains
//for example, Sepolia ETH/USD, Mainnet ETH/USD, etc.abi

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    //If we are on a local anvil, we deploy Mocks
    //Otherwise, grab the existing address from the live network

    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_ANSWER = 200000000000;

    struct NetworkConfig { // if we want to get specific info from different networks this struct is going to hold all the information we need  
        address priceFeed; //ETH/USD prce feed address is the only info we need for this exercise
    }

    constructor(){
        if (block.chainid == 11155111){//block.chainid is one of Solidity's global variables that returns the chain id of the current chain; this if statement is saying that if the chain id is 11155111 (which is the chain id for Sepolia) then we want to run the getSepoliaEthConfig function; if not run on anvil
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1){
            activeNetworkConfig = getMainnetEthConfig();
        } else{
            activeNetworkConfig = getOrCreateAnvilEthConfig();}
    
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory){ //this function is going to return configuration for everything we want out of ETH Sepolia (or any chain) specified in the struct above
        //price feed address
        NetworkConfig memory sepoliaConfig = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaConfig;

    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory){ //this function is going to return configuration for everything we want out of ETH Sepolia (or any chain) specified in the struct above
        //price feed address
        NetworkConfig memory mainnetConfig = NetworkConfig({priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
        return mainnetConfig;
    
    
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory){ //since Anvil doesn't have any price feed contracts we have to create them ourselves
        if (activeNetworkConfig.priceFeed != address(0)){//address(0) refers to the first address that contains the price feed on Anvil; (we don't want to keep creating price feed addresses everytime we test)
            return activeNetworkConfig;
        }
        //1. Depoloy the mocks (mocks are dummy contracts)
        //2. Return the address of the mock
        
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_ANSWER);//this line of code is saying that we are deploying a new MockV3Aggregator contract with 8 decimals and 1000000000000000000000 as the initial answer (see the constructos in the MockV3Aggregator contract)
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({priceFeed: address(mockPriceFeed)});//this line of code is saying that the priceFeed address is equal to the address of the mockPriceFeed contract

        return anvilConfig;
    }
}