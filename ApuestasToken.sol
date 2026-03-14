// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "contracts/ERC20Padre.sol";

contract ApuestasToken is ERC20Padre {
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 initialSupply_
    ) ERC20Padre(name_, symbol_, decimals_) {
        owner = msg.sender;
        // El hijo usa la funcion interna para crear el supply inicial
        _mint(msg.sender, initialSupply_);
    }

    function ownerMint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    function ownerBurn(address from, uint256 amount) external onlyOwner {
        _burn(from, amount);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Zero address");
        owner = newOwner;
    }
}