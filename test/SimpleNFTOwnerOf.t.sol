pragma solidity ^0.8.28;

import {SimpleNFT} from "../src/SimpleNFT.sol";
import {Test} from "../lib/forge-std/src/Test.sol";

contract SimpleNFTOwnerOf is Test {
    SimpleNFT public simpleNFT;

    function setUp() public {
        simpleNFT = new SimpleNFT();
        simpleNFT.mint();
    }

    function testOwnerOfWithInvalidTokenReverts() public {
        vm.expectRevert();
        simpleNFT.ownerOf(100);
    }

    function testOwnerOfSucceeds() public view {
        uint256 tokenId = 1;
        address contractOwner = address(this);
        assertEq(simpleNFT.ownerOf(tokenId), contractOwner);
    }
}
