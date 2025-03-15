// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {SimpleNFC, IERC721} from "../src/SimpleNFC.sol";

contract SimpleNFCApprove is Test {
    SimpleNFC public simpleNFC;

    function setUp() public {
        simpleNFC = new SimpleNFC();
        simpleNFC.mint();
    }

    function testApprovesSuccessfully() public {
        uint256 tokenId = 1;
        //Token is not approved by default
        assertEq(simpleNFC.getApproved(tokenId), address(0));
        address contractOwner = address(this);

        vm.expectEmit();
        emit IERC721.Approval(contractOwner, contractOwner, tokenId);
        simpleNFC.approve(contractOwner, tokenId);
        assertEq(simpleNFC.getApproved(tokenId), contractOwner);
    }
}
