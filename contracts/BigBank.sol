// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;
import "hardhat/console.sol";

contract BigBank {
  uint public total;
  address payable public owner;
  address public ownerOriginal;
  constructor () {
    owner = payable(msg.sender);
    ownerOriginal = msg.sender;
  }
  modifier minAmount(uint amount) {
    require(amount > 0.01*10**18, "Not enough ETH sent");
    _;
  }
  function deposite(uint amountIn) private minAmount(amountIn)  {
    total = total + amountIn;
  }
  function withdraw(uint amountOut) external  returns(bool) {
    require(msg.sender == owner, "Not the owner");
    require(total >= amountOut, "Not enough ETH in the contract");

    (bool success, ) = payable(owner).call{value: amountOut}("");
    require(success, "Withdraw failed");
    total -= amountOut;
    return success;
  }
  function transferOwner(address newOwner) external {
    require(msg.sender == owner, "Not the owner");
    owner = payable(newOwner);
  }
  receive() external payable {
    deposite(msg.value);
  }
}