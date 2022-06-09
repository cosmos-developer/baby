# Specification for testnet
Learners are expected to write a script to deploy a testnet node with configuration as follow:

1. rpc listen address: tcp://0.0.0.0:1711
2. api listen address: tcp://0.0.0.0:1350
3. two address with 1000000000 ubaby, one with 50000000 ubaby
4. chain-id is toddler

github workflow will check:
1. all 4 above criteria