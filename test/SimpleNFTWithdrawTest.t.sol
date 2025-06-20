// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {SimpleNFT} from "../src/SimpleNFT.sol";
import {IERC721} from "../src/interfaces/IERC721.sol";

contract SimpleNFTWithdrawTest is Test {
    SimpleNFT public simpleNFT;
    address public contractOwner;
    address public secondUser;

    function setUp() public {
        simpleNFT = new SimpleNFT();
        contractOwner = address(this);
        secondUser = address(1);
    }

    function testWithdrawalFailsWhenNoBalance() public {
        /*vm.expectRevert(
            abi.encodeWithSelector(IERC721.InsufficientBalanceToWithdraw.selector, contractOwner, 0, 1 wei)
        );

        simpleNFT.withdraw(1 wei);*/
    }

    function testWithdrawalFailsWhenBalanceIsTooLow() public {
        /*simpleNFT.mintSimpleNFT();

        vm.expectRevert(
            abi.encodeWithSelector(IERC721.InsufficientBalanceToWithdraw.selector, contractOwner, 1 gwei, 2 gwei)
        );
        simpleNFT.withdraw(2 gwei);*/
    }
}
