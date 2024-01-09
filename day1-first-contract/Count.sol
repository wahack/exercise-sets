pragma solidity >=0.8.2 <0.9.0;

contract Counter {

    uint256 total;

    constructor () {
        total = 0;
    }
    function add(uint256 num) public {
        total = total + num;
    }
}