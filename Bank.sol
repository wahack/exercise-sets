// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Bank {
    mapping (address => uint) balance;
    address owner;
    uint total = 0;
    address[] topThree;
    constructor() payable {
        owner = msg.sender;
        total = msg.value;
    }
    receive() external payable {
        if (balance[msg.sender] > 0) {
            balance[msg.sender] = balance[msg.sender] + msg.value;
        } else {
            balance[msg.sender] = msg.value;
        }
        total = total + msg.value;
        if (isSenderRepeat(msg.sender)) return;
        if (topThree.length < 3) {
            topThree.push(msg.sender);
        } else {
            uint min = balance[topThree[0]];
            uint minIndex = 0;
            for (uint i = 1; i < topThree.length; i++) {
                if (balance[topThree[i]] < min) {
                    min = balance[topThree[i]];
                    minIndex = i;
                }
            }
            if (msg.value > min) {
                topThree[minIndex] = msg.sender;
            }
        }

    }
    function isSenderRepeat (address sender) internal view returns (bool) {
        for (uint i = 0; i < topThree.length; i++) {
            if (topThree[i] == sender) {
                return true;
            }
        }
        return false;
    }
    function withdraw (uint amountOut) public payable  {
        require(msg.sender == owner && amountOut <= total);
        payable (owner).transfer(amountOut);
    }
}