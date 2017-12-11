pragma solidity ^0.4.0;

import "browser/Token.sol";
import "browser/ERC20.sol";
import "browser/ERC223.sol";
import "browser/ERC223ReceivingContract.sol";

contract ERCTokenIOT is ERC20, ERC223 {
    string public constant acronym = 'IOT';
    string public constant tokenName = 'Internet of Things Token';
    uint public constant decimals = 18; // 1 wei min
    
    uint private totalTokenSupply = 1000;
    
    mapping(address => uint) private balances; // balance is a keyword. balance(s) is not
    mapping(address => mapping(address => uint)) private allowances;
    
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
    
    // Constructor
    function ERCTokenIOT() {
        balances[msg.sender] = totalTokenSupply;
    }
    // ERC20 asbstract def
    function totalSupply() constant returns (uint _totalSupply) {
      _totalSupply = totalTokenSupply;
    }
    
    function balanceOf(address _owner) constant returns (uint balance) {
        return balances[_owner];
    }
    
    function transfer(address _to, uint _value) returns (bool success) {
        if (_value > 0 && _value <= balances[msg.sender]) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        }
        return false;
    }
    
    function transfer(address _to, uint _value, bytes _data) public returns (bool) {
        if (_value > 0 && 
            _value <= balances[msg.sender] &&
            isContract(_to)) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            ERC223ReceivingContract _contract = ERC223ReceivingContract(_to);
                _contract.tokenFallback(msg.sender, _value, _data);
            Transfer(msg.sender, _to, _value, _data);
            return true;
        }
        return false;
    }

    
    function transferFrom(address _from, address _to, uint _value) returns (bool success) {
        if (allowances[_from][msg.sender] > 0 &&
            _value > 0 &&
            allowances[_from][msg.sender] >= _value) {
            balances[_from] -= _value;
            balances[_to] += _value;
            allowances[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        }
        return false;
    }
    
    function isContract(address _addr) returns (bool) {
        uint codeSize;
        assembly {
            codeSize := extcodesize(_addr)
        }
        return codeSize > 0;
    }
    
    function approve(address _spender, uint _value) returns (bool success) {
        allowances[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function allowance(address _owner, address _spender) constant returns (uint remaining) {
        return allowances[_owner][_spender];
    }


}