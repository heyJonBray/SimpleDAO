# SimpleDAO: An Experiment in AI-Assisted Protocol Development

SimpleDAO is an experiment in AI-assisted protocol development that aims to create a decentralized autonomous organization (DAO) on the Ethereum blockchain. The design of this project and governance is the result of fine-tuning prompts in the (OpenAI playground)[1]. All code, including smart contracts associated with this project were outlined at a high level through prompts to OpenAI describing their intended functions. The code is then refined manually as GPT is still limited in providing error-proof code.

The goal of SimpleDAO is to define a methodology for the use of AI in the design and optimization of decentralized protocols. In particular, the project focuses on how AI can help create more efficient and effective governance mechanisms for DAOs through better prompt engineering. By leveraging AI, the hope is that SimpleDAO can provide insights into a workflow and set of prompts that can bring decentralized protocols to market faster than traditional design approaches.

## How it Started

The idea for SimpleDAO emerged out of my interest in the potential of DAOs to revolutionize how we organize and coordinate. However, designing effective governance mechanisms for DAOs is a challenging task, as it requires balancing competing interests and ensuring fairness and transparency.

The recent availability of functional AI models like GPT led me to wonder how best to utilize AI in my programming workflows and to judge how effective AI systems are at tackling the challenge of optimizing DAO governance when provided with the right prompts.

## How it Works

At a high level, SimpleDAO is a DAO that uses a custom governance mechanism which utilizes `ProposalNFTs` to facilitate decision-making in a compartmentalized and ad-hoc manner. Members of the DAO can lock up their _SDAO_ tokens in exchange for _veSDAO_ tokens, which can be used to vote on governance proposals.

### Voting Power

In order to carry any usable voting power, _SDAO_ tokens must be staked for _veSDAO_. Voting power per _SDAO_ token held can be augmented through the use of locked staking, increasing voting power by up to 100%

- Tokens staked using the standard staking method have a voting power of 1.0 (_1 veSDAO/SDAO staked_).
- Tokens can optionally be time-locked for a maximum of 2 years to increase their voting power.
- The voting power increases linearly with time locked up to a maximum of 2.0 (_2 veSDAO/SDAO locked_).

### Voting Mechanism

The voting mechanism is based on a proposal-staking model, where members stake their _veSDAO_ tokens in either a **"yes"** or **"no"** position for each proposal. Proposals can be issued by any _veSDAO_ holders through the `ProtocolFactory` contract, which standardizes the protocol process. Each created `Proposal` is (ERC-721)[2] compliant, and are essentially a liquidity pool of votes and metadata reflecting the intention and logic the proposal should follow.

- Proposals can be created in various types, including `TreasuryProposal`, `ConstitutionProposal`, `QuorumProposal` etc.
- The assignment of new proposal types is done through the same governance mechanism.
- Proposals have an expiration date that is encoded at the time of creation. Expired proposal tokens are burnt the end of Epochs (to be defined) or as-needed to reduce the gas cost of other governmental functions.
- Quorum for Proposals to pass is initially 60%.

### Other DAO Functions

In addition to the governance mechanism, SimpleDAO also includes a treasury and a protocol-owned liquidity pool. The treasury is used to manage the funds of the DAO and is controlled by the governance mechanism. Funds from the treasury can be allocated directly to an address through a passing **"yes"** vote on a `TreasuryProposal`.
The protocol-owned liquidity pool is used to provide liquidity for the SDAO token and is owned by the DAO treasury. Protocol-liquidity can be expanded via the proposal mechanism to include providing liquidity to tokens of other projects such as the native tokens of DAO partners, to fuel member's personal creator economies (social tokens), or other uses outlined by the DAO in the future.

## SimpleDAO is an Experiment

**Note that at this time, SimpleDAO is an experiment in AI-assisted workflow, and the current build has not passed security audits, nor is it ready for mainnet usage.** Progress will be updated here, including a link to the prompts used to create this project.

[1]: https://platform.openai.com/playground
[2]: https://eips.ethereum.org/EIPS/eip-721
