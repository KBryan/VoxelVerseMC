// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Base64} from "./libraries/Base64.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract VoxelVerseMC is ERC721, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint256;

    IERC20 public tokenAddress;
    uint256 public rate;

    Counters.Counter private _tokenIds;

    struct CharacterAttributes {
        string name;
        string imageURI;
        uint256 happiness;
        uint256 thirst;
        uint256 hunger;
        uint256 xp;
        uint256 daysSurvived;
        uint256 characterLevel;
        uint256 health;
        uint256 heat;
    }

    mapping(uint256 => CharacterAttributes) public nftHolderAttributes;
    mapping(uint256 => bool) private _tokenMinted;
    mapping(address => bool) private _addressHasNFT;

    event CharacterUpdated(uint256 tokenId, CharacterAttributes attributes);
    event CharacterNFTMinted(address indexed recipient, uint256 indexed tokenId, CharacterAttributes attributes);

    constructor(address _tokenAddress) ERC721("VoxelVerseMC", "VVMC") {
        tokenAddress = IERC20(_tokenAddress);
        rate = 10 * 10 ** 18; // Default rate, can be adjusted by the owner
    }

    function setRate(uint256 _rate) public onlyOwner {
        rate = _rate;
    }

    function mintCharacterNFT() public {
        require(!_addressHasNFT[msg.sender], "Address already owns an NFT");
        require(tokenAddress.transferFrom(msg.sender, address(this), rate), "Payment transfer failed");

        uint256 newItemId = _tokenIds.current();
        require(!_tokenMinted[newItemId], "Character already minted");

        CharacterAttributes memory attributes = CharacterAttributes({
            name: getMinterAddressAsString(),
            imageURI: "https://harlequin-leading-egret-2.mypinata.cloud/ipfs/Qmd7NWbw2JdUqnJk7rg1w2X79L36dbrbQ5QbESVzHYt3SH",
            happiness: 50,
            thirst: 100,
            hunger: 100,
            xp: 1,
            daysSurvived: 1,
            characterLevel: 1,
            health: 100,
            heat: 50
        });

        _safeMint(msg.sender, newItemId);
        nftHolderAttributes[newItemId] = attributes;
        _tokenMinted[newItemId] = true;
        _addressHasNFT[msg.sender] = true;

        _tokenIds.increment();

        emit CharacterNFTMinted(msg.sender, newItemId, attributes);
    }

    function getMinterAddressAsString() public view returns (string memory) {
        return addressToString(msg.sender);
    }

    /**
     * @dev Converts an address to a string.
     * @param _addr The address to convert.
     * @return The address as a string.
     */
    function addressToString(address _addr) public pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";
        bytes20 value = bytes20(_addr);
        bytes memory str = new bytes(42); // 2 characters for '0x', and 40 characters for the address
        str[0] = '0';
        str[1] = 'x';
        for (uint256 i = 0; i < 20; i++) {
            str[2 + i * 2] = alphabet[uint256(uint8(value[i] >> 4))];
            str[3 + i * 2] = alphabet[uint256(uint8(value[i] & 0x0f))];
        }
        return string(str);
    }

    function updateCharacterAttributes(uint256 tokenId, CharacterAttributes calldata attributes) external onlyOwner {
        require(_exists(tokenId), "Nonexistent token");
        nftHolderAttributes[tokenId] = attributes;
        emit CharacterUpdated(tokenId, attributes);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        CharacterAttributes memory charAttributes = nftHolderAttributes[tokenId];
        string memory json = Base64.encode(bytes(abi.encodePacked(
            '{"name":"', charAttributes.name, '","description":"This is your beta character in the VoxelVerseMC game!","image":"',
            charAttributes.imageURI, '","attributes":', _formatAttributes(charAttributes), '}'
        )));

        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    function _formatAttributes(CharacterAttributes memory charAttributes) private pure returns (string memory) {
        return string(abi.encodePacked(
            '[', _formatAttribute("Happiness", charAttributes.happiness),
            ',', _formatAttribute("Health", charAttributes.health),
            ',', _formatAttribute("Hunger", charAttributes.hunger),
            ',', _formatAttribute("XP", charAttributes.xp),
            ',', _formatAttribute("Days", charAttributes.daysSurvived),
            ',', _formatAttribute("Level", charAttributes.characterLevel),
            ',', _formatAttribute("Heat", charAttributes.heat),
            ',', _formatAttribute("Thirst", charAttributes.thirst), ']'
        ));
    }

    function _formatAttribute(string memory traitType, uint256 value) private pure returns (string memory) {
        return string(abi.encodePacked('{"trait_type":"', traitType, '","value":', value.toString(), '}'));
    }
}

