// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SystemCard is ERC721, Ownable {
    uint256 public nextTokenId;
    mapping(uint256 => string) private _tokenURIs;
    mapping(uint256 => string) public tokenColors;

    enum Rarity { Common, Rare, Unique, Legacy, Divine }
    Rarity[] public rarities;

    // Define colors for each rarity
    string[] public colors = ["White", "Green", "Blue", "Purple", "Gold"];

    constructor() ERC721("SystemCard", "SCARD") {}

    function mintCard(address to, string memory tokenURI, Rarity rarity) external onlyOwner {
        uint256 tokenId = nextTokenId;
        _mint(to, tokenId);
        _setTokenURI(tokenId, tokenURI);

        // Set the color based on the rarity
        tokenColors[tokenId] = colors[uint256(rarity)];
        rarities.push(rarity);
        
        nextTokenId++;
    }

    function _setTokenURI(uint256 tokenId, string memory tokenURI) internal {
        _tokenURIs[tokenId] = tokenURI;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return _tokenURIs[tokenId];
    }

    function getColor(uint256 tokenId) public view returns (string memory) {
        return tokenColors[tokenId];
    }
}
