Each of these lessons will be __5 mins__ long only

For ease of communication, I will assume the following in this guideline:
* chain name: chain
* chain binary: chaind
* chain configuration folder: $HOME/.chaind 

# Module 1: Cosmos SDK chain
## I. Chapter 1: Chain Interaction (11 weeks expected to build)
* Purpose: Chain interaction serves as cornerstone in helping a person get familiar with Cosmos SDK

1. __Group 1__: Starting a chain
* Lesson 1: Scaffolding and starting a chain using Ignite CLI
* Lesson 2: Starting a chain the technical way

2. __Group 2__: Interacting with a chain through cli
* Lesson 3: Introduction to CLI of a chain
* Lesson 4: Keyring
* Lesson 5: Making a transaction through CLI
* Lesson 6: Making a query through CLI
* Lesson 7: Monitoring your node (version, status)

3. __Group 3__: Interacting with a chain through API
* Lesson 8: Introduction to rpc address and api address
* Lesson 9: Making a transaction through API
* Lesson 10: Making a query through API

4. __Group 4__: Chain configuration
* Lesson 11: Introduction to folder configuration ($HOME/.chaind)
* Lesson 12: Introduction to app.toml
* Lesson 13: Introduction to client.toml and "chaind config"
* Lesson 14: Configuration of chain ports
* Lesson 15: Introduction to genesis.json (genesis_time, chain_id, app_state)
* Lesson 16: Dive deeper into app_state module configuration (auth, bank)
* Lesson 17: Dive deeper into app_state module configuration (gov, mint)
* Lesson 18: Dive deeper into app_state module configuration (staking, vesting)
* Lesson 19: Setting up genesis.json before mainnet experience (validate-genesis)

5. __Group 5__: Setting up a validator
* Lesson 17: Introduction to validator role in Cosmos
* Lesson 18: Setting up validator for new chain (add-genesis-account, tendermint, gentx)
* Lesson 19: Joining as validator to running chain

6. __Group 6__: Setting up a local testnet
* Lesson 20: Initialize 3 local nodes
* Lesson 21: Setting up 3 validators for each local nodes
* Lesson 22: Genesis configuration and sharing between 3 local nodes
* Lesson 23: Final setup to start a local testnet

## II. Chapter 2: Building a custom module

# Module 2: CosmWasm
## I. Chapter 1: Write and upload a NFT contract (13 weeks to complete)
* Purpose: write a NFT contract and upload that contract to local testnet of Juno

1. __Group 1__: Setup a Smart Contract project with CosmWasm
* Lesson 1: Generating a CosmWasm project
* Lesson 2: Introduction to CosmWasm project file structure
* Lesson 3: Introduction to NFT's implementation idea and CW-721

2. __Group 2__: Entry point (lib.rs || contract.rs)
* Lesson 4: Introduction to contract entry_point and overall flow
* Lesson 5: instantiate, execute, query entry_point
* Lesson 6: Entry point variable (DepsMut, Deps, Env)
* Lesson 7: Entry point variable (MessageInfo, Msg)

2. __Group 3__: State (To save state of contract to database) (state.rs)
* Lesson 8: Introduction to data Structure of State
* Lesson 9: Introduction to cosmwasm_std::Storage
* Lesson 10: Introduction to cw_storage_plus storage format
* Lesson 11: Saving State to cosmwasm_std::Storage (cw_storage_plus::Item<'a, u64>)

3. __Group 4__: Msg
* Lesson 12: Introduction to Msg
* Lesson 13: Msg schema generation
* Lesson 14: Introduction to InstantiateMsg
* Lesson 15: Introduction to ExecuteMsg
* Lesson 16: Introduction to QueryMsg

4. __Group 5__: Execute
* Lesson 17: Writing implementation for "instantiate"
* Lesson 18: Writing implementation for "transfer" NFT
* Lesson 19: Writing implementation for "mint" NFT

5. __Group 6__: Query
* Lesson 20: Writing implementation for "owner_of"
* Lesson 21: Writing implementation for "nft_info"

6. __Group 7__: Contract error
* Lesson 22: Introduction to contract error

7. __Group 8__: Contract testing
* Lesson 23: Setup contract for testing
* Lesson 24: Test instantiation of contract
* Lesson 25: Test minting of contract

8. __Group 9__: Instantiating contract on local testnet of Juno
* Lesson 26: Store and instantiate contract on testnet

## II. Chapter 2: Interact with NFT contract (CLI and cosmJS)


# Module 3: IBC (Inter - Blockchain Communication)
