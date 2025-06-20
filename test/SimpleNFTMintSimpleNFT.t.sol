// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {Test} from "../lib/forge-std/src/Test.sol";
import {SimpleNFT} from "../src/SimpleNFT.sol";
import {IERC721} from "../src/interfaces/IERC721.sol";

contract SimpleNFTMintSimpleNFT is Test {
    SimpleNFT public simpleNFT;
    address public contractOwner;
    address public secondUser;

    function setUp() public {
        simpleNFT = new SimpleNFT();
        contractOwner = address(this);
        secondUser = address(1);

        vm.deal(contractOwner, 1 ether);
        vm.deal(secondUser, 1 ether);
    }

    function testMintingFailsIfAmountSentIsLessThanTokenPrice() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC721.InsufficientAmountOrNotMultipleOfTokenPrice.selector, 1 wei, simpleNFT.TOKEN_UNIT_COST()
            )
        );
        simpleNFT.mintSimpleNFT{value: 1 wei}();
    }

    function testMintingSuccessful() public {
        vm.prank(secondUser);
        simpleNFT.mintSimpleNFT{value: 1 gwei}();

        assertEq(simpleNFT.totalSupply(), 1);

        assertEq(simpleNFT.totalEthersCollected(), 1 gwei);
        assertEq(simpleNFT.ownerOf(1), secondUser);
    }

    function testMintingTwoTokensAtOnceSuccessfully() public {
        vm.prank(secondUser);
        simpleNFT.mintSimpleNFT{value: 2 gwei}();

        assertEq(simpleNFT.totalSupply(), 2);

        assertEq(simpleNFT.totalEthersCollected(), 2 gwei);
        assertEq(simpleNFT.ownerOf(1), secondUser);
        assertEq(simpleNFT.ownerOf(2), secondUser);
    }

    function testMultipleSuccessfulMinting() public {
        vm.startPrank(secondUser);
        simpleNFT.mintSimpleNFT{value: 1 gwei}();
        simpleNFT.mintSimpleNFT{value: 1 gwei}();
        vm.stopPrank();

        assertEq(simpleNFT.totalEthersCollected(), 2 gwei);
        assertEq(simpleNFT.totalSupply(), 2);

        assertEq(simpleNFT.ownerOf(1), secondUser);
        assertEq(simpleNFT.ownerOf(2), secondUser);
    }
}
