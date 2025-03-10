// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {SimpleNFC} from "../src/SimpleNFC.sol";

contract CounterScript is Script {
    SimpleNFC public simpleNFC;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        simpleNFC = new SimpleNFC();

        vm.stopBroadcast();
    }
}
