// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
interface IVesting {
    function calculateVestedTokens(address _benificiary)external view returns (uint);
}

contract GovernanceToken is ERC20{
    //refferance to vesting contract
    IVesting public vestingContract;
    uint public minimumVestedTokensRequired = 1000 * 10**18;

    uint public proposalCount;
    uint public votingPeriod = 7 days;
    
    constructor(uint initialSupply) ERC20("GovernanceToken","GOV"){
        _mint(msg.sender, initialSupply);
    }

    struct proposal{
        uint id;
        string description;
        uint voteCountFor;
        uint voteCountAgainst;
        uint endTime;
        bool exicuted;
        address proposer;
        bool active;
        address target; // Address to execute the proposal action
        bytes data;     // Encoded function call for execution
    }

    mapping (uint => proposal)public Proposals;
    //vote by each address for each proposal
    mapping (address => mapping (uint =>bool))public votes;

    // EVENTS
    event proposalCreated(address indexed creator, string indexed description);
    event voted(address indexed voter, uint proposalId, bool vote);
    event proposalExicution(uint proposalId, bool exicuted);

    // FUNCTIONS
    function createProposal(
        string memory _description,
        bytes memory _data,
        address _target
        )
        external
        {
        uint proposalId = proposalCount++;
        uint _endTime =block.timestamp + votingPeriod;

        Proposals[proposalId] = proposal({
            id : proposalId,
            description : _description,
            voteCountFor : 0,
            voteCountAgainst : 0,
            endTime : _endTime,
            exicuted :false,
            proposer :msg.sender,
            active : true,
            target :_target,
            data : _data
        });

        emit proposalCreated(msg.sender, _description);
    }

    // vote for a proposal
    function vote(uint proposalId, bool support)external{
        require(Proposals[proposalId].active,"Voting time over");
        require(block.timestamp < Proposals[proposalId].endTime);
        require(votes[msg.sender][proposalId] == false,"Already voted");

        //ensure the veter has the min vesting tokens
        uint vestedTokens = vestingContract.calculateVestedTokens(msg.sender);
        require(vestedTokens >= minimumVestedTokensRequired,"need vested Tokens to vote");

        if(support){
            Proposals[proposalId].voteCountFor++;
        }
        else{
            Proposals[proposalId].voteCountAgainst++;
        }

        votes[msg.sender][proposalId] = true;
        emit  voted(msg.sender, proposalId, support);
    }

    function exicuteProposalAction(address target, bytes memory data)internal returns (bool){
        // Execute the proposal's action on the target address
        (bool success, ) = target.call(data);
        return success;
    }

    // Finalize the proposal
    function finalizeProposal(uint proposalId)external{
        proposal storage prop = Proposals[proposalId];
        require(Proposals[proposalId].active ,"Already Finalized");
        require(block.timestamp >= Proposals[proposalId].endTime);
        require(prop.exicuted == false,"Already finalized");

        if(prop.voteCountAgainst < prop.voteCountFor){
            bool success = exicuteProposalAction(prop.target, prop.data);
            require(success,"Proposal exicution failed");
        }

        prop.exicuted = true;
        prop.active = false;

        emit proposalExicution(proposalId, prop.exicuted);

    }

    function getVotingResults(uint proposalId) external view returns (string memory description, uint voteCountFor,uint voteCountAgainst){
        proposal memory prop = Proposals[proposalId];
        return (prop.description, prop.voteCountFor, prop.voteCountAgainst);
    }
}