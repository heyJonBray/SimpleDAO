// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SDAOToken.sol";

contract SDAOStaking {
    struct Stake {
        uint256 amount;
        uint256 lockTime;
        bool position; // true for "Yes", false for "No"
    }

    SDAOToken public sdaoToken;

    mapping(address => Stake[]) public stakes;

    constructor(SDAOToken _sdaoToken) {
        sdaoToken = _sdaoToken;
    }

    function stake(uint256 _amount, bool _position) public {
        require(sdaoToken.balanceOf(msg.sender) >= _amount, "Insufficient SDAO balance");
        require(sdaoToken.allowance(msg.sender, address(this)) >= _amount, "Must approve SDAO before staking");
        sdaoToken.transferFrom(msg.sender, address(this), _amount);
        stakes[msg.sender].push(Stake({
            amount: _amount,
            lockTime: block.timestamp + 7 days,
            position: _position
        }));
    }

    function unstake(uint256 _index) public {
        Stake storage stake = stakes[msg.sender][_index];
        require(stake.lockTime < block.timestamp, "Stake is still locked");
        sdaoToken.transfer(msg.sender, stake.amount);
        stake.amount = 0;
    }

    function votingPower(address _user) public view returns (uint256) {
        uint256 power = 0;
        for (uint256 i = 0; i < stakes[_user].length; i++) {
            if (stakes[_user][i].lockTime > block.timestamp) {
                power += stakes[_user][i].amount;
            }
        }
        return power;
    }
}
