// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "contracts/VoxelVerseMC.sol";

contract DeployScript is Script {
    function setUp() public {}

    function run() public {
        // Start broadcasting transactions
        vm.startBroadcast();

        // Deploy the contract
        VoxelVerseMC gameContract = new VoxelVerseMC();
        console.log("Contract deployed to:", address(gameContract));

        // Mint an NFT character
        gameContract.mintCharacterNFT();

        // Get and log the token URI
        string memory returnedTokenUri = gameContract.tokenURI(1);
        console.log("Token URI:", returnedTokenUri);

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}