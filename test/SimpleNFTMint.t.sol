pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";

import {SimpleNFT} from "../src/SimpleNFT.sol";
import {IERC721} from "../src/interfaces/IERC721.sol";

contract SimpleNFCMint is Test {
    SimpleNFT public simpleNFT;

    function setUp() public {
        simpleNFT = new SimpleNFT();
    }

    function testMintSucceedsAndImpactEnumarable() public {
        assertEq(simpleNFT.balanceOf(address(this)), 0);
        vm.expectEmit();
        emit IERC721.Transfer(address(0), address(this), 1);

        simpleNFT.mint();
        assertEq(simpleNFT.totalSupply(), 1);
        assertEq(simpleNFT.balanceOf(address(this)), 1);
        assertEq(simpleNFT.tokenOfOwnerByIndex(address(this), 0), 1);
        assertEq(simpleNFT.tokenByIndex(0), 1);
    }

    function testMintForDifferentAddressSucceeds() public {
        simpleNFT.mint(address(1));
        assertEq(simpleNFT.ownerOf(1), address(1));
    }

    function testMintSucceedsTwiceWith() public {
        assertEq(simpleNFT.balanceOf(address(this)), 0);
        simpleNFT.mint();
        simpleNFT.mint();

        assertEq(simpleNFT.totalSupply(), 2);
        assertEq(simpleNFT.balanceOf(address(this)), 2);
        assertEq(simpleNFT.tokenOfOwnerByIndex(address(this), 0), 1);
        assertEq(simpleNFT.tokenOfOwnerByIndex(address(this), 1), 2);
    }

    function testMintSucceedsWithDifferentUsersOneAfterAnother() public {
        address firstUser = address(1);
        address secondUser = address(2);

        simpleNFT.mint(firstUser);
        simpleNFT.mint(secondUser);

        assertEq(simpleNFT.balanceOf(firstUser), 1);
        assertEq(simpleNFT.balanceOf(secondUser), 1);

        assertEq(simpleNFT.tokenOfOwnerByIndex(firstUser, 0), 1);
        assertEq(simpleNFT.tokenOfOwnerByIndex(secondUser, 0), 2);
    }

    function testMintsFailsWhenNotContractOwner() public {
        vm.prank(address(0));
        vm.expectRevert();
        simpleNFT.mint();
    }
}
