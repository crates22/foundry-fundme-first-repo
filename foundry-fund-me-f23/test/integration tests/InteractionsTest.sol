//SPDX-License-Identifier: MIT
//here we are testing the interactions script
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol"; //these standard contracts (in our case 'Test.sol') are available to us in the forge-std package and make things a bit easier
import {FundMe} from "../../src/FundMe.sol"; //this is the contract we want to test
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test{

 FundMe fundMe;//here we are declaring a variable of type FundMe, that way we can use it in our tests (here we used it to test min is five dollars)
    
    address USER = makeAddr("user"); // here we are creating a fake address to use in our tests (https://book.getfoundry.sh/reference/forge-std/make-addr?highlight=makeaddr#makeaddr)
    
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant USER_BALANCE = 1 ether;
    uint256 constant GAS_PRICE = 1;

     function setUp() external {
        DeployFundMe deploy = new DeployFundMe();// this line of code says that we are deploying a new DeployFundMe contract
        fundMe = deploy.run();//this line of code says that we are running the run function from the DeployFundMe contract
        vm.deal(USER, USER_BALANCE);//this line of code is saying that we are setting up the USER addy with 1 ETH  
    }

    function testUserCanFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);
    
    }

}