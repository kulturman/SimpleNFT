// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Test} from "../lib/forge-std/src/Test.sol";
import {SimpleNFT} from "../src/SimpleNFT.sol";
import {IERC721Enumerable} from "../src/interfaces/IERC721Enumerable.sol";
import {IERC721} from "../src/interfaces/IERC721.sol";
import {IERC165} from "../src/interfaces/IERC165.sol";
import {IERC721Metadata} from "../src/interfaces/IERC721Metadata.sol";

contract SimpleNFTSupportsInterfaceTest is Test {
    SimpleNFT public simpleNFT;

    function setUp() public {
        simpleNFT = new SimpleNFT();
    }

    function testReturnsFalseIfContractDoesNotSupportInterface() public {
        assertFalse(simpleNFT.supportsInterface(bytes4(type(IERC165).interfaceId)));
    }

    function testReturnsTrueIfContractSupportsInterface() public {
        assertTrue(simpleNFT.supportsInterface(bytes4(type(IERC721).interfaceId)));
        assertTrue(simpleNFT.supportsInterface(bytes4(type(IERC721Enumerable).interfaceId)));
        assertTrue(simpleNFT.supportsInterface(bytes4(type(IERC721Metadata).interfaceId)));
    }
}
