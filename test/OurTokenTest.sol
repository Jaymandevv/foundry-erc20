// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DeployOurToken} from "script/DeployOurToken.s.sol";
import {OurToken} from "src/OurToken.sol";

contract OurTokenTest is Test {
    OurToken public ourToken;
    DeployOurToken public deployer;

    address jay = makeAddr("jay");
    address wealth = makeAddr("wealth");

    uint256 public constant STARTING_BALANCE = 100 ether;

    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();

        vm.prank(msg.sender);
        ourToken.transfer(jay, STARTING_BALANCE);
    }

    function testJayBalance() public {
        assertEq(STARTING_BALANCE, ourToken.balanceOf(jay));
    }

    function testAllowancesWork() public {
        uint256 intialAllowance = 1000;
        uint256 transferAmount = 500;

        // jay approves wealth to spend some tokens on his behalf
        vm.prank(jay);
        ourToken.approve(wealth, intialAllowance);

        vm.prank(wealth);
        ourToken.transferFrom(jay, wealth, transferAmount);

        assertEq(transferAmount, ourToken.balanceOf(wealth));
        assertEq(STARTING_BALANCE - transferAmount, ourToken.balanceOf(jay));
    }

    // AI tests - chat-gpt
    function testTransferFromRevertsWhenExceedingAllowance() public {
        vm.startPrank(jay);

        // Approve user2
        uint256 approveAmount = 50 ether;
        ourToken.approve(wealth, approveAmount);

        vm.stopPrank();
        vm.startPrank(wealth);

        // Attempt transferFrom exceeding allowance
        uint256 transferAmount = 60 ether;
        vm.expectRevert();
        ourToken.transferFrom(jay, wealth, transferAmount);

        vm.stopPrank();
    }

    function testAllowanceDecreasesAfterTransferFrom() public {
        vm.startPrank(jay);

        // Approve wealth
        uint256 approveAmount = 50 ether;
        ourToken.approve(wealth, approveAmount);

        vm.stopPrank();
        vm.startPrank(wealth);

        // Perform transferFrom
        uint256 transferAmount = 20 ether;
        ourToken.transferFrom(jay, wealth, transferAmount);

        // Verify allowance decreases
        assertEq(
            ourToken.allowance(jay, wealth),
            approveAmount - transferAmount
        );

        vm.stopPrank();
    }
}
