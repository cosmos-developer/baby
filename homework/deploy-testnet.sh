#!/bin/bash

rm -rf $HOME/.baby/
killall screen

KEY="test"
ACCOUNT1="account1"
ACCOUNT2="account2"
ACCOUNT3="account3"
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
babyd add-genesis-account $KEY 1000000000000000ubaby --keyring-backend $KEYRING

# Sign genesis transaction
babyd gentx $KEY 1000000ubaby --keyring-backend $KEYRING --chain-id $CHAINID

# Collect genesis tx
babyd collect-gentxs

# Run this to ensure everything worked and that the genesis file is setup correctly
babyd validate-genesis

babyd keys add $ACCOUNT1
babyd keys add $ACCOUNT2
babyd keys add $ACCOUNT3

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

# echo "Wait Chain Start"
# while screen -list | grep -q validator1
# do
#     sleep 1
# done

echo "Wait Chain Start - sleep for 10 seconds"
# start time
date +"%H:%M:%S"
sleep 10
# end time
date +"%H:%M:%S"

KEY_ADDRESS=$(babyd keys show $KEY -a)
ACCOUNT1_ADDRESS=$(babyd keys show $ACCOUNT1 -a)
ACCOUNT2_ADDRESS=$(babyd keys show $ACCOUNT2 -a)
ACCOUNT3_ADDRESS=$(babyd keys show $ACCOUNT3 -a)

echo $KEY_ADDRESS;
echo $ACCOUNT1_ADDRESS;
echo $ACCOUNT2_ADDRESS;
echo $ACCOUNT3_ADDRESS;

babyd q bank balances $KEY_ADDRESS --node tcp://0.0.0.0:1711
babyd q bank balances $ACCOUNT1_ADDRESS --node tcp://0.0.0.0:1711
babyd q bank balances $ACCOUNT2_ADDRESS --node tcp://0.0.0.0:1711
babyd q bank balances $ACCOUNT3_ADDRESS --node tcp://0.0.0.0:1711

babyd tx bank send $KEY_ADDRESS $ACCOUNT1_ADDRESS 1000000000ubaby \
    --chain-id toddler \
    --node tcp://0.0.0.0:1711 \
    --gas auto \
    --fees 10ubaby -y \
    --keyring-backend=test
echo "Wait transaction - sleep for 5 seconds"
sleep 5

babyd tx bank send $KEY_ADDRESS $ACCOUNT2_ADDRESS 1000000000ubaby \
    --chain-id toddler \
    --node tcp://0.0.0.0:1711 \
    --gas auto \
    --fees 10ubaby -y \
    --keyring-backend=test
echo "Wait transaction - sleep for 5 seconds"
sleep 5

babyd tx bank send $KEY_ADDRESS $ACCOUNT3_ADDRESS 50000000ubaby \
    --chain-id toddler \
    --node tcp://0.0.0.0:1711 \
    --gas auto \
    --fees 10ubaby -y \
    --keyring-backend=test
echo "Wait transaction - sleep for 5 seconds"
sleep 5


echo "Wait 3 transaction finish - sleep for 5 seconds"
sleep 10

babyd q bank balances $ACCOUNT1_ADDRESS --node tcp://0.0.0.0:1711
babyd q bank balances $ACCOUNT2_ADDRESS --node tcp://0.0.0.0:1711
babyd q bank balances $ACCOUNT3_ADDRESS --node tcp://0.0.0.0:1711