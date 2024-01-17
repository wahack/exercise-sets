// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "forge-std/Test.sol";
import { NFTMarket } from "../contracts/NftMarket.sol";
import  { NFT } from "../contracts/Nft.sol";
import { Token } from "../contracts/Token.sol";
import {console2} from "forge-std/console2.sol";


contract NftMarketTest is Test {
  NFTMarket market;
  Token erc20Token;
  NFT nftToken;
  address admin = makeAddr('admin');
  address alice = makeAddr('alice');
  address bob = makeAddr('bob');
  mapping(address => uint) public usersNft;


  function setUp() public {
    deal(admin, 1 ether);
    deal(alice, 1 ether);
    deal(bob, 1 ether);
    vm.startPrank(admin);
    {
      erc20Token = new Token('ETHAN', 'ET', 18, 1000 ether);
      erc20Token.transfer(alice, 10 ether);
      erc20Token.transfer(bob, 10 ether);
    }
    {
      nftToken = new NFT();
      usersNft[bob] = nftToken.mint(bob, 'ipfs://111111');
      usersNft[alice] = nftToken.mint(alice, 'ipfs://111111');
    }
    {
      market = new NFTMarket(address(erc20Token));
    }
    vm.stopPrank();
  }


  function test_listNFT() public {
    vm.startPrank(alice);
    // vm.expect('not approved');

    // market.listNFT(address(nftToken), usersNft[alice], 1 ether);
    nftToken.approve(address(market), usersNft[alice]);

    market.listNFT(address(nftToken), usersNft[alice], 1 ether);

    assertEq(nftToken.ownerOf(usersNft[alice]), address(market));
    // assertEq(market.owner(), address(this));
    // assertEq(market.token(), address(0));
    assertEq(market.getSeller(address(nftToken), usersNft[alice]), alice);

    vm.stopPrank();
  }

  function test_buyNft() public {
    
    {
      // alice list nft
      vm.startPrank(alice);
      nftToken.approve(address(market), usersNft[alice]);
      market.listNFT(address(nftToken), usersNft[alice], 1 ether);
      vm.stopPrank();
    }
    {
      // bob buy nft
      vm.startPrank(bob);
      erc20Token.approve(alice, 1 ether);
      market.buyNFT(address(nftToken), usersNft[alice]);
      assertEq(nftToken.ownerOf(usersNft[alice]), bob);
      assertEq(erc20Token.balanceOf(alice), 11 ether);
      assertEq(market.getSeller(address(nftToken), usersNft[alice]), address(0));
      vm.stopPrank();
    }
  }
}
