pragma solidity >=0.8.2 <0.9.0;

// 可见行 public private internal external
// 状态可变性 pure（纯计算不读不写状态） view（只读） payable（调用时可以传 eth）
//两个特殊函数： recieve() 有转账时自动被调用  fallback() 尝试调用一个不存在的方法时被调用

contract Counter {

    uint256 total;

    constructor () {
        total = 0;
    }
    function add(uint256 num) public {
        total = total + num;
    }
}