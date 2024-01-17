// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.2;
import "hardhat/console.sol";
// import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import {IERC721Receiver} from '@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol';
import './NFT.sol';
import './Token.sol';
// 编写一个市场合约:使用自己发行的ERC20 Token 来买卖NFT:
// NFT 持有者可上架 NFT(list 设置价格 多少个 TOKEN 购买 NFT )
//编写购买NFT 方法 buyNFT(uint tokenID, uint amount),转入对应的TOKEN,获取对应的 NFT
contract NFTMarket is IERC721Receiver, onTokenRecived {
  address public owner;
  address public erc20TokenAddress;
  struct NftItemListed {
    address seller;
    uint price;
  }
  mapping (address => mapping (address => uint)) nftWhoLost;
  error NotOwner();
  error NotList();
  modifier isOwner(address nftContract, uint tokenId) {
    if(NFT(nftContract).ownerOf(tokenId) != msg.sender){
      revert NotOwner();
    }
    _;
  }
  mapping (address => mapping (uint => NftItemListed)) public nftsListed ;
  constructor (address _erc20TokenAddress) {
    owner = msg.sender;
    erc20TokenAddress = _erc20TokenAddress;
  }
  function buyNFT(address nftAddress, uint tokenId) public {
    if(nftsListed[nftAddress][tokenId].price == 0) {
      revert NotList();
    }
    NftItemListed memory targetList = nftsListed[nftAddress][tokenId];
    Token(erc20TokenAddress).transferFromSafe(msg.sender, targetList.seller, targetList.price, abi.encode(nftAddress, tokenId ));
    NFT(nftAddress).safeTransferFrom(address(this), msg.sender, tokenId, abi.encode(nftAddress));
    // NFT(nftAddress).transferFrom(msg.sender, owner, _tokenID);
    delete nftsListed[nftAddress][tokenId];
  }

  function listNFT (address nftAddress, uint nftTokenId, uint erc20TokenAmount) isOwner(nftAddress, nftTokenId) external returns(bool)  {
    require(NFT(nftAddress).getApproved(nftTokenId) == address(this), 'not approved');
    NFT(nftAddress).safeTransferFrom(msg.sender, address(this),nftTokenId, abi.encode(nftAddress));
    NftItemListed memory newNftItem;
    newNftItem.seller = msg.sender;
    newNftItem.price = erc20TokenAmount;
    nftsListed[nftAddress][nftTokenId] = newNftItem;
    return true;
  }
  function deListNFT (address nftAddress, uint tokenId) external {
    NftItemListed memory targetNftList = nftsListed[nftAddress][tokenId];
    require(targetNftList.seller == msg.sender, 'not the owner');
    NFT(nftAddress).safeTransferFrom(address(this), targetNftList.seller, tokenId);
    delete nftsListed[nftAddress][tokenId];
  }
  function onERC721Received( address operator,
        address from,
        uint256 tokenId,
        bytes calldata data) external returns (bytes4) {
    // buyNFT(from, tokenId);
    address nftAddress = abi.decode(data, (address));
    nftWhoLost[nftAddress][from] = tokenId;
    return IERC721Receiver.onERC721Received.selector;
  }
  function tokenRecived(address buyer, uint amount, bytes calldata data)  external returns(bool) {
    (address nftAddress, uint tokenId) = abi.decode(data, (address, uint));
    NFT(nftAddress).safeTransferFrom(address(this), buyer, tokenId, abi.encode(nftAddress));
    // NFT(nftAddress).transferFrom(msg.sender, owner, _tokenID);
    delete nftsListed[nftAddress][tokenId];
    return true;
  }
  function getSeller (address nftAddress, uint tokenId) public view returns(address) {
    return nftsListed[nftAddress][tokenId].seller;
  }
}
