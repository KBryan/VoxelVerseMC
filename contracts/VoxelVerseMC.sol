// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./libraries/Base64.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract VoxelVerseMC is ERC721, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint256;

    Counters.Counter private _tokenIds;
    bool private _characterMinted = false;

    struct CharacterAttributes {
        string name;
        string imageURI;
        uint happiness;
        uint thirst;
        uint hunger;
        uint xp;
        uint daysSurvived;
        uint characterLevel;
        uint health;
    }

    mapping(uint256 => CharacterAttributes) public nftHolderAttributes;
    mapping(uint256 => bool) private _tokenMinted;

    event CharacterNFTMinted(address sender, uint256 tokenId);
    event CharacterUpdated(uint256 tokenId, CharacterAttributes attributes);
    event CharacterNFTMinted(address indexed sender, uint256 indexed tokenId, CharacterAttributes attributes);


    constructor() ERC721("VoxelVerseMC", "VVMC") {}

    function mintCharacterNFT(CharacterAttributes memory attributes) external {
        uint256 newItemId = _tokenIds.current();

        require(!_tokenMinted[newItemId], "Character already minted");

        _safeMint(msg.sender, newItemId);
        nftHolderAttributes[newItemId] = attributes;
        _tokenMinted[newItemId] = true;

        _tokenIds.increment();

        emit CharacterNFTMinted(msg.sender, newItemId, attributes);
    }

    function updateCharacterAttributes(uint256 tokenId, CharacterAttributes memory attributes) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "Caller is not owner nor approved");
        nftHolderAttributes[tokenId] = attributes;

        emit CharacterUpdated(tokenId, attributes);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        CharacterAttributes memory charAttributes = nftHolderAttributes[tokenId];

        // Start building the JSON string
        string memory jsonPart1 = string(abi.encodePacked(
            '{"name":"', charAttributes.name,
            '","description":"This is your beta character in the VoxelVerseMC game!","image":"',
            charAttributes.imageURI, '","attributes":['
        ));

        // Attributes part
        string memory attributesJson = string(abi.encodePacked(
            '{"trait_type":"Happiness","value":"', charAttributes.happiness.toString(), '"},',
            '{"trait_type":"Health","value":"', charAttributes.health.toString(), '"},',
            '{"trait_type":"Hunger","value":"', charAttributes.hunger.toString(), '"},',
            '{"trait_type":"XP","value":"', charAttributes.xp.toString(), '"},',
            '{"trait_type":"Days","value":"', charAttributes.daysSurvived.toString(), '"},',
            '{"trait_type":"Level","value":"', charAttributes.characterLevel.toString(), '"},',
            '{"trait_type":"Thirst","value":"', charAttributes.thirst.toString(), '"}'
        ));

        // Combine parts
        string memory finalJson = string(abi.encodePacked(jsonPart1, attributesJson, "]}"));

        // Base64 encode
        string memory encodedJson = Base64.encode(bytes(finalJson));

        return string(abi.encodePacked("data:application/json;base64,", encodedJson));
    }
}
