// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {NFTWithUSDC} from "../src/NFTWithUSDC.sol";

contract DeployScript is Script {
    function run() public returns (NFTWithUSDC) {
        // Base Sepolia USDC address
        address usdcAddress = 0x036CbD53842c5426634e7929541eC2318f3dCF7e;

        vm.startBroadcast();
        NFTWithUSDC nft = new NFTWithUSDC(usdcAddress);
        vm.stopBroadcast();

        return nft;
    }
}
