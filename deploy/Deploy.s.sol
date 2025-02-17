// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "contracts/FreeVoxelVerseMint.sol";

contract DeployScript is Script {
    function setUp() public {}

    function run() public {
    
        vm.startBroadcast();

        // Deploy the contract
        FreeVoxelVerseMC gameContract = new FreeVoxelVerseMC();
        console.log("Contract deployed to:", address(gameContract));

        /* Minting functionality preserved for reference
        // Mint an NFT character
        // gameContract.mintCharacterNFT(address);
        // console.log("Done!"); 
        */

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}