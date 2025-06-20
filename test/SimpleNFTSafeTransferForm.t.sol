// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {Test} from "../lib/forge-std/src/Test.sol";
import {SimpleNFT} from "../src/SimpleNFT.sol";
import {IERC721} from "../src/interfaces/IERC721.sol";
import {ERC721RightReceiver} from "../src/test/ERC721RightReceiver.sol";
import {ERC721WrongReceiver} from "../src/test/ERC721WrongReceiver.sol";

contract SimpleNFTSafeTransferForm is Test {
    SimpleNFT public simpleNFT;
    address public contractOwner;
    address public secondAccount;

    function setUp() public {
        simpleNFT = new SimpleNFT();
        simpleNFT.mint();
        contractOwner = address(this);
        secondAccount = address(1);
    }

    function testSuccessfulSafeTransferUpdatesOwnedTokens() public {
        address firstUser = address(this);
        address secondUser = address(2);

        //We already minted on in setUp
        simpleNFT.mint(firstUser);

        assertEq(simpleNFT.tokenOfOwnerByIndex(firstUser, 0), 1);
        assertEq(simpleNFT.tokenOfOwnerByIndex(firstUser, 1), 2);

        simpleNFT.safeTransferFrom(firstUser, secondUser, 2);

        assertEq(simpleNFT.tokenOfOwnerByIndex(firstUser, 0), 1);
        assertEq(simpleNFT.tokenOfOwnerByIndex(secondUser, 0), 2);
    }

    function testSafeTransferFailsToAddressIsInvalid() public {
        vm.expectRevert("Invalid address");

        simpleNFT.safeTransferFrom(address(1), address(0), 1, bytes(""));
    }

    function testSafeTransferFailsFromAddressIsInvalid() public {
        vm.expectRevert("Invalid address");

        simpleNFT.safeTransferFrom(address(0), address(1), 1, bytes(""));
    }

    function testSafeTransferFailsItTokenDoesNotBelongToSender() public {
        //Token 1 belongs to contractOwner
        vm.expectRevert(abi.encodeWithSelector(IERC721.NoAuthorizationOnToken.selector, 1, address(this)));
        simpleNFT.safeTransferFrom(secondAccount, contractOwner, 1, "");
    }

    function testSafeTransferWhenReceiverIsEOA() public {
        assertEq(simpleNFT.ownerOf(1), contractOwner);

        vm.expectEmit();

        emit IERC721.Transfer(contractOwner, secondAccount, 1);

        simpleNFT.safeTransferFrom(contractOwner, secondAccount, 1);

        assertEq(simpleNFT.ownerOf(1), secondAccount);
    }

    function testSafeTransferFailsWhenReceiverIsASmartContractAndDoesNotRespectOnReceiverInterface() public {
        address receivingContractAddress = address(new ERC721WrongReceiver());
        vm.expectRevert();

        simpleNFT.safeTransferFrom(contractOwner, receivingContractAddress, 1);
    }

    function testSafeTransferFailsWhenReceiverIsASmartContractAndDoesRespectOnReceiverInterface() public {
        address receivingContractAddress = address(new ERC721RightReceiver());

        simpleNFT.safeTransferFrom(contractOwner, receivingContractAddress, 1);
        assertEq(simpleNFT.ownerOf(1), receivingContractAddress);
    }
}
