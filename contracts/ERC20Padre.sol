// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title ERC-20 Padre para heredar funcionalidad base
contract ERC20Padre {
    // ======= ERC-20 metadata =======
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    // ======= Estado =======
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // ======= Eventos =======
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // ======= Constructor =======
    constructor(string memory name_, string memory symbol_, uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }

    // ======= Funciones de información (Getters) =======
    function name() public view returns (string memory) { 
        return _name; 
    }
    
    function symbol() public view returns (string memory) { 
        return _symbol; 
    }
    
    function decimals() public view returns (uint8) { 
        return _decimals; 
    }
    
    function totalSupply() public view returns (uint256) { 
        return _totalSupply; 
    }
    
    function balanceOf(address account) public view returns (uint256) { 
        return _balances[account]; 
    }

    // ======= Funciones de movimiento =======
    function transfer(address to, uint256 amount) public returns (bool) {
        require(to != address(0), "ERC20: envio a la direccion cero");
        require(_balances[msg.sender] >= amount, "ERC20: saldo insuficiente");

        _balances[msg.sender] -= amount;
        _balances[to] += amount;
        
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        require(spender != address(0), "ERC20: aprobacion a la direccion cero");

        _allowances[msg.sender][spender] = amount;
        
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        require(from != address(0), "ERC20: envio desde la direccion cero");
        require(to != address(0), "ERC20: envio a la direccion cero");
        require(_balances[from] >= amount, "ERC20: saldo insuficiente");
        require(_allowances[from][msg.sender] >= amount, "ERC20: permiso insuficiente");

        _balances[from] -= amount;
        _balances[to] += amount;
        _allowances[from][msg.sender] -= amount;

        emit Transfer(from, to, amount);
        return true;
    }

    // ======= Funciones internas para el Hijo (Mint/Burn) =======
    // Estas funciones permiten al contrato hijo modificar los saldos sin romper la encapsulacion private
    
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint a la direccion cero");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn desde la direccion cero");
        require(_balances[account] >= amount, "ERC20: cantidad de burn excede el saldo");

        _balances[account] -= amount;
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }
}