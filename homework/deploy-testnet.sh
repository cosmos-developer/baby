#!/bin/bash

rm -rf $HOME/.baby/
killall screen

KEY="test"
KEYRING="test"
CHAINID="toddler"
MONIKER="localtestnet"
KEYALGO="secp256k1"
LOGLEVEL="info"

babyd config keyring-backend $KEYRING
babyd config chain-id $CHAINID

# determine if user wants to recorver or create new
babyd keys add $KEY --keyring-backend $KEYRING --algo $KEYALGO

# init chain
babyd init $MONIKER --chain-id $CHAINID

# Change parameter token denominations to ubaby
cat $HOME/.baby/config/genesis.json | jq '.app_state["staking"]["params"]["bond_denom"]="ubaby"' > $HOME/.baby/config/tmp_genesis.json && mv $HOME/.baby/config/tmp_genesis.json $HOME/.baby/config/genesis.json
cat $HOME/.baby/config/genesis.json | jq '.app_state["crisis"]["constant_fee"]["denom"]="ubaby"' > $HOME/.baby/config/tmp_genesis.json && mv $HOME/.baby/config/tmp_genesis.json $HOME/.baby/config/genesis.json
cat $HOME/.baby/config/genesis.json | jq '.app_state["gov"]["deposit_params"]["min_deposit"][0]["denom"]="ubaby"' > $HOME/.baby/config/tmp_genesis.json && mv $HOME/.baby/config/tmp_genesis.json $HOME/.baby/config/genesis.json
cat $HOME/.baby/config/genesis.json | jq '.app_state["mint"]["params"]["mint_denom"]="ubaby"' > $HOME/.baby/config/tmp_genesis.json && mv $HOME/.baby/config/tmp_genesis.json $HOME/.baby/config/genesis.json

# api listen address: tcp://0.0.0.0:1350
sed -i -E 's|tcp://0.0.0.0:1317|tcp://0.0.0.0:1350|g' $HOME/.baby/config/app.toml
sed -i -E 's|swagger = false|swagger = true|g' $HOME/.baby/config/app.toml
sed -i -E 's|enable = false|enable = true|g' $HOME/.baby/config/app.toml

# enable rest server and swagger
# toml set --toml-path $HOME/.baby/config/app.toml api.swagger true
# toml set --toml-path $HOME/.baby/config/app.toml api.enable true

# Allocate genesis accounts (cosmos formatted addresses)
babyd add-genesis-account $KEY 1000000000000ubaby --keyring-backend $KEYRING

# Sign genesis transaction
babyd gentx $KEY 1000000ubaby --keyring-backend $KEYRING --chain-id $CHAINID

# Collect genesis tx
babyd collect-gentxs

# Run this to ensure everything worked and that the genesis file is setup correctly
babyd validate-genesis

# Start the node (remove the --pruning=nothing flag if historical queries are not needed)
# rpc listen address: tcp://0.0.0.0:1711
babyd start --pruning=nothing \
    --log_level $LOGLEVEL \
    --minimum-gas-prices=0.0001ubaby \
    --p2p.laddr tcp://0.0.0.0:1710 \
    --rpc.laddr tcp://0.0.0.0:1711 \
    --grpc.address 0.0.0.0:1712 \
    --grpc-web.address 0.0.0.0:1713