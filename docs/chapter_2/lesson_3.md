Goal:
* Learners should understand how to create and submit a simple transfer transaction
* Learners should know how to make an arbitrary transaction

# Lesson 3: Making a transaction through CLI

## Guidelines
Transaction is the only way you can commit actions on the chain.

Use "--help" to learn more

1. Important flags:
* node
* from
* gas
* fees
* chain-id

2. Nice-to-know flags:
* yes (-y)

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