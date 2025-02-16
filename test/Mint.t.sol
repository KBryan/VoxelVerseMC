// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../contracts/VoxelVerseMC.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Mock ERC20 token for testing
contract MockToken is ERC20 {
    constructor() ERC20("Mock Token", "MTK") {
        _mint(msg.sender, 1000 * 10**18);
    }
}

contract VoxelVerseMCTest is Test {
    VoxelVerseMC public voxelVerse;
    MockToken public mockToken;
    address public user = address(1);

    function setUp() public {
        // Deploy mock token
        mockToken = new MockToken();
        
        // Deploy VoxelVerseMC with mock token
        voxelVerse = new VoxelVerseMC(address(mockToken));

        // Setup user with tokens
        vm.startPrank(user);
        mockToken.approve(address(voxelVerse), 100 * 10**18);
        deal(address(mockToken), user, 100 * 10**18);
        vm.stopPrank();
    }

    function test_MintCharacterNFT() public {
        vm.startPrank(user);
        
        // Mint NFT
        voxelVerse.mintCharacterNFT();
        
        // Check NFT ownership
        assertEq(voxelVerse.ownerOf(0), user);
        
        // Check NFT attributes
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
}