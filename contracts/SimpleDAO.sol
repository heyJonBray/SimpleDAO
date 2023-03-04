// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SDAOToken.sol";
import "./Governance.sol";
import "./SDAOStaking.sol";

contract SimpleDAO {
    SDAOToken public sdaoToken;
    Governance public governance;
    SDAOStaking public staking;

    constructor() {
        sdaoToken = new SDAOToken();
        governance = new Governance(sdaoToken);
        staking = new SDAOStaking(sdaoToken);
        sdaoToken.transferOwnership(address(governance));
    }
}
