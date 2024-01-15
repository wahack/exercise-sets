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
  address public nftAddress;
  address public erc20TokenAddress;
  mapping (uint => uint) nftList; // nft 列表， nftId => price
  constructor (address _nftAddress, address _erc20TokenAddress) {
    owner = msg.sender;
    nftAddress = _nftAddress;
    erc20TokenAddress = _erc20TokenAddress;
  }
  function buyNFT(uint _tokenID, uint _amount) external {
    require(nftList[_tokenID] <= _amount, 'price not match');
    Token(erc20TokenAddress).transferFrom(msg.sender, address(this), _amount);
    NFT(nftAddress).safeTransferFrom(address(this), msg.sender, _tokenID);
    // NFT(nftAddress).transferFrom(msg.sender, owner, _tokenID);
  }
  function listNFT (uint nftTokenId, uint erc20TokenAmount) external {
    // NFT).approve(address(this), erc20TokenAmount);
    NFT(nftAddress).safeTransferFrom(msg.sender, address(this), nftTokenId);
    nftList[nftTokenId] = erc20TokenAmount;
  }
}
