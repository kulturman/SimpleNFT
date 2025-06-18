pragma solidity ^0.8.28;

import {SimpleNFT} from "../src/SimpleNFT.sol";
import {IERC721} from "../src/interfaces/IERC721.sol";
import {Test} from "../lib/forge-std/src/Test.sol";

contract SimpleNFTSetApprovalForAll is Test {
    SimpleNFT public simpleNFC;

    function setUp() public {
        simpleNFC = new SimpleNFT();
    }

    function testApprovalForAllSucceeds() public {
        address contractOwner = address(this);
        address operator = address(1);
        assertFalse(simpleNFC.isApprovedForAll(contractOwner, operator));

        vm.expectEmit();
        emit IERC721.ApprovalForAll(contractOwner, operator, true);
        simpleNFC.setApprovalForAll(operator, true);
        assertTrue(simpleNFC.isApprovedForAll(contractOwner, operator));
    }
}
