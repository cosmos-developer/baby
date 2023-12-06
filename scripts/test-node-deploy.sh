#!/bin/bash

KEY="test"
CHAINID="${CHAINID:-baby-1}"
# check if CHAINID is not defined
if [ -z "$CHAINID" ];
then
    CHAINID="baby-1"
fi
KEYRING="test"
MONIKER="localtestnet"
KEYALGO="secp256k1"
LOGLEVEL="info"
NODE_HOME="mytestnet"
BINARY="build/babyd"

# retrieve all args
WILL_RECOVER=0
# default running will install new node binary and start new instance
WILL_INSTALL=1
WILL_CONTINUE=0
INITIALIZE_ONLY=0
# $# is to check number of arguments
if [ $# -gt 0 ];
then
    # $@ is for getting list of arguments
    for arg in "$@"; do
        case $arg in
        --initialize)
            INITIALIZE_ONLY=1
            shift
            ;;
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
    $BINARY start --pruning=nothing --log_level $LOGLEVEL --minimum-gas-prices=0.0001ubaby --p2p.laddr tcp://0.0.0.0:2280 --grpc.address 0.0.0.0:2282 --grpc-web.address 0.0.0.0:2283 --home $NODE_HOME
    exit 1;
fi

# validate dependencies are installed
command -v jq > /dev/null 2>&1 || { echo >&2 "jq not installed. More info: https://stedolan.github.io/jq/download/"; exit 1; }
command -v toml > /dev/null 2>&1 || { echo >&2 "toml not installed. More info: https://github.com/mrijken/toml-cli"; exit 1; }

# install babyd if not exist
if [ $WILL_INSTALL -eq 0 ];
then 
    command -v build/babyd > /dev/null 2>&1 || { echo >&1 "installing babyd"; make build; }
else
    echo >&1 "installing babyd"
    rm -rf $NODE_HOME
    rm -rf build/babyd 2> /dev/null
    rm client/.env
    rm scripts/mnemonic.txt
    make build
fi

$BINARY config keyring-backend $KEYRING --home $NODE_HOME
$BINARY config chain-id $CHAINID --home $NODE_HOME

# determine if user wants to recorver or create new
MNEMONIC=""
if [ $WILL_RECOVER -eq 0 ];
then
    MNEMONIC=$($BINARY keys add $KEY --keyring-backend $KEYRING --algo $KEYALGO --output json --home $NODE_HOME | jq -r '.mnemonic')
else
    MNEMONIC=$($BINARY keys add $KEY --keyring-backend $KEYRING --algo $KEYALGO --recover --output json --home $NODE_HOME | jq -r '.mnemonic')
fi

echo "MNEMONIC=$MNEMONIC" >> client/.env
echo "MNEMONIC for $($BINARY keys show $KEY -a --keyring-backend $KEYRING --home $NODE_HOME) = $MNEMONIC" >> scripts/mnemonic.txt

echo >&1 "\n"

# init chain
$BINARY init $MONIKER --chain-id $CHAINID --home $NODE_HOME

# Change parameter token denominations to ubaby
cat $NODE_HOME/config/genesis.json | jq '.app_state["staking"]["params"]["bond_denom"]="ubaby"' > $NODE_HOME/config/tmp_genesis.json && mv $NODE_HOME/config/tmp_genesis.json $NODE_HOME/config/genesis.json
cat $NODE_HOME/config/genesis.json | jq '.app_state["crisis"]["constant_fee"]["denom"]="ubaby"' > $NODE_HOME/config/tmp_genesis.json && mv $NODE_HOME/config/tmp_genesis.json $NODE_HOME/config/genesis.json
cat $NODE_HOME/config/genesis.json | jq '.app_state["gov"]["deposit_params"]["min_deposit"][0]["denom"]="ubaby"' > $NODE_HOME/config/tmp_genesis.json && mv $NODE_HOME/config/tmp_genesis.json $NODE_HOME/config/genesis.json
cat $NODE_HOME/config/genesis.json | jq '.app_state["mint"]["params"]["mint_denom"]="ubaby"' > $NODE_HOME/config/tmp_genesis.json && mv $NODE_HOME/config/tmp_genesis.json $NODE_HOME/config/genesis.json

# Set gas limit in genesis
# cat $NODE_HOME/config/genesis.json | jq '.consensus_params["block"]["max_gas"]="10000000"' > $NODE_HOME/config/tmp_genesis.json && mv $NODE_HOME/config/tmp_genesis.json $NODE_HOME/config/genesis.json

# enable rest server and swagger
toml set --toml-path $NODE_HOME/config/app.toml api.swagger true
toml set --toml-path $NODE_HOME/config/app.toml api.enable true
toml set --toml-path $NODE_HOME/config/app.toml api.address tcp://0.0.0.0:1310
toml set --toml-path $NODE_HOME/config/client.toml node tcp://0.0.0.0:2281

# create more test key
MNEMONIC_1=$($BINARY keys add test1 --keyring-backend $KEYRING --algo $KEYALGO --output json --home $NODE_HOME | jq -r '.mnemonic')
TO_ADDRESS=$($BINARY keys show test1 -a --keyring-backend $KEYRING --home $NODE_HOME)
echo "MNEMONIC for $TO_ADDRESS = $MNEMONIC_1" >> scripts/mnemonic.txt
echo "TO_ADDRESS=$TO_ADDRESS" >> client/.env

# Allocate genesis accounts (cosmos formatted addresses)
$BINARY add-genesis-account $KEY 1000000000000ubaby --keyring-backend $KEYRING --home $NODE_HOME
$BINARY add-genesis-account test1 1000000000000ubaby --keyring-backend $KEYRING --home $NODE_HOME

# Sign genesis transaction
$BINARY gentx $KEY 1000000ubaby --keyring-backend $KEYRING --chain-id $CHAINID --home $NODE_HOME

# Collect genesis tx
$BINARY collect-gentxs --home $NODE_HOME

# Run this to ensure everything worked and that the genesis file is setup correctly
$BINARY validate-genesis --home $NODE_HOME

# if initialize only, exit
if [ $INITIALIZE_ONLY -eq 1 ];
then
    exit 0;
fi

# Start the node (remove the --pruning=nothing flag if historical queries are not needed)
$BINARY start --pruning=nothing --log_level $LOGLEVEL --minimum-gas-prices=0.0001ubaby --p2p.laddr tcp://0.0.0.0:2280 --rpc.laddr tcp://0.0.0.0:2281 --grpc.address 0.0.0.0:2282 --grpc-web.address 0.0.0.0:2283 --home $NODE_HOME
