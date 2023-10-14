// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.17;

// Helper we wrote to encode in Base64
import "./libraries/Base64.sol";

// NFT contract to inherit from.
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// Helper functions OpenZeppelin provides.
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "hardhat/console.sol";

contract PixelDudes is ERC721 {
    uint randNonce = 0; // this is used to help ensure that the algorithm has different inputs every time
    // We'll hold our character's attributes in a struct. Feel free to add
    // whatever you'd like as an attribute! (ex. defense, crit chance, etc).
    struct CharacterAttributes {
        uint characterIndex;
        string name;
        string imageURI;
        uint hp;
        uint maxHp;
        uint attackDamage;
    }

    // The tokenId is the NFTs unique identifier, it's just a number that goes
    // 0, 1, 2, 3, etc.
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // We create a mapping from the nft's tokenId => that NFTs attributes.
    mapping(uint256 => CharacterAttributes) public nftHolderAttributes;
    event CharacterNFTMinted(address sender, uint256 tokenId, uint256 characterIndex);
    event AttackComplete(address sender, uint newBossHp, uint newPlayerHp);

    struct BigBoss {
        string name;
        string imageURI;
        uint hp;
        uint maxHp;
        uint attackDamage;
    }

    BigBoss public bigBoss;

    // A mapping from an address => the NFTs tokenId. Gives me an ez way
    // to store the owner of the NFT and reference it later.
    mapping(address => uint256) public nftHolders;
    // A lil array to help us hold the default data for our characters.
    // This will be helpful when we mint new characters and need to know
    // things like their HP, AD, etc.
    CharacterAttributes[] defaultCharacters;
    constructor(
        string[] memory characterNames,
        string[] memory characterImageURIs,
        uint[] memory characterHp,
        uint[] memory characterAttackDmg,
        string memory bossName,
        string memory bossImageURI,
        uint bossHp,
        uint bossAttackDamage) ERC721("PixelDudes", "PXLDUDES") {
        // Initialize the boss. Save it to our global "bigBoss" state variable.
        bigBoss = BigBoss({
        name: bossName,
        imageURI: bossImageURI,
        hp: bossHp,
        maxHp: bossHp,
        attackDamage: bossAttackDamage
        });

        console.log("Done initializing boss %s w/ HP %s, img %s", bigBoss.name, bigBoss.hp, bigBoss.imageURI);
        // All the other character code is below here is the same as before, just not showing it to keep things short!
        // Loop through all the characters, and save their values in our contract so
        // we can use them later when we mint our NFTs.
        for(uint i = 0; i < characterNames.length; i += 1) {
            defaultCharacters.push(CharacterAttributes({
            characterIndex: i,
            name: characterNames[i],
            imageURI: characterImageURIs[i],
            hp: characterHp[i],
            maxHp: characterHp[i],
            attackDamage: characterAttackDmg[i]
            }));

            CharacterAttributes memory c = defaultCharacters[i];
            console.log("Done initializing %s w/ HP %s, img %s", c.name, c.hp, c.imageURI);
        }
        // I increment _tokenIds here so that my first NFT has an ID of 1.
        _tokenIds.increment();
    }
    function checkIfUserHasNFT() public view returns (CharacterAttributes memory) {
        // Get the tokenId of the user's character NFT
        uint256 userNftTokenId = nftHolders[msg.sender];
        // If the user has a tokenId in the map, return their character.
        if (userNftTokenId > 0) {
            return nftHolderAttributes[userNftTokenId];
        }
        // Else, return an empty character.
        else {
            CharacterAttributes memory emptyStruct;
            return emptyStruct;
        }
    }
    function getAllDefaultCharacters() public view returns (CharacterAttributes[] memory) {
        return defaultCharacters;
    }
    function getBigBoss() public view returns (BigBoss memory) {
        return bigBoss;
    }
    // Users would be able to hit this function and get their NFT based on the
    // characterId they send in!
    function mintCharacterNFT(uint _characterIndex) external {
        // Get current tokenId (starts at 1 since we incremented in the constructor).
        uint256 newItemId = _tokenIds.current();
        // The magical function! Assigns the tokenId to the caller's wallet address.
        _safeMint(msg.sender, newItemId);
        // We map the tokenId => their character attributes.
        nftHolderAttributes[newItemId] = CharacterAttributes({
        characterIndex: _characterIndex,
        name: defaultCharacters[_characterIndex].name,
        imageURI: defaultCharacters[_characterIndex].imageURI,
        hp: defaultCharacters[_characterIndex].hp,
        maxHp: defaultCharacters[_characterIndex].maxHp,
        attackDamage: defaultCharacters[_characterIndex].attackDamage
        });

        console.log("Minted NFT w/ tokenId %s and characterIndex %s", newItemId, _characterIndex);

        // Keep an easy way to see who owns what NFT.
        nftHolders[msg.sender] = newItemId;

        // Increment the tokenId for the next person that uses it.
        _tokenIds.increment();
        // emit event for created character
        emit CharacterNFTMinted(msg.sender, newItemId, _characterIndex);

    }
    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        CharacterAttributes memory charAttributes = nftHolderAttributes[_tokenId];

        string memory strHp = Strings.toString(charAttributes.hp);
        string memory strMaxHp = Strings.toString(charAttributes.maxHp);
        string memory strAttackDamage = Strings.toString(charAttributes.attackDamage);

        string memory json = Base64.encode(
            abi.encodePacked(
                '{"name": "',
                charAttributes.name,
                ' -- PixelDude #: ',
                Strings.toString(_tokenId),
                '", "description": "Your unique battle player in PixelDudes Arena!", "image": "',
                charAttributes.imageURI,
                '", "attributes": [ { "trait_type": "Health Points", "value": ',strHp,', "max_value":',strMaxHp,'}, { "trait_type": "Attack Damage", "value": ',
                strAttackDamage,'} ]}'
            )
        );

        string memory output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return output;
    }
    function attackBoss() public {
        // Get the state of the player's NFT.
        uint256 nftTokenIdOfPlayer = nftHolders[msg.sender];
        CharacterAttributes storage player = nftHolderAttributes[nftTokenIdOfPlayer];
        console.log("\nPlayer w/ character %s about to attack. Has %s HP and %s AD", player.name, player.hp, player.attackDamage);
        console.log("Boss %s has %s HP and %s AD", bigBoss.name, bigBoss.hp, bigBoss.attackDamage);
        // Make sure the player has more than 0 HP.
        require (
            player.hp > 0,
            "Error: character must have HP to attack boss."
        );
        // Make sure the boss has more than 0 HP.
        require (
            bigBoss.hp > 0,
            "Error: boss must have HP to attack character."
        );
        // Allow player to attack boss.
        if (bigBoss.hp < player.attackDamage) {
            bigBoss.hp = 0;
        } else {
            bigBoss.hp = bigBoss.hp - player.attackDamage;
        }
        // Allow boss to attack player.
        if (player.hp < bigBoss.attackDamage) {
            player.hp = 0;
        } else {
            player.hp = player.hp - bigBoss.attackDamage;
        }
        // Console for ease.
        console.log("Player attacked boss. New boss hp: %s", bigBoss.hp);
        console.log("Boss attacked player. New player hp: %s\n", player.hp);
        // Make sure the boss has more than 0 HP.
        // Allow player to attack boss.
        // Allow boss to attack player.
        console.log("%s swings at %s...", player.name, bigBoss.name);
        if (bigBoss.hp < player.attackDamage) {
            bigBoss.hp = 0;
            console.log("The boss is dead!");
        } else {
            if (randomMod(10) > 5) {
                // by passing 10 as the mod, we elect to only grab the last digit (0-9) of the hash!
                bigBoss.hp = bigBoss.hp - player.attackDamage;
                console.log("%s attacked boss. New boss hp: %s", player.name, bigBoss.hp);
            } else {
                console.log("%s missed!\n", player.name);
            }
        }
        emit AttackComplete(msg.sender, bigBoss.hp, player.hp);
    }
    function getRandomNumber() public view returns (uint )
    {
        bytes32 res = getRandom();
        uint256 num = uint256(res);
        return num;
    }

    function getRandom() private view returns (bytes32 addr) {
        assembly {
            let freemem := mload(0x40)
            let start_addr := add(freemem, 0)
            if iszero(staticcall(gas(), 0x18, 0, 0, start_addr, 32)) {
                invalid()
            }
            addr := mload(freemem)
        }
    }
    // DO NOT USE IN PRODUCTION. Use ChainLink VRF.
    function randomMod(uint _modulus) internal returns(uint) {
        randNonce++;                                                     // increase nonce
        return uint(keccak256(abi.encodePacked(block.timestamp,         //  now timestamp
            msg.sender,               // your address
            randNonce))) % _modulus;  // modulo using the _modulus argument
    }
}