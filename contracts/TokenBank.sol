// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;
import "hardhat/console.sol";

interface ERC20 {
  function transfer(address to, uint amount) external returns(bool);
  function transferFrom(address from, address to, uint amount) external returns(bool);
  function approve(address spender, uint amount) external returns(bool);
}

contract TokenBank {
  mapping (address => uint256) public balanceOf;
  address tokenAddress;
  address public erc20TokenAddress;
  address public owner;
  modifier onlyOwner() {
    require(msg.sender == owner, 'not the owner');
    _;
    
  }
  constructor (address _erc20TokenAddress){
    erc20TokenAddress = _erc20TokenAddress;
    owner = msg.sender;
  }
  function deposite (uint value) public{
    // (bool transformSuccess,) = erc20TokenAddress.call(abi.encodeWithSignature("transferFrom(address,address,uint256)",msg.sender, address(this), value));
    // require(transformSuccess, 'transform failed');
    ERC20(erc20TokenAddress).transferFrom(msg.sender, address(this), value);
    balanceOf[msg.sender] += value;
  }
  function withdraw (uint value) onlyOwner public {
    ERC20(erc20TokenAddress).transfer(owner, value);
  }

}