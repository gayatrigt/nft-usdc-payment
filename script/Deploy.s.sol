// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {NFTSwap} from "../src/NFTSwap.sol";
import {console} from "forge-std/console.sol";

contract DeployNFTSwap is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address nftContract = vm.envAddress("NFT_CONTRACT");
        uint256 nftId = vm.envUint("NFT_ID");
        address seller = vm.envAddress("SELLER");
        address buyer = vm.envAddress("BUYER");

        // Log values to verify
        console.log("NFT Contract:", nftContract);
        console.log("NFT ID:", nftId);
        console.log("Seller:", seller);
        console.log("Buyer:", buyer);

        vm.startBroadcast(deployerPrivateKey);

        // Deploy NFTSwap contract with try-catch to get error message
        try
            new NFTSwap(
                address(0x036CbD53842c5426634e7929541eC2318f3dCF7e), // USDC on Base Sepolia
                nftContract,
                nftId,
                2_000_000, // 2 USDC (6 decimals)
                seller,
                buyer
            )
        returns (NFTSwap nftSwap) {
            console.log("NFTSwap deployed to:", address(nftSwap));
        } catch Error(string memory reason) {
            console.log("Deployment failed:", reason);
        }

        vm.stopBroadcast();
    }
}
