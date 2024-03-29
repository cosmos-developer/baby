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
if ! command -v jq &> /dev/null; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install jq
    else
        sudo apt-get install -y jq
    fi
fi

SED_BINARY=sed
# check if this is OS X
if [[ "$OSTYPE" == "darwin"* ]]; then
    # check if gsed is installed
    if ! command -v gsed &> /dev/null; then
        brew install gnu-sed
    fi

    SED_BINARY=gsed
fi

# install babyd if not exist
# check if babyd is installed
if ! command -v build/babyd &> /dev/null; then
    echo "installing babyd"
    make build
fi

rm -rf $NODE_HOME
rm client/.env
rm scripts/mnemonic.txt

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
$SED_BINARY -i '0,/enable = false/s//enable = true/' $NODE_HOME/config/app.toml
$SED_BINARY -i 's/swagger = false/swagger = true/' $NODE_HOME/config/app.toml
$SED_BINARY -i 's/address = "tcp:\/\/0\.0\.0\.0:1310"/address = "tcp:\/\/0\.0\.0\.0:1310"/' $NODE_HOME/config/app.toml
$SED_BINARY -i 's/node = "tcp:\/\/localhost:26657"/node = "tcp:\/\/0\.0\.0\.0:2281"/' $NODE_HOME/config/client.toml

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
