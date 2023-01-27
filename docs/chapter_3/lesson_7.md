Goal:
* Learners should understand how to make a query through API

# Lesson 7: Making a query through API

Useful flags
* --node: <host>:<port> to Tendermint RPC interface for this chain (default "tcp://localhost:26657")

to learn more

## Guidelines
Query helps you to query information on chain or for debugging

1. start a baby node
2. make a transaction through CLI
 * babyd tx bank send baby15722a4jxtq7mkahfh93wt3s8skwzt9la50z8qf baby1sfcc725xlcrdsd6ltfqygz8cqh9fg6duqa40au 500000ubaby --fees 30ubaby  --node tcp://localhost:1711
3. query transaction through API
 * curl -X GET "http://localhost:1350/cosmos/bank/v1beta1/balances/baby1sfcc725xlcrdsd6ltfqygz8cqh9fg6duqa40au/by_denom?denom=ubaby" -H  "accept: application/json"
## Help videos
https://youtu.be/zfgvsb7sFpA
