# baby
**baby** is a blockchain built using Cosmos SDK and Tendermint and created with [Ignite CLI](https://ignite.com/cli).

Inspired by Jacob Gadikian old blockchain project aimed at teaching Cosmos. Baby blockchain is intended as a guide for people to learn Cosmos.

Baby is intended to be an open source interactive learning with CI/CD to confirm the work of leaners.

Baby is intended to be easy and captivating to learn with 5 minutes lessons only.

Baby learning path includes:
1. deploying a local testnet [Specs here](specs/testnet_spec.md)
2. writing claims module [Specs here](specs/claims_module_spec.md) (building)

# SDK Vietnam community class

## I. Chapter 1: Chain Interaction

Purpose: Chain interaction serves as cornerstone in helping a person get familiar with Cosmos SDK

1. Group 1: Starting a chain

- [Lesson 1: Scaffolding and starting a chain](docs/chapter_1/group_1/lesson_1.md)
- [Lesson 2: Configuration of node ports](docs/chapter_1/group_1/lesson_2.md)

2. Group 2: Interacting with a chain through cli

- [Lesson 3: Keyring](docs/chapter_1/group_2/lesson_3.md)
- [Lesson 4: Making a transaction through CLI](docs/chapter_1/group_2/lesson_4.md)
- [Lesson 5: Making a query through CLI](docs/chapter_1/group_2/lesson_5.md)
- [Lesson 6: Monitoring your node (version, status)](docs/chapter_1/group_2/lesson_6.md)

3. Group 3: Interacting with a chain through API

- [Lesson 7: Making a transaction through API](docs/chapter_1/group_3/lesson_7.md)
- [Lesson 8: Making a query through API](docs/chapter_1/group_3/lesson_8.md)

4. Group 4: Chain configuration

- [Lesson 9: Enable API server in app.toml](docs/chapter_1/group_4/lesson_9.md)
- [Lesson 10: Introduction to client.toml](docs/chapter_1/group_4/lesson_10.md)
- [Lesson 11: Introduction to genesis.json (genesis_time, chain_id, consensus_params)](docs/chapter_1/group_4/lesson_11.md)
- [Lesson 12: Dive deeper into app_state module configuration (accounts, bank, staking)](docs/chapter_1/group_4/lesson_12.md)
- [Lesson 13: Dive deeper into app_state module configuration (mint, distribution, gov)](docs/chapter_1/group_4/lesson_13.md)

5. Group 5: Setting up a validator
- [Lesson 14: Setting up validator for new chain (add-genesis-account, tendermint, gentx, validate-genesis)](docs/chapter_1/group_5/lesson_14.md)
- [Lesson 15: Setting up testnet](docs/chapter_1/group_5/lesson_15.md)

## II. Chapter 2: Building a custom module

1. Group 1: Protobuf
- Lesson 1: Write a protobuf struct in Cosmos
- Lesson 2: Generate protobuf struct
  
2. Group 2: Write a chain module
- Lesson 3: Integrate module into app.go
- Lesson 4: Add new chain module data structure
- Lesson 5: Add new chain module logic
- Lesson 6: Add chain module CLI interaction
- Lesson 7: Add handling for chain module logic genesis state
- Lesson 8: Expose new chain module logic in module.go
- Lesson 9: Integrate new chain module logic to app.go
  
3. Group 3: Testing
- Lesson 10: Add unit testing
- Lesson 11: Add system testing
- Lesson 12: Linting
  
4. Group 4: Scripts
- Lesson 13: start node and local-net script
- Lesson 14: development script in Makefile
  
5. Group 5: Capstone project
- Lesson 15: Practice building a simple text module part 1
- Lesson 16: Practice building a simple text module part 2

# III. Chapter 3: Building CosmWasm contracts
1. Group 1: Basic setup
- Lesson 1: CosmWasm introduction
- Lesson 2: Bootstrap a basic CosmWasm dapp