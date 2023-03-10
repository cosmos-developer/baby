Goal:
* Learners should understand more information(params) in genesis.json

# Lesson 11: Introduction to genesis.json

genesis.json: Is a json file that defines the initial state of the chain, as block 0 of the chain. In this file, it will contain a lot of necessary information such as initialization time, important parameters like crisis, consensus param, bank, ...

In this lesson, I will mention 3 information that is genesis_time, chain_id and consensus_param.

## Guidelines

1. initialize a node
2. try to find genesis.json in ~/.baby/config. Try to look for this paragraph

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
* consensus_param: defines consensus params.
```bash
 "block": "
      "max_bytes": "22020096",
      "max_gas": "-1",
      "time_iota_ms": "1000"
    "
```
Like you see, in field block, have three sub-params: max_byte (max numbers of byte / block ); max_gas: total gas in a block cannot exceed this limit (if u not setup, default's -1); time_iota_ms: minimum time increment between consecutive blocks (in milliseconds). 

```bash
 "evidence": "
      "max_age_num_blocks": "100000",
      "max_age_duration": "172800000000000",
      "max_bytes": "1048576"
    "
```
In field evidence, have three sub-params: max_age_num_blocks: defines the maximum number of blocks after which an evidence is not valid anymore. Ie. if its 1000, and we're at block 5000, only evidence since block 4000 will be considered valid  

```bash
"validator": "
      "pub_key_types": [
        "ed25519"
      ]
    "
```
In field validator, just show type of publickey (ed25519), if you wanna understand it, read it.

## Homework
1. Prepare for the following informative lessons by learning more about the remaining fields in the genesis.json file and understanding those fields