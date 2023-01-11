Goal:
* Learners should understand how to create and query balances
* Learners should know how to query in general

# Lesson 4: Making a query through CLI

## Guidelines
Query helps you to query information on chain or for debugging

Use "babyd q bank balances --help" to learn more

Useful flags
* --output (-o): Output format (text|json) (default "text")
* --node: <host>:<port> to Tendermint RPC interface for this chain (default "tcp://localhost:26657")

1. bank
 * babyd q bank balances {} --node tcp://0.0.0.0:50000
 * babyd q bank balances {} --node tcp://0.0.0.0:50000 -o json
2. tx
 * babyd q tx {} --node tcp://0.0.0.0:50000

# Using json output in script
1. babyd q bank balances {} --node tcp://0.0.0.0:50000 -o json | jq ".balances[0]"
    * jq is a favourite tool for handling json

## Help videos
https://youtu.be/iC1Ca5JFnx4

## Homework
1. create a new key "test1"
2. make a bank send transaction from key "test" to "test1"

![res1](images/query_make_tx.png)

3. query tx of that bank transaction and get raw_log

![res2](images/query_tx_get_raw_log.png)

4. query balances of "test1" to make sure that it has received funds

![res3](images/query_bank_bal.png)