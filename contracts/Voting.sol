// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SDAOToken.sol";
import "./Governance.sol";

contract Voting {
    enum ProposalStatus {Pending, Passed, Failed}
    struct Proposal {
        address
    proposer;
    string description;
    uint256 yesVotes;
    uint256 noVotes;
    uint256 totalVotes;
    uint256 votingDeadline;
    ProposalStatus status;
    mapping(address => bool) voted;
}

SDAOToken public sdaoToken;
Governance public governance;
uint256 public constant VOTING_PERIOD = 7 days;

Proposal[] public proposals;

event ProposalAdded(uint256 proposalId, address indexed proposer, string description);
event Voted(uint256 proposalId, address indexed voter, bool position, uint256 votes);
event ProposalExecuted(uint256 proposalId, uint256 yesVotes, uint256 noVotes, uint256 totalVotes);

constructor(SDAOToken _sdaoToken, Governance _governance) {
    sdaoToken = _sdaoToken;
    governance = _governance;
}

function propose(string memory _description) public {
    require(sdaoToken.balanceOf(msg.sender) > 0, "Must have SDAO balance to propose");
    Proposal memory newProposal = Proposal({
        proposer: msg.sender,
        description: _description,
        yesVotes: 0,
        noVotes: 0,
        totalVotes: 0,
        votingDeadline: block.timestamp + VOTING_PERIOD,
        status: ProposalStatus.Pending
    });
    proposals.push(newProposal);
    emit ProposalAdded(proposals.length - 1, msg.sender, _description);
}

function vote(uint256 _proposalId, bool _position) public {
    Proposal storage proposal = proposals[_proposalId];
    require(proposal.votingDeadline >= block.timestamp, "Voting period has ended");
    require(!proposal.voted[msg.sender], "Already voted");
    uint256 votingPower = governance.votingPower(msg.sender);
    require(votingPower > 0, "Must have locked SDAO to vote");
    proposal.voted[msg.sender] = true;
    proposal.totalVotes += votingPower;
    if (_position) {
        proposal.yesVotes += votingPower;
    } else {
        proposal.noVotes += votingPower;
    }
    emit Voted(_proposalId, msg.sender, _position, votingPower);
}

function executeProposal(uint256 _proposalId) public {
    Proposal storage proposal = proposals[_proposalId];
    require(proposal.votingDeadline < block.timestamp, "Voting period has not ended");
    require(proposal.status == ProposalStatus.Pending, "Proposal has already been executed");
    if (proposal.yesVotes > proposal.noVotes) {
        // Proposal passed
        proposal.status = ProposalStatus.Passed;
        // Execute proposal here
    } else {
        // Proposal failed
        proposal.status = ProposalStatus.Failed;
    }
    emit ProposalExecuted(_proposalId, proposal.yesVotes, proposal.noVotes, proposal.totalVotes);
}
}