// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.2;

import "hardhat/console.sol";
import '@openzeppelin/contracts/token/ERC721/ERC721.sol';

contract NFT is ERC721 {
  uint private _tokenIds;
  mapping(uint => string) public _tokenURIs;
  constructor () ERC721("ETHAN", "ET") {

  }
  function mint(address to, string memory uri) public returns (uint256) {
    _tokenIds++;
    _safeMint(to, _tokenIds);
    _tokenURIs[_tokenIds] = uri;
    return _tokenIds;
  }
  function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
    return _tokenURIs[tokenId];
  }
}