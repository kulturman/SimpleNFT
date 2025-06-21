// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {SimpleNFT} from "../src/SimpleNFT.sol";

contract SimpleNFTWithdrawTest is Test {
    SimpleNFT public simpleNFT;
    address public owner;
    address public nonOwner;

    function setUp() public {
        owner = address(1);
        nonOwner = address(0x1234);

        vm.prank(owner);
        simpleNFT = new SimpleNFT();

        // Fund the contract with some ETH
        vm.deal(address(nonOwner), 1 ether);
        vm.prank(nonOwner);
        simpleNFT.mintSimpleNFT{value: 200 gwei}();
    }

    function testWithdrawSuccess() public {
        vm.startPrank(owner);
        uint256 withdrawAmount = 100 gwei;

        uint256 initialOwnerBalance = owner.balance;
        uint256 initialContractBalance = simpleNFT.totalEthersCollected();

        simpleNFT.withdraw(withdrawAmount);

        uint256 finalOwnerBalance = owner.balance;
        uint256 finalContractBalance = simpleNFT.totalEthersCollected();

        assertEq(finalOwnerBalance, initialOwnerBalance + withdrawAmount);
        assertEq(finalContractBalance, initialContractBalance - withdrawAmount);
    }

    function testWithdrawOnlyOwner() public {
        uint256 withdrawAmount = 1 gwei;

        vm.prank(nonOwner);
        vm.expectRevert();
        simpleNFT.withdraw(withdrawAmount);
    }

    function testWithdrawInsufficientBalance() public {
        uint256 withdrawAmount = 15 ether; // More than contract has

        vm.expectRevert();
        simpleNFT.withdraw(withdrawAmount);
    }

    function testWithdrawZeroAmount() public {
        vm.startPrank(owner);

        uint256 initialOwnerBalance = owner.balance;
        uint256 initialContractBalance = simpleNFT.totalEthersCollected();

        simpleNFT.withdraw(0);

        // Balances should remain unchanged
        assertEq(owner.balance, initialOwnerBalance);
        assertEq(address(simpleNFT).balance, initialContractBalance);
    }

    function testWithdrawEntireBalance() public {
        vm.startPrank(owner);
        uint256 contractBalance = simpleNFT.totalEthersCollected();
        uint256 initialOwnerBalance = owner.balance;
        simpleNFT.withdraw(contractBalance);

        assertEq(address(simpleNFT).balance, 0);
        assertEq(owner.balance, initialOwnerBalance + contractBalance);
    }
}
