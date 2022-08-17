#!/bin/bash

KEY="test"
CHAINID="toddler"
KEYRING="test"
MONIKER="toddler"
KEYALGO="secp256k1"
LOGLEVEL="info"

# validate dependencies are installed
command -v jq > /dev/null 2>&1 || { echo >&2 "jq not installed. More info: https://stedolan.github.io/jq/download/"; exit 1; }
command -v toml > /dev/null 2>&1 || { echo >&2 "toml not installed. More info: https://github.com/mrijken/toml-cli"; exit 1; }

babyd config keyring-backend $KEYRING
babyd config chain-id $CHAINID

babyd keys add $KEY --keyring-backend $KEYRING --algo $KEYALGO
babyd keys add test1 --keyring-backend $KEYRING --algo $KEYALGO
babyd keys add test2 --keyring-backend $KEYRING --algo $KEYALGO
babyd keys add test3 --keyring-backend $KEYRING --algo $KEYALGO

echo >&1 "\n"

# init chain
babyd init $MONIKER --chain-id $CHAINID

# Change parameter token denominations to ubaby
cat $HOME/.baby/config/genesis.json | jq '.app_state["staking"]["params"]["bond_denom"]="ubaby"' > $HOME/.baby/config/tmp_genesis.json && mv $HOME/.baby/config/tmp_genesis.json $HOME/.baby/config/genesis.json
cat $HOME/.baby/config/genesis.json | jq '.app_state["crisis"]["constant_fee"]["denom"]="ubaby"' > $HOME/.baby/config/tmp_genesis.json && mv $HOME/.baby/config/tmp_genesis.json $HOME/.baby/config/genesis.json
cat $HOME/.baby/config/genesis.json | jq '.app_state["gov"]["deposit_params"]["min_deposit"][0]["denom"]="ubaby"' > $HOME/.baby/config/tmp_genesis.json && mv $HOME/.baby/config/tmp_genesis.json $HOME/.baby/config/genesis.json
cat $HOME/.baby/config/genesis.json | jq '.app_state["mint"]["params"]["mint_denom"]="ubaby"' > $HOME/.baby/config/tmp_genesis.json && mv $HOME/.baby/config/tmp_genesis.json $HOME/.baby/config/genesis.json

# Set gas limit in genesis
# cat $HOME/.baby/config/genesis.json | jq '.consensus_params["block"]["max_gas"]="10000000"' > $HOME/.baby/config/tmp_genesis.json && mv $HOME/.baby/config/tmp_genesis.json $HOME/.baby/config/genesis.json

# enable rest server and swagger
toml set --toml-path $HOME/.baby/config/app.toml api.address "tcp://0.0.0.0:1350"
toml set --toml-path $HOME/.baby/config/app.toml api.swagger true
toml set --toml-path $HOME/.baby/config/app.toml api.enable true

# Allocate genesis accounts (cosmos formatted addresses)
babyd add-genesis-account $KEY 1000000000000ubaby --keyring-backend $KEYRING
babyd add-genesis-account test1 1000000000ubaby --keyring-backend $KEYRING
babyd add-genesis-account test2 1000000000ubaby --keyring-backend $KEYRING
babyd add-genesis-account test3 50000000ubaby --keyring-backend $KEYRING

# Sign genesis transaction
babyd gentx $KEY 1000000ubaby --keyring-backend $KEYRING --chain-id $CHAINID

# Collect genesis tx
babyd collect-gentxs

# Run this to ensure everything worked and that the genesis file is setup correctly
babyd validate-genesis

# Start the node (remove the --pruning=nothing flag if historical queries are not needed)
babyd start --pruning=nothing --log_level $LOGLEVEL --minimum-gas-prices=0.0001ubaby --rpc.laddr tcp://localhost:1711