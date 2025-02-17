// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "lib/openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract VoxelVerseStaking is Ownable, ReentrancyGuard {
    // Interfaces for the NFT and reward token
    IERC721 public nftCollection;
    IERC20 public rewardToken;
    
    // Staking settings
    uint256 public rewardRate = 10 * 10**18; // 10 tokens per day
    uint256 public constant SECONDS_IN_DAY = 86400;

    // Staking information
    struct Stake {
        address owner;
        uint256 timestamp;
        bool isStaked;
    }
    
    // Mapping from NFT ID to stake info
    mapping(uint256 => Stake) public stakes;
    
    // Events
    event NFTStaked(address indexed owner, uint256 tokenId, uint256 timestamp);
    event NFTUnstaked(address indexed owner, uint256 tokenId, uint256 timestamp);
    event RewardsClaimed(address indexed owner, uint256 amount);

    constructor(
        address _nftCollection,
        address _rewardToken
    ) Ownable() {
        nftCollection = IERC721(_nftCollection);
        rewardToken = IERC20(_rewardToken);
    }

    // Update reward rate (only owner)
    function setRewardRate(uint256 _rewardRate) external onlyOwner {
        rewardRate = _rewardRate;
    }

    // Calculate rewards for a specific token
    function calculateRewards(uint256 tokenId) public view returns (uint256) {
        Stake memory stake = stakes[tokenId];
        if (!stake.isStaked) return 0;
        
        uint256 timeElapsed = block.timestamp - stake.timestamp;
        return (timeElapsed * rewardRate) / SECONDS_IN_DAY;
    }

    // Stake NFT
    function stakeNFT(uint256 tokenId) external nonReentrant {
        require(nftCollection.ownerOf(tokenId) == msg.sender, "Not the owner");
        require(!stakes[tokenId].isStaked, "Already staked");

        // Transfer NFT to contract
        nftCollection.transferFrom(msg.sender, address(this), tokenId);

        // Record stake
        stakes[tokenId] = Stake({
            owner: msg.sender,
            timestamp: block.timestamp,
            isStaked: true
        });

        emit NFTStaked(msg.sender, tokenId, block.timestamp);
    }

    // Unstake NFT and claim rewards
    function unstakeNFT(uint256 tokenId) external nonReentrant {
        Stake memory stake = stakes[tokenId];
        require(stake.owner == msg.sender, "Not the staker");
        require(stake.isStaked, "Not staked");

        // Calculate and transfer rewards
        uint256 rewards = calculateRewards(tokenId);
        if (rewards > 0) {
            require(rewardToken.transfer(msg.sender, rewards), "Reward transfer failed");
            emit RewardsClaimed(msg.sender, rewards);
        }

        // Transfer NFT back to owner
        nftCollection.transferFrom(address(this), msg.sender, tokenId);

        // Clear stake
        delete stakes[tokenId];

        emit NFTUnstaked(msg.sender, tokenId, block.timestamp);
    }

    // Claim rewards without unstaking
    function claimRewards(uint256 tokenId) external nonReentrant {
        Stake memory stake = stakes[tokenId];
        require(stake.owner == msg.sender, "Not the staker");
        require(stake.isStaked, "Not staked");

        uint256 rewards = calculateRewards(tokenId);
        require(rewards > 0, "No rewards to claim");

        // Update timestamp
        stakes[tokenId].timestamp = block.timestamp;

        // Transfer rewards
        require(rewardToken.transfer(msg.sender, rewards), "Reward transfer failed");
        
        emit RewardsClaimed(msg.sender, rewards);
    }

    // View functions
    function getStakeInfo(uint256 tokenId) external view returns (
        address owner,
        uint256 timestamp,
        bool isStaked,
        uint256 currentRewards
    ) {
        Stake memory stake = stakes[tokenId];
        return (
            stake.owner,
            stake.timestamp,
            stake.isStaked,
            calculateRewards(tokenId)
        );
    }

    // Emergency withdraw function (only owner)
    function emergencyWithdraw(uint256 tokenId) external onlyOwner {
        require(stakes[tokenId].isStaked, "Not staked");
        address stakeOwner = stakes[tokenId].owner;
        
        // Transfer NFT back to original owner
        nftCollection.transferFrom(address(this), stakeOwner, tokenId);
        
        // Clear stake
        delete stakes[tokenId];
        
        emit NFTUnstaked(stakeOwner, tokenId, block.timestamp);
    }
}