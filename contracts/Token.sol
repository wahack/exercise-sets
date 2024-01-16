// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;
import "hardhat/console.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import "@openzeppelin/contracts/utils/Address.sol";


interface  onTokenRecived {
    function tokenRecived(address from, uint256 amount) external returns (bool);
}


interface ERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8); // 小数位数

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


contract Token is ERC20 {
    string public override name;
    string public override symbol;
    uint8 public override decimals;
    uint256 public override totalSupply;
    mapping(address => uint256) public  _balanceOf;
    mapping(address => mapping(address => uint256)) public override allowance;

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _totalSupply
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply;
        _balanceOf[msg.sender] = _totalSupply;
    }

    function transfer(address to, uint256 amount)
        external
        override
        returns (bool)
    {
        require(_balanceOf[msg.sender] >= amount, "Not enough balance");
        _balanceOf[msg.sender] -= amount;
        _balanceOf[to] += amount;
         if (isContract(to)) {
            onTokenRecived(to).tokenRecived(msg.sender, amount);
        }
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount)
        external
        override
        returns (bool)
    {
        allowance[msg.sender][spender] = amount;
        console.log('approve:', msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {        
        require(allowance[from][msg.sender] >= amount, "Not enough allowance");
        require(_balanceOf[from] >= amount, "Not enough balance");
        _balanceOf[from] -= amount;
        _balanceOf[to] += amount;
        allowance[from][to] -= amount;
        emit Transfer(from, to, amount);
        return true;
    }
    function balanceOf(address account) external view override returns (uint256){
        return _balanceOf[account];
    }
    function isContract(address _addr) public view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }
}