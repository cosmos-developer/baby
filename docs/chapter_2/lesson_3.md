Goal:
* Learners should understand how to create and submit a simple transfer transaction
* Learners should know how to make an arbitrary transaction

# Lesson 3: Making a transaction through CLI

## Guidelines
Transaction is the only way you can commit actions on the chain.

Use "babyd tx bank send --help" to learn more

1. Important flags:
* node: <host>:<port> to tendermint rpc interface for this chain (default "tcp://localhost:26657")
* from: name or address of private key with which to sign
* gas: gas limit to set per-transaction; set to "auto" to calculate sufficient gas automatically (default 200000)
* fees: Fees to pay along with transaction; eg: 10uatom
* chain-id: The network chain ID

2. Nice-to-know flags:
* yes (-y): Skip tx broadcasting prompt confirmation

3. Example: bank transaction
* babyd tx bank send {} {} 1000000ubaby --chain-id baby-1 --node tcp://localhost:2281 --gas auto --fees 10ubaby -y --keyring-backend test
* (will explain query in next video) babyd q bank balances {}

## Help videos
* https://www.youtube.com/watch?v=8k5PpLndpEo

## Homework
* try to make a transfer transaction

![transfer](./images/transfer.png)

* use "--help", try to delegate to a validator (babyd tx staking --help)

![stake](./images/stake.png)