pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";

import {SimpleNFC, IERC721} from "../src/SimpleNFC.sol";

contract SimpleNFCMint is Test {
    SimpleNFC public simpleNFC;

    function setUp() public {
        simpleNFC = new SimpleNFC();
    }

    function testMintSucceeds() public {
        assertEq(simpleNFC.balances(address(this)), 0);
        simpleNFC.mint();
        assertEq(simpleNFC.balances(address(this)), 1);
    }

    function testMintSucceedsTwice() public {
        assertEq(simpleNFC.balances(address(this)), 0);
        simpleNFC.mint();
        simpleNFC.mint();
        assertEq(simpleNFC.balances(address(this)), 2);
    }

    function testMintsFailsWhenNotOwner() public {
        vm.prank(address (0));
        vm.expectRevert();
        simpleNFC.mint();
    }
}