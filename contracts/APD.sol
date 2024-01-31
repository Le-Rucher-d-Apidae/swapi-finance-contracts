// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
// import "@openzeppelin/contracts/access/AccessControl.sol";
// import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

// alias openzeppelin/contracts@5.0.1
import "@openzeppelin/contracts-5.0.1/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts-5.0.1/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts-5.0.1/access/AccessControl.sol";
import "@openzeppelin/contracts-5.0.1/token/ERC20/extensions/ERC20Permit.sol";


contract APD is ERC20, ERC20Burnable, AccessControl, ERC20Permit {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor(address defaultAdmin, address minter)
        ERC20("APIDAE01", "APD01")
        ERC20Permit("APIDAE01")
    {
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(MINTER_ROLE, minter);
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }
}