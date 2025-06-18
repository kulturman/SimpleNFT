// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {SimpleNFT} from "../src/SimpleNFT.sol";

contract CounterScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("SEPOLIA_PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        new SimpleNFT();

        vm.stopBroadcast();
    }
}
