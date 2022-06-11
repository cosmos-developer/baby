# Specification for testnet
Learners are expected to write a script in [deploy-testnet](/homework/deploy-testnet.sh) to deploy a testnet node with configuration as follow:

1. rpc listen address: tcp://0.0.0.0:1711
2. api listen address: tcp://0.0.0.0:1350
3. two address with 1000000000 ubaby, one with 50000000 ubaby
4. chain-id is toddler

github workflow will check:
1. all 4 above criteria

# workflow for ci
1. a container will run script deploy-testnet.sh and deploy a node
2. run steps to check point 3 with API address
3. run steps to check point 4 with RPC address

# What learners will do
1. fork github.com/cosmos-developer/baby
2. checkout branch testnet-check
3. write script in [deploy-testnet](/homework/deploy-testnet.sh)
4. make a pull request to github.com/cosmos-developer/baby of branch testnet-check