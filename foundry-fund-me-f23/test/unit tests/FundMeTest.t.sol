//SPDX-License-Identifier: MIT
//here we want to test the fundme contract is doing what we want it to do

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol"; //these standard contracts (in our case 'Test.sol') are available to us in the forge-std package and make things a bit easier
import {FundMe} from "../../src/FundMe.sol"; //this is the contract we want to test
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";//here we are importing the DeployFundMe contract from the script folder

contract FundMeTest is Test {
    FundMe fundMe;//here we are declaring a variable of type FundMe, that way we can use it in our tests (here we used it to test min is five dollars)
    
    address USER = makeAddr("user"); // here we are creating a fake address to use in our tests (https://book.getfoundry.sh/reference/forge-std/make-addr?highlight=makeaddr#makeaddr)
    
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant USER_BALANCE = 1 ether;
    uint256 constant GAS_PRICE = 1;


    function setUp() external {
        //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployfundMe = new DeployFundMe();// this line of code says that we are deploying a new DeployFundMe contract
        fundMe = deployfundMe.run();//this line of code says that we are running the run function from the DeployFundMe contract
        vm.deal(USER, USER_BALANCE);//this line of code is saying that we are setting up the USER addy with 1 ETH  
    }

    function testMinimumDollarisFive() public{
        assertEq(fundMe.MINIMUM_USD(), 5e18); //the assertEq function is a function from the Test.sol contract that we imported
    }

    function testOwnerIsDeployer() public{
        //console.log(fundMe.i_owner());//console.log is a functiont that shows us what is in the ('') (in this case fundMe.i_owner() and msg.sender)
        //console.log(msg.sender);
        assertEq(fundMe.getOwner(), msg.sender);//here we are asserting that the owner of the contract is the address that deployed it; in this case it's FundMeTest
    }

    function testPriceFeedVersionIsAccurate() public{
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughETH () public{
        vm.expectRevert(); //this line of code is saying that we expect the revert error message to be "You need to spend more ETH!" and if it's not then the test fails
            fundMe.fund();//if this test passes that means we are not sending enough ETH to the contract (if it fails than we are sending the minimum 5 USD)
        }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); //this line of code is saying that we are sending 5 ETH to the contract from the USER address
        fundMe.fund{value: SEND_VALUE}();
        
        uint256 amountFunded = fundMe.getAddreessToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);     
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);//this is checking that the funder = USER
    }



//this is a modifier that we can use in our tests to make sure that the contract is funded before we run the test; any function written after this will automatically fund the USER
//therefore, you wouldn't need to write vm.prank(USER); fundMe.fund{value: SEND_VALUE}(); before every test
    modifier funded(){ 
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }


    function testOnlyOwnerCanWithdraw() public{//here this test passes if the user trying to withdraw is not the owner of the contract
        
        vm.expectRevert();// this line of code is saying that we expect the revert error message to be "Not owner" and if it's not then the test fails
        vm.prank(USER);//then we will have the USER try to withdraw
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded{
       //Arrange
         uint256 startingOwnerBalance = fundMe.getOwner().balance;
         uint256 startingFundMeBalance = address(fundMe).balance;

       //Action
        //uint256 gasStart = gasleft();//gasleft is a built in Solidity function that returns the amount of gas left in the transaction
        //vm.txGasPrice(GAS_PRICE);//this line of code is saying that we want to set the gas price to 1 gwei (https://book.getfoundry.sh/reference/forge-std/tx-gas-price?highlight=txgasprice#txgasprice
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        //uint256 gasEnd = gasleft();
        //uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice; //this line of code is saying that we want to calculate the amount of gas used in the transaction 
        //console.log(gasUsed); //this line of code is saying that we want to log the amount of gas used in the transaction (https://book.getfoundry.sh/reference/forge-std/console-log?highlight=consolelog#consolelog

       //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(endingOwnerBalance, startingOwnerBalance + startingFundMeBalance);
    }


    function testWithdrawFromMultipleFunders() public funded{
        //Arrange
        uint160 numberOfFundMeFunders = 10; //if we want to generate a number of addresses we have to use a uint160 

        uint160 startingFunderIndex = 2;//here we are saying that we want to start funding the contract from the USER address 2 (the first two addresses are the owner and the USER)
        for (uint160 i = startingFunderIndex; i < numberOfFundMeFunders; i++){//this for loop is saying that we want to fund the contract from the USER address 10 times
            
            hoax(address(i), SEND_VALUE);
            //the above vms will create addresses to fund the fundMe contract using the 'hoax' cheat code (https://book.getfoundry.sh/reference/forge-std/hoax?highlight=hoax#hoax)
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        //Assert
        assertEq(address(fundMe).balance, 0);//assert that we have removed all funds from fund me contract
        assertEq(fundMe.getOwner().balance, startingOwnerBalance + startingFundMeBalance);//assert that the owner has received all the funds from the contract
        
   }

   function tesFundFailsWithoutEnoughEth () public {
    vm.expectRevert(); //this is saying 'hey the next line should revert'; if this test passes it means it failed ie. we did not send enough ETH
    fundMe.fund(); //send 0 value to the contract; therfore, the test passes
   }

}



