// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title ParkingDAO
 * @dev DAO for community-driven parking governance
 * @notice Drivers can vote on parking rules, fees, and penalties
 */
contract ParkingDAO is AccessControl, ReentrancyGuard {
    
    bytes32 public constant VOTER_ROLE = keccak256("VOTER_ROLE");
    bytes32 public constant PROPOSER_ROLE = keccak256("PROPOSER_ROLE");
    
    // Proposal types
    enum ProposalType {
        FeeChange,
        RuleChange,
        PenaltyChange,
        General
    }
    
    enum ProposalStatus {
        Pending,
        Active,
        Passed,
        Rejected,
        Executed
    }
    
    struct Proposal {
        uint256 id;
        address proposer;
        ProposalType proposalType;
        string title;
        string description;
        uint256 newValue; // For fee/penalty changes
        uint256 votesFor;
        uint256 votesAgainst;
        uint256 startTime;
        uint256 endTime;
        ProposalStatus status;
        bool executed;
        mapping(address => bool) hasVoted;
    }
    
    // State variables
    uint256 private _proposalIdCounter;
    uint256 public votingPeriod = 7 days;
    uint256 public quorumPercentage = 30; // 30% of voters must participate
    uint256 public passingThreshold = 50; // 50% of votes must be in favor
    uint256 public totalVoters;
    
    mapping(uint256 => Proposal) public proposals;
    mapping(address => uint256) public votingPower;
    
    // Events
    event ProposalCreated(
        uint256 indexed proposalId,
        address indexed proposer,
        ProposalType proposalType,
        string title,
        uint256 endTime
    );
    
    event VoteCast(
        uint256 indexed proposalId,
        address indexed voter,
        bool support,
        uint256 weight
    );
    
    event ProposalExecuted(
        uint256 indexed proposalId,
        ProposalStatus status
    );
    
    event VoterAdded(address indexed voter, uint256 votingPower);
    event VoterRemoved(address indexed voter);
    
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PROPOSER_ROLE, msg.sender);
    }

    /**
     * @notice Add a voter to the DAO
     * @param voter Address of the voter
     * @param power Voting power (typically based on tokens held)
     */
    function addVoter(address voter, uint256 power) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(voter != address(0), "Invalid address");
        require(power > 0, "Power must be greater than 0");
        require(!hasRole(VOTER_ROLE, voter), "Already a voter");
        
        _grantRole(VOTER_ROLE, voter);
        votingPower[voter] = power;
        totalVoters++;
        
        emit VoterAdded(voter, power);
    }

    /**
     * @notice Remove a voter from the DAO
     * @param voter Address of the voter
     */
    function removeVoter(address voter) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(hasRole(VOTER_ROLE, voter), "Not a voter");
        
        _revokeRole(VOTER_ROLE, voter);
        votingPower[voter] = 0;
        totalVoters--;
        
        emit VoterRemoved(voter);
    }

    /**
     * @notice Create a new proposal
     * @param proposalType Type of proposal
     * @param title Proposal title
     * @param description Detailed description
     * @param newValue New value for fee/penalty changes (0 for general proposals)
     */
    function createProposal(
        ProposalType proposalType,
        string memory title,
        string memory description,
        uint256 newValue
    ) external onlyRole(PROPOSER_ROLE) returns (uint256) {
        require(bytes(title).length > 0, "Title required");
        require(bytes(description).length > 0, "Description required");
        
        _proposalIdCounter++;
        uint256 newProposalId = _proposalIdCounter;
        
        Proposal storage proposal = proposals[newProposalId];
        proposal.id = newProposalId;
        proposal.proposer = msg.sender;
        proposal.proposalType = proposalType;
        proposal.title = title;
        proposal.description = description;
        proposal.newValue = newValue;
        proposal.startTime = block.timestamp;
        proposal.endTime = block.timestamp + votingPeriod;
        proposal.status = ProposalStatus.Active;
        
        emit ProposalCreated(
            newProposalId,
            msg.sender,
            proposalType,
            title,
            proposal.endTime
        );
        
        return newProposalId;
    }

    /**
     * @notice Cast a vote on a proposal
     * @param proposalId ID of the proposal
     * @param support True for yes, false for no
     */
    function vote(uint256 proposalId, bool support) external onlyRole(VOTER_ROLE) {
        Proposal storage proposal = proposals[proposalId];
        
        require(proposal.id != 0, "Proposal does not exist");
        require(proposal.status == ProposalStatus.Active, "Proposal not active");
        require(block.timestamp <= proposal.endTime, "Voting period ended");
        require(!proposal.hasVoted[msg.sender], "Already voted");
        
        uint256 weight = votingPower[msg.sender];
        require(weight > 0, "No voting power");
        
        proposal.hasVoted[msg.sender] = true;
        
        if (support) {
            proposal.votesFor += weight;
        } else {
            proposal.votesAgainst += weight;
        }
        
        emit VoteCast(proposalId, msg.sender, support, weight);
    }

    /**
     * @notice Execute a proposal after voting period
     * @param proposalId ID of the proposal
     */
    function executeProposal(uint256 proposalId) external nonReentrant {
        Proposal storage proposal = proposals[proposalId];
        
        require(proposal.id != 0, "Proposal does not exist");
        require(proposal.status == ProposalStatus.Active, "Proposal not active");
        require(block.timestamp > proposal.endTime, "Voting period not ended");
        require(!proposal.executed, "Already executed");
        
        uint256 totalVotes = proposal.votesFor + proposal.votesAgainst;
        uint256 totalPossibleVotes = _getTotalVotingPower();
        
        // Check quorum
        uint256 quorum = (totalPossibleVotes * quorumPercentage) / 100;
        if (totalVotes < quorum) {
            proposal.status = ProposalStatus.Rejected;
            proposal.executed = true;
            emit ProposalExecuted(proposalId, ProposalStatus.Rejected);
            return;
        }
        
        // Check if passed
        uint256 passingVotes = (totalVotes * passingThreshold) / 100;
        if (proposal.votesFor >= passingVotes) {
            proposal.status = ProposalStatus.Passed;
        } else {
            proposal.status = ProposalStatus.Rejected;
        }
        
        proposal.executed = true;
        
        emit ProposalExecuted(proposalId, proposal.status);
    }

    /**
     * @notice Get proposal details
     * @param proposalId ID of the proposal
     */
    function getProposal(uint256 proposalId) external view returns (
        address proposer,
        ProposalType proposalType,
        string memory title,
        string memory description,
        uint256 newValue,
        uint256 votesFor,
        uint256 votesAgainst,
        uint256 startTime,
        uint256 endTime,
        ProposalStatus status,
        bool executed
    ) {
        Proposal storage proposal = proposals[proposalId];
        return (
            proposal.proposer,
            proposal.proposalType,
            proposal.title,
            proposal.description,
            proposal.newValue,
            proposal.votesFor,
            proposal.votesAgainst,
            proposal.startTime,
            proposal.endTime,
            proposal.status,
            proposal.executed
        );
    }

    /**
     * @notice Check if an address has voted on a proposal
     * @param proposalId ID of the proposal
     * @param voter Address to check
     */
    function hasVoted(uint256 proposalId, address voter) external view returns (bool) {
        return proposals[proposalId].hasVoted[voter];
    }

    /**
     * @notice Update voting period (only admin)
     * @param newPeriod New voting period in seconds
     */
    function updateVotingPeriod(uint256 newPeriod) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(newPeriod >= 1 days, "Period too short");
        require(newPeriod <= 30 days, "Period too long");
        votingPeriod = newPeriod;
    }

    /**
     * @notice Update quorum percentage (only admin)
     * @param newQuorum New quorum percentage (0-100)
     */
    function updateQuorum(uint256 newQuorum) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(newQuorum > 0 && newQuorum <= 100, "Invalid quorum");
        quorumPercentage = newQuorum;
    }

    /**
     * @notice Update passing threshold (only admin)
     * @param newThreshold New passing threshold (0-100)
     */
    function updatePassingThreshold(uint256 newThreshold) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(newThreshold > 0 && newThreshold <= 100, "Invalid threshold");
        passingThreshold = newThreshold;
    }

    /**
     * @notice Get total voting power across all voters
     */
    function _getTotalVotingPower() private view returns (uint256) {
        // This is a simplified version. In production, you'd want to track this more efficiently
        return totalVoters * 100; // Assuming average voting power
    }

    /**
     * @notice Get total number of proposals
     */
    function getProposalCount() external view returns (uint256) {
        return _proposalIdCounter;
    }
}
