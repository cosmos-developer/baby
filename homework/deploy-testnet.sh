#!/bin/bash

RPC="tcp://0.0.0.0:1711"
API="tcp://0.0.0.0:1350"
CHAIN_ID="toddler"
KEYRING="test"
MONIKER="idktestnet"

echo starting 

if [ -d $HOME/.baby ]; then
    rm -rf $HOME/.baby
fi

babyd config keyring-backend $KEYRING
babyd config chain-id $CHAIN_ID

# Adding keys 
babyd keys add key1 --keyring-backend $KEYRING 
babyd keys add key2 --keyring-backend $KEYRING 
babyd keys add key0 --keyring-backend $KEYRING 

babyd init $MONIKER --chain-id $CHAIN_ID

toml set --toml-path $HOME/.baby/config/app.toml api.swagger true
toml set --toml-path $HOME/.baby/config/app.toml api.enable true
toml set --toml-path $HOME/.baby/config/config.toml rpc.laddr $RPC
toml set --toml-path $HOME/.baby/config/app.toml api.address $API

# denom change for staking
cat $HOME/.baby/config/genesis.json | jq '.app_state["staking"]["params"]["bond_denom"]="ubaby"' > $HOME/.baby/config/tmp_genesis.json && mv $HOME/.baby/config/tmp_genesis.json $HOME/.baby/config/genesis.json

# update crisis variable to ubaby
cat $HOME/.baby/config/genesis.json | jq '.app_state["crisis"]["constant_fee"]["denom"]="ubaby"' > $HOME/.baby/config/tmp_genesis.json && mv $HOME/.baby/config/tmp_genesis.json $HOME/.baby/config/genesis.json

# udpate gov genesis
cat $HOME/.baby/config/genesis.json | jq '.app_state["gov"]["deposit_params"]["min_deposit"][0]["denom"]="ubaby"' > $HOME/.baby/config/tmp_genesis.json && mv $HOME/.baby/config/tmp_genesis.json $HOME/.baby/config/genesis.json

# update mint genesis
cat $HOME/.baby/config/genesis.json | jq '.app_state["mint"]["params"]["mint_denom"]="ubaby"' > $HOME/.baby/config/tmp_genesis.json && mv $HOME/.baby/config/tmp_genesis.json $HOME/.baby/config/genesis.json


babyd add-genesis-account key0 1001000000ubaby --keyring-backend $KEYRING
babyd add-genesis-account key1 1000000000ubaby --keyring-backend $KEYRING
babyd add-genesis-account key2 50000000ubaby --keyring-backend $KEYRING

babyd gentx key0 1000000ubaby --chain-id $CHAIN_ID --keyring-backend $KEYRING
babyd collect-gentxs
babyd validate-genesis


babyd start
 

