// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "../lib/forge-std/src/Test.sol";
import {SimpleNFT} from "../src/SimpleNFT.sol";

contract SimpleNFTRevealAndTokenUriTest is Test {
    SimpleNFT public simpleNFT;

    function setUp() public {
        simpleNFT = new SimpleNFT();
    }

    function testRevealFailsBeforeRevelDate() public {
        vm.expectRevert("Too early to reveal");
        simpleNFT.reveal();
    }

    function testRevealIsSuccessfulAfterRevealDate() public {
        vm.warp(simpleNFT.revealTimestamp() + 1 hours);
        simpleNFT.reveal();

        assertTrue(simpleNFT.revealed());
    }

    function testTokenUriReturnsObfuscatedUriWhenNotRevealed() public {
        simpleNFT.mint();
        assertEq(simpleNFT.tokenURI(1), "Collection not revealed yet!");
    }

    function testTokenUriReturnsRealUriWhenRevealed() public {
        simpleNFT.mint();
        vm.warp(simpleNFT.revealTimestamp() + 1 hours);
        simpleNFT.reveal();

        assertEq(simpleNFT.tokenURI(1), string(abi.encodePacked(simpleNFT.baseUrl(), "/1.json")));
    }
}
