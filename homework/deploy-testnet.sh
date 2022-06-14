#!/bin/bash
VALIDATOR="validator"
KEY1="tieubaoca01"
KEY2="tieubaoca02"
KEY3="tieubaoca03"
BALANCE1="1000000000ubaby"
BALANCE2="50000000ubaby"
CHAINID="toddler"
KEYRING="test"
MONIKER="localtestnet"
LOGLEVEL="info"


    rm -rf $HOME/.baby*
make install
babyd config keyring-backend $KEYRING
babyd config chain-id $CHAINID
# init chain
babyd init $MONIKER --chain-id $CHAINID
babyd keys add $KEY1 --keyring-backend $KEYRING
babyd keys add $KEY2 --keyring-backend $KEYRING
# Change parameter token denominations to ubaby
cat $HOME/.baby/config/genesis.json | jq '.app_state["staking"]["params"]["bond_denom"]="ubaby"' > $HOME/.baby/config/tmp_genesis.json && mv $HOME/.baby/config/tmp_genesis.json $HOME/.baby/config/genesis.json
cat $HOME/.baby/config/genesis.json | jq '.app_state["crisis"]["constant_fee"]["denom"]="ubaby"' > $HOME/.baby/config/tmp_genesis.json && mv $HOME/.baby/config/tmp_genesis.json $HOME/.baby/config/genesis.json
cat $HOME/.baby/config/genesis.json | jq '.app_state["gov"]["deposit_params"]["min_deposit"][0]["denom"]="ubaby"' > $HOME/.baby/config/tmp_genesis.json && mv $HOME/.baby/config/tmp_genesis.json $HOME/.baby/config/genesis.json
cat $HOME/.baby/config/genesis.json | jq '.app_state["mint"]["params"]["mint_denom"]="ubaby"' > $HOME/.baby/config/tmp_genesis.json && mv $HOME/.baby/config/tmp_genesis.json $HOME/.baby/config/genesis.json

# enable rest server and swagger
toml set --toml-path $HOME/.baby/config/app.toml api.swagger true
toml set --toml-path $HOME/.baby/config/app.toml api.enable true
toml set --toml-path $HOME/.baby/config/app.toml api.address tcp://0.0.0.0:1350
# sed -i -E 's|tcp://0.0.0.0:1317|tcp://0.0.0.0:1350|g' $HOME/.baby/config/app.toml

# Allocate genesis accounts (cosmos formatted addresses) 
babyd add-genesis-account $KEY1 $BALANCE1 --keyring-backend $KEYRING
babyd add-genesis-account $KEY2 $BALANCE1 --keyring-backend $KEYRING
babyd add-genesis-account $KEY3 $BALANCE2 --keyring-backend $KEYRING
babyd add-genesis-account $VALIDATOR $BALANCE1 --keyring-backend $KEYRING

# Sign genesis transaction
babyd gentx $VALIDATOR 1000000ubaby --keyring-backend $KEYRING --chain-id $CHAINID

# Collect genesis tx
babyd collect-gentxs

# Run this to ensure everything worked and that the genesis file is setup correctly
babyd validate-genesis

# Start the node (remove the --pruning=nothing flag if historical queries are not needed)
babyd start --pruning=nothing --log_level $LOGLEVEL --minimum-gas-prices=0.0001ubaby --p2p.laddr tcp://0.0.0.0:2280 --rpc.laddr tcp://0.0.0.0:1711
# do it man :))))