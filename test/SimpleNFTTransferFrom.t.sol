pragma solidity ^0.8.28;

import {SimpleNFT} from "../src/SimpleNFT.sol";
import {Test, console} from "../lib/forge-std/src/Test.sol";
import {IERC721} from "../src/interfaces/IERC721.sol";

contract SimpleNFTTransferFrom is Test {
    SimpleNFT public simpleNFT;
    address public contractOwner;
    address public secondAccount;

    function setUp() public {
        simpleNFT = new SimpleNFT();
        simpleNFT.mint();
        contractOwner = address(this);
        secondAccount = address(1);
    }

    function testTransferFromSucceedsWhenUsingOneOwnAccount() public {
        vm.expectEmit();
        emit IERC721.Transfer(contractOwner, secondAccount, 1);
        simpleNFT.transferFrom(contractOwner, secondAccount, 1);
        assertEq(simpleNFT.ownerOf(1), secondAccount);
    }

    function testTransferFromFailsWhenTokenDoesNotBelongToSender() public {
        //Token 1 belongs to contractOwner
        vm.expectRevert();
        simpleNFT.transferFrom(secondAccount, contractOwner, 1);
    }

    function testTransferFromFailsWhenTokenNotApprovedBy() public {
        //Token 1 belongs to secondAccount now, we already tested this case above
        simpleNFT.transferFrom(contractOwner, secondAccount, 1);

        vm.expectRevert(abi.encodeWithSelector(IERC721.NoAuthorizationOnToken.selector, 1, contractOwner));
        simpleNFT.transferFrom(secondAccount, contractOwner, 1);
    }

    function testTransferSucceedsWhenTokenIsApproved() public {
        address thirdAccount = address(2);
        simpleNFT.approve(secondAccount, 1);

        vm.prank(secondAccount);
        simpleNFT.transferFrom(contractOwner, thirdAccount, 1);

        assertEq(simpleNFT.balanceOf(contractOwner), 0);
        assertEq(simpleNFT.balanceOf(secondAccount), 0);
        assertEq(simpleNFT.balanceOf(thirdAccount), 1);
    }

    function testTransferSucceedsWhenSenderIsAllApproved() public {
        address thirdAccount = address(2);
        simpleNFT.setApprovalForAll(secondAccount, true);

        vm.prank(secondAccount);
        simpleNFT.transferFrom(contractOwner, thirdAccount, 1);

        assertEq(simpleNFT.balanceOf(contractOwner), 0);
        assertEq(simpleNFT.balanceOf(secondAccount), 0);
        assertEq(simpleNFT.balanceOf(thirdAccount), 1);
    }

    function testTransferFailsToZeroAddress() public {
        vm.expectRevert("Invalid address");
        simpleNFT.transferFrom(contractOwner, address(0), 1);
    }

    function testTransferFailsForNonExistentToken() public {
        vm.expectRevert(abi.encodeWithSelector(IERC721.InvalidToken.selector, 999));
        simpleNFT.transferFrom(contractOwner, secondAccount, 999);
    }

    function testSuccessfulTransferUpdatesOwnedTokens() public {
        address firstUser = address(this);
        address secondUser = address(2);

        //We already minted on in setUp
        simpleNFT.mint(firstUser);

        assertEq(simpleNFT.tokenOfOwnerByIndex(firstUser, 0), 1);
        assertEq(simpleNFT.tokenOfOwnerByIndex(firstUser, 1), 2);

        simpleNFT.transferFrom(firstUser, secondUser, 2);

        assertEq(simpleNFT.tokenOfOwnerByIndex(firstUser, 0), 1);
        assertEq(simpleNFT.tokenOfOwnerByIndex(secondUser, 0), 2);
    }

    function testTransferClearsApprovedAddress() public {
        simpleNFT.approve(secondAccount, 1);
        vm.prank(secondAccount);
        simpleNFT.transferFrom(contractOwner, secondAccount, 1);

        assertEq(simpleNFT.getApproved(1), address(0));
        assertEq(simpleNFT.balanceOf(contractOwner), 0, "Contract owner should have no balance");
        assertEq(simpleNFT.balanceOf(secondAccount), 1, "Receiver owner should have 1 for balance");
    }
}
