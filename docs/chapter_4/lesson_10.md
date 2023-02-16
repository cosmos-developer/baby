Goal:
* Learners should understand how to config node in client.toml
* Learners should be able to start a node with configured client.toml

# Lesson 10: Introduction to client.toml

client.toml: configuration for client CLI interaction

## Guidelines

1. initialize a node
2. try to find client.toml in ~/.baby/config. Try to look for this paragraph

![client configuration](images/client_config.png)

3. There are three fields that you need to care about. Explaination is already in the file.
* chain-id: for more information, chain-id will also affect sending transaction
* keyring-backend
* node

4. Change it like in [test-node-deploy.sh](../../scripts/test-node-deploy.sh)

```bash
toml set --toml-path $HOME/.baby/config/client.toml node tcp://0.0.0.0:2281
```

This will set rpc node to tcp://0.0.0.0:2281

## Help videos

## Homework
1. Halt the node and change chain-id to "cosmos-boyz", node to port 4567
2. Continue running node with updated configuration in client.toml
3. Try sending money from account 1 to account 2 with updated chain-id and port