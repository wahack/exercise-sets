// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.2;
import "hardhat/console.sol";
import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import './NFT.sol';
import './Token.sol';
// 编写一个市场合约:使用自己发行的ERC20 Token 来买卖NFT:
// NFT 持有者可上架 NFT(list 设置价格 多少个 TOKEN 购买 NFT )
//编写购买NFT 方法 buyNFT(uint tokenID, uint amount),转入对应的TOKEN,获取对应的 NFT

contract NFTMarket {
  address public owner;
  address public erc20TokenAddress;
  struct NftItem {
    address seller;
    uint price;
    uint tokenId;
    address nftContract;
  }
  NftItem[] public nftList;
  constructor (address _erc20TokenAddress) {
    owner = msg.sender;
    erc20TokenAddress = _erc20TokenAddress;
  }
  function buyNFT(uint listingId) external {
    require(listingId < nftList.length, 'not exist');
    NftItem memory targetList = nftList[listingId];
    Token(erc20TokenAddress).transferFrom(msg.sender, address(this), targetList.price);
    NFT(targetList.nftContract).safeTransferFrom(address(this), msg.sender, targetList.tokenId);
    // NFT(nftAddress).transferFrom(msg.sender, owner, _tokenID);
    delete nftList[listingId];
  }
  function listNFT (address nftAddress, uint nftTokenId, uint erc20TokenAmount) external  {
    require(NFT(nftAddress).ownerOf(nftTokenId) == msg.sender, 'not the owner');
    NFT(nftAddress).safeTransferFrom(msg.sender, address(this), nftTokenId);
    NftItem memory newNftList;
    newNftList.tokenId = nftTokenId;
    newNftList.seller = msg.sender;
    newNftList.price = erc20TokenAmount;
    newNftList.nftContract = nftAddress;
    nftList.push(newNftList);
  }
  function deListNFT (uint listingId) external {
    NftItem memory targetNftList = nftList[listingId];
    NFT(targetNftList.nftContract).safeTransferFrom(address(this), targetNftList.seller, targetNftList.tokenId);
    delete nftList[listingId];
  }
}
