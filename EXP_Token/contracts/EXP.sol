// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./Soulbound_ERC20_Updated.sol";
import "./CustomOwnable.sol";

// Code is heavily inspired by below github
// https://github.com/kethcode/exp
// This is basically a learning experience for me - SolDev-HP

// Why revert error and why not require? May be gas optimization purposes? Need to check. 
// @Todo Check gas estimations of both methods 
error NotAllowed();
error InsuffBal();

contract EXP is ERC20, CustomOwnable {
    // So we have set of admin addresses that can mint, burn tokens
    // First admin would be the contract initiator and is able to add
    // other admins 
    // mapping(Address is admin => True/False)
    mapping(address => bool) public tokenAdmins;

    // Emits and event whenever token admin is set 
    event TokenAdminSet(address indexed _admin, bool indexed adminSet);

    constructor(string memory _name, string memory _symbol, uint8 _decimals) ERC20(_name, _symbol, _decimals) {
        // Setting the first admin of the contract 
        tokenAdmins[msg.sender] = true;
    }

    // Now let's see who can mint and burn 
    // Super admin only can set/unset admins 
    function setApprovedMinter(address _adminAddress, bool _adminSet) public {
        if(msg.sender != owner()) revert NotAllowed();
        tokenAdmins[_adminAddress] = _adminSet;
        emit TokenAdminSet(_adminAddress, _adminSet);
    }

    function mint(address _mintTo, uint _value) public {
        if(tokenAdmins[msg.sender] == false) revert NotAllowed();
        _mint(_mintTo, _value);
    }

    function burn(address _burnFrom, uint _value) public {
        if(tokenAdmins[msg.sender] == false && msg.sender != _burnFrom) revert NotAllowed();
        if(balanceOf[_burnFrom] < _value) revert InsuffBal();
        _burn(_burnFrom, _value);
    }
}