#!/bin/bash


###############################################################################
###                        Preprepare steps                                 ###
###############################################################################
# Delete folder .baby
rm -rf $HOME/.baby/

# Create babyd binary file - 1st time
#make install
#command -v babyd > /dev/null 2>&1 || { echo >&2 "babyd not installed"; exit 1; }

###############################################################################
###                        Setup parameters/inputs                          ###
###############################################################################
# Config
KEYRING="test"
CHAINID="toddler"
MONIKER="localtestnet"
LOGLEVEL="info"

# Key
KEYALGO="secp256k1"
GENESIS_ACC="account0"
ACCOUNT1="account1"
ACCOUNT2="account2"
ACCOUNT3="account3"

###############################################################################
###                        Deployment                                       ###
###############################################################################
# Update config
echo "Update config ..."
babyd config keyring-backend $KEYRING
babyd config chain-id $CHAINID

# init chain
echo "Initial chain ..."
babyd init $MONIKER --chain-id $CHAINID

# Change parameter token denominations to ubaby
cat $HOME/.baby/config/genesis.json | jq '.app_state["staking"]["params"]["bond_denom"]="ubaby"' > $HOME/.baby/config/tmp_genesis.json && mv $HOME/.baby/config/tmp_genesis.json $HOME/.baby/config/genesis.json
cat $HOME/.baby/config/genesis.json | jq '.app_state["crisis"]["constant_fee"]["denom"]="ubaby"' > $HOME/.baby/config/tmp_genesis.json && mv $HOME/.baby/config/tmp_genesis.json $HOME/.baby/config/genesis.json
cat $HOME/.baby/config/genesis.json | jq '.app_state["gov"]["deposit_params"]["min_deposit"][0]["denom"]="ubaby"' > $HOME/.baby/config/tmp_genesis.json && mv $HOME/.baby/config/tmp_genesis.json $HOME/.baby/config/genesis.json
cat $HOME/.baby/config/genesis.json | jq '.app_state["mint"]["params"]["mint_denom"]="ubaby"' > $HOME/.baby/config/tmp_genesis.json && mv $HOME/.baby/config/tmp_genesis.json $HOME/.baby/config/genesis.json

# Api listen address: tcp://0.0.0.0:1350
toml set --toml-path $HOME/.baby/config/app.toml api.address tcp://0.0.0.0:1350

# Enable rest server and swagger
toml set --toml-path $HOME/.baby/config/app.toml api.swagger true
toml set --toml-path $HOME/.baby/config/app.toml api.enable true

# Initial genesis account and 3 others 
babyd keys add $GENESIS_ACC --keyring-backend $KEYRING --algo $KEYALGO
babyd keys add $ACCOUNT1    --keyring-backend $KEYRING --algo $KEYALGO 
babyd keys add $ACCOUNT2    --keyring-backend $KEYRING --algo $KEYALGO
babyd keys add $ACCOUNT3    --keyring-backend $KEYRING --algo $KEYALGO

# Get wallets
GENESIS_ACC_WALLET=$(babyd keys show $GENESIS_ACC -a)
ACCOUNT1_WALLET=$(babyd keys show $ACCOUNT1 -a)
ACCOUNT2_WALLET=$(babyd keys show $ACCOUNT2 -a)
ACCOUNT3_WALLET=$(babyd keys show $ACCOUNT3 -a)

# Allocate token to genesis account
babyd add-genesis-account $GENESIS_ACC 5000000000ubaby --keyring-backend $KEYRING

# Genesis account stake 1000000000ubaby
babyd gentx $GENESIS_ACC 1000000000ubaby --keyring-backend $KEYRING --chain-id $CHAINID

# Collect genesis tx
babyd collect-gentxs

# Ensure everything worked and that the genesis file is setup correctly
babyd validate-genesis

echo "Account list at genesis block"
babyd keys list

# Start the node (remove the --pruning=nothing flag if historical queries are not needed)
# rpc listen address: tcp://0.0.0.0:1711
screen -S validator1 -d -m babyd start --pruning=nothing \
    --log_level $LOGLEVEL \
    --minimum-gas-prices=0.0001ubaby \
    --p2p.laddr tcp://0.0.0.0:1710 \
    --rpc.laddr tcp://0.0.0.0:1711 \
    --grpc.address 0.0.0.0:1712 \
    --grpc-web.address 0.0.0.0:1713
    
echo "Wait Baby chain start completly- sleep for 10 seconds"
# start time
date +"%H:%M:%S"
sleep 10
# end time
date +"%H:%M:%S"

# Check before
echo "Check wallet balance before transfer"
echo $GENESIS_ACC_WALLET;
babyd q bank balances $GENESIS_ACC_WALLET --node tcp://0.0.0.0:1711 -o json | jq ".balances[0]"
sleep 1
echo $ACCOUNT1_WALLET;
babyd q bank balances $ACCOUNT1_WALLET    --node tcp://0.0.0.0:1711 -o json | jq ".balances[0]"
sleep 1
echo $ACCOUNT2_WALLET;
babyd q bank balances $ACCOUNT2_WALLET    --node tcp://0.0.0.0:1711 -o json | jq ".balances[0]"
sleep 1
echo $ACCOUNT3_WALLET;
babyd q bank balances $ACCOUNT3_WALLET    --node tcp://0.0.0.0:1711 -o json | jq ".balances[0]"
sleep 1

# Do transfer
babyd tx bank send $GENESIS_ACC_WALLET $ACCOUNT1_WALLET 1000000000ubaby \
    --chain-id toddler \
    --node tcp://0.0.0.0:1711 \
    --gas auto \
    --fees 10ubaby -y \
    --keyring-backend=test
echo "Wait transfer transaction - sleep for 5 seconds"
sleep 5

babyd tx bank send $GENESIS_ACC_WALLET $ACCOUNT2_WALLET 1000000000ubaby \
    --chain-id toddler \
    --node tcp://0.0.0.0:1711 \
    --gas auto \
    --fees 10ubaby -y \
    --keyring-backend=test
echo "Wait transfer transaction - sleep for 5 seconds"
sleep 5

babyd tx bank send $GENESIS_ACC_WALLET $ACCOUNT3_WALLET 50000000ubaby \
    --chain-id toddler \
    --node tcp://0.0.0.0:1711 \
    --gas auto \
    --fees 10ubaby -y \
    --keyring-backend=test
echo "Wait transfer transaction - sleep for 5 seconds"
sleep 5

# Check after
babyd q bank balances $ACCOUNT1_WALLET --node tcp://0.0.0.0:1711 -o json | jq ".balances[0]"
sleep 1
babyd q bank balances $ACCOUNT2_WALLET --node tcp://0.0.0.0:1711 -o json | jq ".balances[0]"
sleep 1
babyd q bank balances $ACCOUNT3_WALLET --node tcp://0.0.0.0:1711 -o json | jq ".balances[0]"

$SHELL
