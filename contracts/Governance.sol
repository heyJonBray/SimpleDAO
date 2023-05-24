// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';

contract Governance is Ownable {
  enum VoteStatus {
    None,
    Yes,
    No
  }
  struct Proposal {
    uint256 id; // Unique identifier for the proposal
    uint256 creationTime; // Timestamp when the proposal was created
    uint256 expirationTime; // Timestamp when the proposal expires
    uint256 yesVotes; // Number of "yes" votes received
    uint256 noVotes; // Number of "no" votes received
    uint256 voteCount; // Total number of votes casted
    address proposer; // Address of the proposer
    bool executed; // Flag indicating if the proposal has been executed
    bool passed; // Flag indicating if the proposal has passed
    bool isActive; // Flag indicating if the proposal is active for voting or not
    string ipfsHash; // IPFS content hash of the proposal details
    mapping(address => VoteStatus) votes; // Mapping to track vote status by address
  }

  mapping(uint256 => Proposal) public proposals;
  uint256 public proposalCount;
  uint8 public voteThreshold;

  // Events
  event ProposalCreated(
    uint256 indexed id,
    address indexed proposer,
    string ipfsHash,
    uint256 expirationTime
  );

  event ProposalExpirationTimeSet(
    uint256 indexed proposalId,
    uint256 expirationTime
  );
  event VoteCast(
    uint256 indexed proposalId,
    address indexed voter,
    bool support
  );
  event ProposalExecuted(uint256 indexed proposalId, address indexed executor);

  constructor(uint8 initialVoteThreshold) {
    proposalCount = 0;
    voteThreshold = 51;
  }

  /**
   * @dev Creates a new proposal with the given IPFS hash and expiration time.
   * If no expiration time is provided, the default is set to 14 days.
   * Emits a `ProposalCreated` event with the details of the newly created proposal.
   * @param ipfsHash The IPFS content hash of the proposal details.
   * @param expirationTimeInDays The expiration time of the proposal in days (optional).
   */

  function createProposal(
    string memory ipfsHash,
    uint256 expirationTimeInDays
  ) public {
    // If expiration time is not provided, default to 14 days
    uint256 actualExpirationTime = expirationTimeInDays > 0
      ? expirationTimeInDays * 1 days
      : 14 days;

    Proposal storage newProposal = proposals[proposalCount];
    newProposal.id = proposalCount;
    newProposal.creationTime = block.timestamp;
    newProposal.expirationTime = actualExpirationTime;
    newProposal.yesVotes = 0;
    newProposal.noVotes = 0;
    newProposal.voteCount = 0;
    newProposal.proposer = msg.sender;
    newProposal.executed = false;
    newProposal.passed = false;
    newProposal.isActive = true;
    newProposal.ipfsHash = ipfsHash;

    proposalCount++;

    emit ProposalCreated(
      proposalCount,
      msg.sender,
      ipfsHash,
      actualExpirationTime
    );
  }

  /**
   * @dev Set the expiration time of a proposal by its ID, for the owner only.
   * @param proposalId The ID of the proposal.
   * @param expirationTime The new expiration time in hours.
   */
  function setProposalExpirationTime(
    uint256 proposalId,
    uint256 expirationTime
  ) public onlyOwner {
    require(proposalId < proposalCount, 'Invalid proposal ID');

    Proposal storage proposal = proposals[proposalId];
    require(proposal.isActive, 'Proposal is not active');

    proposal.expirationTime = expirationTime;

    emit ProposalExpirationTimeSet(proposalId, expirationTime);
  }

  function vote(uint256 proposalId, bool support) public {
    require(
      proposalId > 0 && proposalId <= proposalCount,
      'Invalid proposal ID'
    );

    Proposal storage proposal = proposals[proposalId];
    require(!proposal.executed, 'Proposal has already been executed');

    // Perform voting logic and update the vote count
    if (support) {
      proposal.yesVotes++;
    } else {
      proposal.noVotes++;
    }

    emit VoteCast(proposalId, msg.sender, support);
  }

  function executeProposal(uint256 proposalId) public onlyOwner {
    require(
      proposalId > 0 && proposalId <= proposalCount,
      'Invalid proposal ID'
    );

    Proposal storage proposal = proposals[proposalId];
    require(!proposal.executed, 'Proposal has already been executed');
    require(proposal.passed, 'Proposal has not been passed');

    // Execute the proposal actions or changes here
    // ...

    // Mark the proposal as executed
    proposal.executed = true;

    emit ProposalExecuted(proposalId, msg.sender);
  }

  /**
   * @dev Get the total number of proposals created.
   */
  function getProposalCount() public view returns (uint256) {
    return proposalCount;
  }

  /**
   * @dev Retrieves the details of a proposal by its ID.
   * @param proposalId The ID of the proposal to fetch.
   * @return id The ID of the proposal.
   * @return proposer The address of the proposer.
   * @return ipfsHash The IPFS content hash of the proposal details.
   * @return yesVotes The number of "yes" votes received by the proposal.
   * @return noVotes The number of "no" votes received by the proposal.
   * @return voteCount The total count of votes received by the proposal.
   * @return executed A flag indicating whether the proposal has been executed.
   * @return passed A flag indicating whether the proposal has passed.
   */
  function getProposalDetails(
    uint256 proposalId
  )
    public
    view
    returns (
      uint256 id,
      address proposer,
      string memory ipfsHash,
      uint256 yesVotes,
      uint256 noVotes,
      uint256 voteCount,
      bool executed,
      bool passed
    )
  {
    require(proposalId < proposalCount, 'Invalid proposal ID');

    Proposal storage proposal = proposals[proposalId];
    id = proposal.id;
    proposer = proposal.proposer;
    ipfsHash = proposal.ipfsHash;
    yesVotes = proposal.yesVotes;
    noVotes = proposal.noVotes;
    voteCount = proposal.voteCount;
    executed = proposal.executed;
    passed = proposal.passed;
  }

  /**
   * @dev Get the total number of votes cast for a specific proposal.
   * @param proposalId The ID of the proposal.
   */
  function getProposalVoteCount(
    uint256 proposalId
  ) public view returns (uint256) {
    require(proposalId < proposalCount, 'Invalid proposal ID');
    return proposals[proposalId].voteCount;
  }

  /**
   * @dev Get the vote status (yes or no) of a specific voter for a given proposal.
   * @param proposalId The ID of the proposal.
   * @param voter The address of the voter.
   */
  function getProposalVoteStatus(
    uint256 proposalId,
    address voter
  ) public view returns (VoteStatus) {
    require(proposalId < proposalCount, 'Invalid proposal ID');
    require(voter != address(0), 'Invalid voter address');

    return proposals[proposalId].votes[voter];
  }

  /**
   * @dev Check if a proposal has been executed.
   * @param proposalId The ID of the proposal.
   */
  function getProposalExecutionStatus(
    uint256 proposalId
  ) public view returns (bool) {
    require(proposalId < proposalCount, 'Invalid proposal ID');
    return proposals[proposalId].executed;
  }

  /**
   * @dev Check if a proposal has passed.
   * @param proposalId The ID of the proposal.
   */
  function getProposalPassedStatus(
    uint256 proposalId
  ) public view returns (bool) {
    require(proposalId < proposalCount, 'Invalid proposal ID');
    return proposals[proposalId].passed;
  }

  /**
   * @dev Toggle the active state of a proposal for review by the DAO admin (Owner).
   * @param proposalId The ID of the proposal to be toggled.
   * @param isActive The desired active state of the proposal.
   */
  function toggleProposalActiveState(
    uint256 proposalId,
    bool isActive
  ) public onlyOwner {
    require(proposalId < proposalCount, 'Invalid proposal ID');
    Proposal storage proposal = proposals[proposalId];
    require(!proposal.executed, 'Proposal already executed');
    proposal.isActive = isActive;
  }

  /**
   * @dev Update the IPFS content hash of a proposal after it has been created but before it is executed.
   * @param proposalId The ID of the proposal.
   * @param ipfsHash The new IPFS content hash.
   */
  function updateProposal(uint256 proposalId, string memory ipfsHash) public {
    require(proposalId < proposalCount, 'Invalid proposal ID');
    require(bytes(ipfsHash).length > 0, 'Invalid IPFS hash');
    Proposal storage proposal = proposals[proposalId];
    require(!proposal.executed, 'Proposal already executed');
    proposal.ipfsHash = ipfsHash;
  }

  /**
   * @dev Get the total number of yes votes for a specific proposal.
   * @param proposalId The ID of the proposal.
   */
  function getTotalYesVotes(uint256 proposalId) public view returns (uint256) {
    require(proposalId < proposalCount, 'Invalid proposal ID');
    return proposals[proposalId].yesVotes;
  }

  /**
   * @dev Get the total number of no votes for a specific proposal.
   * @param proposalId The ID of the proposal.
   */
  function getTotalNoVotes(uint256 proposalId) public view returns (uint256) {
    require(proposalId < proposalCount, 'Invalid proposal ID');
    return proposals[proposalId].noVotes;
  }

  /**
   * @dev Check if a proposal has expired based on a defined time limit.
   * @param proposalId The ID of the proposal.
   */
  function isProposalExpired(uint256 proposalId) public view returns (bool) {
    require(proposalId < proposalCount, 'Invalid proposal ID');
    Proposal storage proposal = proposals[proposalId];
    return block.timestamp >= proposal.creationTime + proposal.expirationTime;
  }

  /**
   * @dev Get the minimum number of votes required for a proposal to pass.
   */
  function getVoteThreshold() public view returns (uint8) {
    return voteThreshold;
  }

  /**
   * @dev Updates the vote threshold required for a proposal to pass.
   * @param newThreshold The new vote threshold value to be set.
   * Requirements:
   * - The function can only be called by the contract owner.
   */
  function updateVoteThreshold(uint8 newThreshold) public onlyOwner {
    voteThreshold = newThreshold;
  }
}
