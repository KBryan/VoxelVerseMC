// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "contracts/FreeVoxelVerseMint.sol";

contract VoxelVerseMCTest is Test {
    FreeVoxelVerseMC public voxelVerse;
    address public player = address(0x1);

    function setUp() public {
        // Deploy the contract
        voxelVerse = new FreeVoxelVerseMC();
    }

    function testMintNFT() public {
        // Set player address
        vm.startPrank(player);

        // Mint NFT
        voxelVerse.mintCharacterNFT();

        // Verify NFT was minted to the correct address
        assertEq(voxelVerse.ownerOf(0), player);

        // Get token URI and verify it's not empty
        string memory tokenURI = voxelVerse.tokenURI(0);
        assertTrue(bytes(tokenURI).length > 0);

        // Get character attributes and verify initial values
        (
            string memory name,
            string memory imageURI,
            uint256 happiness,
            uint256 thirst,
            uint256 hunger,
            uint256 xp,
            uint256 daysSurvived,
            uint256 characterLevel,
            uint256 health,
            uint256 heat
        ) = voxelVerse.nftHolderAttributes(0);

        // Verify initial values
        assertEq(happiness, 50);
        assertEq(thirst, 100);
        assertEq(hunger, 100);
        assertEq(xp, 1);
        assertEq(daysSurvived, 1);
        assertEq(characterLevel, 1);
        assertEq(health, 100);
        assertEq(heat, 50);

        vm.stopPrank();
    }

    function testCannotMintTwice() public {
        // Set player address
        vm.startPrank(player);

        // First mint should succeed
        voxelVerse.mintCharacterNFT();

        // Second mint should fail
        vm.expectRevert("Address already owns an NFT");
        voxelVerse.mintCharacterNFT();

        vm.stopPrank();
    }
}