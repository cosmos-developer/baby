Goal:
* Learners should understand more information(params) in genesis.json

# Lesson 11: Introduction to genesis.json

genesis.json: Is a json file that defines the initial state of the chain, as block 0 of the chain. This file will contain necessary information related to network identification (chain_id), consensus params, and parameter configuration for keepers.

In this lesson, I will mention 3 information that is genesis_time, chain_id and consensus_param.

## Guidelines

1. initialize a node 
```bash
bash scripts/test-node-deploy.sh --install
```
2. try to find genesis.json in ~/.baby/config. Look for this paragraph

![client configuration](images/genesis.png)

3. There are three fields that you need to care about. Explaination is already in the file.
* genesis_time: specify how long the thread was initialized. That is, when the thread runs the build successfully, the time (UTC) will be started.
```bash
 "genesis_time": "2023-03-09T06:22:42.750266398Z",
```

* chain_id: is a unique identifier for your chain. (If using the same version, it helps different between two chain_id)
```bash
 "chain_id": "baby-1",
```
* consensus_param: defines consensus params for tendermint node. This will affect how Tendermint node behaves. In most case, this should be left alone.
```bash
 "block": "
      "max_bytes": "22020096",
      "max_gas": "-1",
      "time_iota_ms": "1000"
    "
```
There are three sub-params in field "block":

* max_byte (max numbers of byte / block )
* max_gas: total gas in a block cannot exceed this limit (if not setup, default is -1)
* time_iota_ms: minimum time increment between consecutive blocks (in milliseconds).

```bash
 "evidence": "
      "max_age_num_blocks": "100000",
      "max_age_duration": "172800000000000",
      "max_bytes": "1048576"
    "
```
There are three sub-params in field "evidence":

* max_age_num_blocks: defines the maximum number of blocks after which an evidence is not valid anymore. Ie. if its 1000, and we're at block 5000, only evidence since block 4000 will be considered valid
* max_age_duration: Max age of evidence, in time. It should correspond with an app's "unbonding period" or other similar mechanism for handling [Nothing-At-Stake attacks]. Read more at (https://github.com/ethereum/wiki/wiki/Proof-of-Stake-FAQ#what-is-the-nothing-at-stake-problem-and-how-can-it-be-fixed)
* max_bytes: This sets the maximum size of total evidence in bytes that can be committed in a single block and should fall comfortably under the max block bytes. Default is 1048576 or 1MB

```bash
"validator": "
      "pub_key_types": [
        "ed25519"
      ]
    "
```
```bash
babyd tendermint show-validator
```  
to see validator public key in ed25519. Each node will an unique validator public key.



## Homework
1. Deploy a node with chain_id "lesson_11"
2. Make a bank send transaction successfully
![client configuration](images/tx_bank.png)

