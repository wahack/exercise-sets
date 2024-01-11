// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;
import './BigBank.sol';

// interface BigBank {
//   function withdraw(uint amountOut) external; 
// }


contract Ownable {
  address payable public bigBankOwner;
  address public owner;
  constructor (address  ow) {
    owner = msg.sender;
    bigBankOwner = payable(ow);
  }
  function withdraw(uint amountOut) external{
    require(msg.sender == owner, "Not the owner");
    BigBank(bigBankOwner).withdraw(amountOut);
  }
}