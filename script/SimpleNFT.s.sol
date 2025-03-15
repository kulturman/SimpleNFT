// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {SimpleNFT} from "../src/SimpleNFT.sol";

contract CounterScript is Script {
    SimpleNFT public simpleNFC;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        simpleNFC = new SimpleNFT();

        vm.stopBroadcast();
    }
}
