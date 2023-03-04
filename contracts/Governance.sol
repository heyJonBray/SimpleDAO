// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SDAOToken.sol";

contract Governance {
    SDAOToken public sdaoToken;
    mapping(address => uint256) public votingPower;

    event LockedSDAO(address indexed user, uint256 amount, uint256 votingPower);
    event UnlockedSDAO(address indexed user, uint256 amount, uint256 votingPower);

    constructor(SDAOToken _sdaoToken) {
        sdaoToken = _sdaoToken;
    }

    function lockSDAO(uint256 _amount) public {
        require(_amount > 0, "Amount must be greater than 0");
        sdaoToken.transferFrom(msg.sender, address(this), _amount);
        votingPower[msg.sender] += _amount;
        emit LockedSDAO(msg.sender, _amount, votingPower[msg.sender]);
    }

    function unlockSDAO(uint256 _amount) public {
        require(votingPower[msg.sender] >= _amount, "Not enough locked SDAO");
        votingPower[msg.sender] -= _amount;
        sdaoToken.transfer(msg.sender, _amount);
        emit UnlockedSDAO(msg.sender, _amount, votingPower[msg.sender]);
    }
}
