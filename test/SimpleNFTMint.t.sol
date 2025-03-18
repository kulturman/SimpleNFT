pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";

import {SimpleNFT, IERC721} from "../src/SimpleNFT.sol";

contract SimpleNFCMint is Test {
    SimpleNFT public simpleNFC;

    function setUp() public {
        simpleNFC = new SimpleNFT();
    }

    function testMintSucceeds() public {
        assertEq(simpleNFC.balanceOf(address(this)), 0);
        simpleNFC.mint();
        assertEq(simpleNFC.balanceOf(address(this)), 1);
    }

    function testMintSucceedsTwice() public {
        assertEq(simpleNFC.balanceOf(address(this)), 0);
        simpleNFC.mint();
        simpleNFC.mint();
        assertEq(simpleNFC.balanceOf(address(this)), 2);
    }

    function testMintsFailsWhenNotOwner() public {
        vm.prank(address(0));
        vm.expectRevert();
        simpleNFC.mint();
    }
}
