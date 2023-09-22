//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";


contract DeployFundMe is Script{
    function run() external returns (FundMe){ //this line of code is saying that the run function will return a FundMe contract
        //Befopre startBroadcast -> Not a "real" tx
        HelperConfig helperConfig = new HelperConfig();//this line of code is establishing a new HelperConfig contract
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();//this line of code is saying that the ethUsdPriceFeed variable is equal to the activeNetworkConfig function from the HelperConfig contract
        
        //After startBroadcast -> "real" tx
        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethUsdPriceFeed);//this line of code is establishing a new FundMe contract with the desired priceFeed address
        vm.stopBroadcast();
        return fundMe;
       

    }

}