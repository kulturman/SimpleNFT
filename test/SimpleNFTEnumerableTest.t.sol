// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {Test} from "../lib/forge-std/src/Test.sol";
import {SimpleNFT} from "../src/SimpleNFT.sol";

contract SimpleNFTEnumerableTest is Test {
    SimpleNFT public simpleNFT;

    function setUp() public {
        simpleNFT = new SimpleNFT();
    }

    function testTotalSupplyWhenNothingHasBeenMinted() public {
        assertEq(0, simpleNFT.totalSupply());
    }

    function testTotalSupply() public {
        simpleNFT.mint();
        simpleNFT.mint();

        assertEq(simpleNFT.totalSupply(), 2);
    }

    function testTokenByIndex() public {
        simpleNFT.mint();
        simpleNFT.mint();
        simpleNFT.mint();

        assertEq(1, simpleNFT.tokenByIndex(0));
        assertEq(2, simpleNFT.tokenByIndex(1));
        assertEq(3, simpleNFT.tokenByIndex(2));
    }
}
