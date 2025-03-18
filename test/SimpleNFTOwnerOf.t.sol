pragma solidity ^0.8.28;

import "../src/SimpleNFT.sol";
import {Test} from "../lib/forge-std/src/Test.sol";

contract SimpleNFTOwnerOf is Test {
    SimpleNFT public simpleNFC;

    function setUp() public {
        simpleNFC = new SimpleNFT();
        simpleNFC.mint();
    }

    function testOwnerOfWithInvalidTokenReverts() public {
        vm.expectRevert();
        simpleNFC.ownerOf(100);
    }

    function testOwnerOfSucceeds() public view {
        uint256 tokenId = 1;
        address contractOwner = address(this);
        assertEq(simpleNFC.ownerOf(tokenId), contractOwner);
    }
}
