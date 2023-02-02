#!/bin/bash

KEY="test"
CHAINID="baby-1"
KEYRING="test"
MONIKER="localtestnet"
KEYALGO="secp256k1"
LOGLEVEL="info"

# retrieve all args
WILL_RECOVER=0
WILL_INSTALL=0
WILL_CONTINUE=0
# $# is to check number of arguments
if [ $# -gt 0 ];
then
    # $@ is for getting list of arguments
    for arg in "$@"; do
        case $arg in
        --recover)
            WILL_RECOVER=1
            shift
            ;;
        --install)
            WILL_INSTALL=1
            shift
            ;;
        --continue)
            WILL_CONTINUE=1
            shift
            ;;
        *)
            printf >&2 "wrong argument somewhere"; exit 1;
            ;;
        esac
    done
fi

# continue running if everything is configured
if [ $WILL_CONTINUE -eq 1 ];
then
    # Start the node (remove the --pruning=nothing flag if historical queries are not needed)
    babyd start --pruning=nothing --log_level $LOGLEVEL --minimum-gas-prices=0.0001ubaby --p2p.laddr tcp://0.0.0.0:2280 --rpc.laddr tcp://0.0.0.0:2281 --grpc.address 0.0.0.0:2282 --grpc-web.address 0.0.0.0:2283
    exit 1;
fi

# validate dependencies are installed
command -v jq > /dev/null 2>&1 || { echo >&2 "jq not installed. More info: https://stedolan.github.io/jq/download/"; exit 1; }
command -v toml > /dev/null 2>&1 || { echo >&2 "toml not installed. More info: https://github.com/mrijken/toml-cli"; exit 1; }

# install babyd if not exist
if [ $WILL_INSTALL -eq 0 ];
then 
    command -v babyd > /dev/null 2>&1 || { echo >&1 "installing babyd"; make install; }
else
    echo >&1 "installing babyd"
    rm -rf $HOME/.baby*
    rm client/.env
    make install
fi

babyd config keyring-backend $KEYRING
babyd config chain-id $CHAINID

# determine if user wants to recorver or create new
if [ $WILL_RECOVER -eq 0 ];
then
    MNEMONIC=$(babyd keys add $KEY --keyring-backend $KEYRING --algo $KEYALGO --output json | jq -r '.mnemonic')
    echo "MNEMONIC=$MNEMONIC" >> client/.env
else
    MNEMONIC=$(babyd keys add $KEY --keyring-backend $KEYRING --algo $KEYALGO --recover --output json | jq -r '.mnemonic')
    echo "MNEMONIC=$MNEMONIC" >> client/.env
fi

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
toml set --toml-path $HOME/.baby/config/app.toml api.swagger true
toml set --toml-path $HOME/.baby/config/app.toml api.enable true
toml set --toml-path $HOME/.baby/config/app.toml api.address tcp://0.0.0.0:1310

# create more test key
TO_ADDRESS=$(babyd keys add test1 --keyring-backend $KEYRING --algo $KEYALGO --output json | jq -r '.address')
echo "TO_ADDRESS=$TO_ADDRESS" >> client/.env

# Allocate genesis accounts (cosmos formatted addresses)
babyd add-genesis-account $KEY 1000000000000ubaby --keyring-backend $KEYRING
babyd add-genesis-account test1 1000000000000ubaby --keyring-backend $KEYRING

# Sign genesis transaction
babyd gentx $KEY 1000000ubaby --keyring-backend $KEYRING --chain-id $CHAINID

# Collect genesis tx
babyd collect-gentxs

# Run this to ensure everything worked and that the genesis file is setup correctly
babyd validate-genesis

# Start the node (remove the --pruning=nothing flag if historical queries are not needed)
babyd start --pruning=nothing --log_level $LOGLEVEL --minimum-gas-prices=0.0001ubaby --p2p.laddr tcp://0.0.0.0:2280 --rpc.laddr tcp://0.0.0.0:2281 --grpc.address 0.0.0.0:2282 --grpc-web.address 0.0.0.0:2283
