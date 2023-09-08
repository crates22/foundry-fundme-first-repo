//SPDX-License-Identifier: MIT
//here we will use a script to deploy SimpleStorage.sol

pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol"; //this is how you import from forge to let foundry know you're deoploying SimpleStorage via a script
import {SimpleStorage} from "../src/SimpleStorage.sol"; //the ".."" in the beginning is how you go down a directory

contract DeploySimpleStorage is Script {
    function run() external returns (SimpleStorage) {
        vm.startBroadcast(); //this line basicaly says, everything after this line is a transaction sent to the RPC
        //
        SimpleStorage simpleStorage = new SimpleStorage();
        //this is how you deploy the contract (by creating a new instance of it)
        //
        vm.stopBroadcast();
        //this line basicaly says, everything before this line is a transaction sent to the RPC and ends the broadcast

        return simpleStorage;
        //to run a script and deploy the contract run this in you terminal: 'forge script script/DeploySimpleStorage.s.sol --rpc-url  http://127.0.0.1:8545 --broadcast --private-key'
    }
}
