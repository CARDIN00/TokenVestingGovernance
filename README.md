# TokenVestingGovernance
 A set of smart contracts for token vesting and governance with voting mechanisms, enabling token holders with vested tokens to participate in proposal creation and voting in decentralized governance.
Token Vesting Contract:

Purpose: Manages the distribution of tokens to beneficiaries over time according to a vesting schedule.
Main Functions:
addBeneficiary(): Adds a beneficiary with a specific vesting schedule.
calculateVestedTokens(): Calculates the amount of tokens a beneficiary is entitled to release based on the vesting schedule.
release(): Allows beneficiaries to release vested tokens once they become available.
Key Features:
Customizable vesting schedules with start times, cliff durations, and vesting durations.
Secure release of tokens after the cliff and vesting period.
Governance Token Contract:

Purpose: Implements a governance token with voting rights and the ability to create and vote on proposals.
Main Functions:
createProposal(): Allows users to create proposals for governance actions.
vote(): Allows token holders with vested tokens to vote on proposals.
finalizeProposal(): Finalizes the proposal after the voting period and executes the proposal if it passes.
Key Features:
Voting rights are granted to users with a minimum amount of vested tokens.
Proposal execution occurs only if the proposal passes the voting phase.
Supports the creation of off-chain executable actions by encoding them in the proposal data.
Implements a proposal lifecycle with active, finalized, and executed states.
Interaction between Contracts:

The GovernanceToken contract interacts with the TokenVesting contract to check if a user has enough vested tokens to participate in the voting process.
Users need to have at least a predefined amount of vested tokens (e.g., 1000 tokens) to vote on proposals.
Security and Access Control:

The TokenVesting contract has an onlyOwner modifier to restrict access to certain administrative functions, such as adding beneficiaries.
The GovernanceToken contract ensures that only users with sufficient vested tokens can vote and participate in the governance process.
