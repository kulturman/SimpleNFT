// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {SimpleNFC} from "../src/SimpleNFC.sol";

contract CounterTest is Test {
    SimpleNFC public simpleNFC;

    function setUp() public {
        simpleNFC = new SimpleNFC();
    }

    function test_Increment() public {
        uint a = 2;
        assertEq(a, 2);
    }
}
