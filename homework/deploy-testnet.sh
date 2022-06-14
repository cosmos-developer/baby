#!/bin/bash

# do it man :))))

VALIDATOR_1="gnad01"
VALIDATOR_2="gnad02"
VALIDATOR_3="gnad03"
BALANCE1="1000000000ubaby"
BALANCE2="50000000ubaby"
CHAIN_ID="toddler"
KEY_RING="test"
MONIKER="localtestnet"
LOG_LEVEL="info"

# install baby
rm -rf $HOME/.baby*
make install

# config chain
babyd config keyring-backend $KEY_RING
babyd config chain-id $CHAIN_ID

# init chain
babyd init $MONIKER --chain-id $CHAIN_ID
babyd keys add $VALIDATOR_1 --keyring-backend $KEY_RING
babyd keys add $VALIDATOR_2 --keyring-backend $KEY_RING
babyd keys add $VALIDATOR_3 --keyring-backend $KEY_RING


# Change parameter token denominations to ubaby
cat $HOME/.baby/config/genesis.json | jq '.app_state["staking"]["params"]["bond_denom"]="ubaby"' > $HOME/.baby/config/tmp_genesis.json && mv $HOME/.baby/config/tmp_genesis.json $HOME/.baby/config/genesis.json
cat $HOME/.baby/config/genesis.json | jq '.app_state["crisis"]["constant_fee"]["denom"]="ubaby"' > $HOME/.baby/config/tmp_genesis.json && mv $HOME/.baby/config/tmp_genesis.json $HOME/.baby/config/genesis.json
cat $HOME/.baby/config/genesis.json | jq '.app_state["gov"]["deposit_params"]["min_deposit"][0]["denom"]="ubaby"' > $HOME/.baby/config/tmp_genesis.json && mv $HOME/.baby/config/tmp_genesis.json $HOME/.baby/config/genesis.json
cat $HOME/.baby/config/genesis.json | jq '.app_state["mint"]["params"]["mint_denom"]="ubaby"' > $HOME/.baby/config/tmp_genesis.json && mv $HOME/.baby/config/tmp_genesis.json $HOME/.baby/config/genesis.json

# enable rest server and swagger
sed -i -E 's|swagger = false|swagger = true|g' $HOME/.baby/config/app.toml
sed -i -E 's|enable = false|enable = true|g' $HOME/.baby/config/app.toml
sed -i -E 's|tcp://0.0.0.0:1317|tcp://0.0.0.0:1350|g' $HOME/.baby/config/app.toml

babyd add-genesis-account $VALIDATOR_1 $BALANCE1 --keyring-backend $KEY_RING
babyd add-genesis-account $VALIDATOR_2 $BALANCE1 --keyring-backend $KEY_RING
babyd add-genesis-account $VALIDATOR_3 $BALANCE2 --keyring-backend $KEY_RING


# Sign genesis transaction
babyd gentx $VALIDATOR_1 1000000ubaby --keyring-backend $KEY_RING --chain-id $CHAIN_ID

# Collect genesis tx
babyd collect-gentxs

# Run this to ensure everything worked and that the genesis file is setup correctly
babyd validate-genesis

# Start the node (remove the --pruning=nothing flag if historical queries are not needed)
babyd start --pruning=nothing --log_level $LOG_LEVEL --minimum-gas-prices=0.0001ubaby --p2p.laddr tcp://0.0.0.0:2280 --rpc.laddr tcp://0.0.0.0:1711 --grpc.address 0.0.0.0:2282 --grpc-web.address 0.0.0.0:2283

