//here we will create a scipt that will help us interact with the functions of FundMe
//Fund
//Wihdraw
//in order to keep track of the most recently deployed FundMe contract we need to install the foundry-dev-ops package from Github; we do that by typing "forge install ChainAccelOrg/foundry-devops --no-commit" into the terminal  
//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script { 
    uint256 constant SEND_VALUE = 0.01 ether;

    function fundFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();//vm.startBroadcast is used to 
        FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();
        console.log("Funded FundMe with %s", SEND_VALUE);
        vm.stopBroadcast();
    }


    function run() external { //the run function is callinf the fundFundMe function (which in turn is calling the latest FundMe contract)
       
        address mostRecentlyDeployedFundMe = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);//this looks into the 'broadcast' folder based on the chainid and picks the most recently deployed contract in that file
        fundFundMe(mostRecentlyDeployedFundMe);//this is going to call our fundFundMe function and pass in the mostRecentlyDeployedFundMe address
        
    } 
}

contract WithdrawFundMe is Script {
    uint256 constant SEND_VALUE = 0.01 ether;

     function withdrawFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).withdraw();
        console.log("Withdraw FundMe with %s", SEND_VALUE);
        vm.stopBroadcast();
    }


    function run() external { //the run function is callinf the fundFundMe function (which in turn is calling the latest FundMe contract)
        
        address mostRecentlyDeployedFundMe = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);//this looks into the 'broadcast' folder based on the chainid and picks the most recently deployed contract in that file
        withdrawFundMe(mostRecentlyDeployedFundMe);//this is going to call our fundFundMe function and pass in the mostRecentlyDeployedFundMe address
    
    } 


}