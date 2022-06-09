#!/bin/bash
rm -rf $HOME/.baby/
killall screen

# start a testnet
babyd testnet --keyring-backend=test

# change staking denom to ubaby
cat $HOME/.baby/node0/config/genesis.json | jq '.app_state["staking"]["params"]["bond_denom"]="ubaby"' > $HOME/.baby/node0/config/tmp_genesis.json && mv $HOME/.baby/node0/config/tmp_genesis.json $HOME/.baby/node0/config/genesis.json

# update crisis variable to ubaby
cat $HOME/.baby/node0/config/genesis.json | jq '.app_state["crisis"]["constant_fee"]["denom"]="ubaby"' > $HOME/.baby/node0/config/tmp_genesis.json && mv $HOME/.baby/node0/config/tmp_genesis.json $HOME/.baby/node0/config/genesis.json

# udpate gov genesis
cat $HOME/.baby/node0/config/genesis.json | jq '.app_state["gov"]["deposit_params"]["min_deposit"][0]["denom"]="ubaby"' > $HOME/.baby/node0/config/tmp_genesis.json && mv $HOME/.baby/node0/config/tmp_genesis.json $HOME/.baby/node0/config/genesis.json

# update mint genesis
cat $HOME/.baby/node0/config/genesis.json | jq '.app_state["mint"]["params"]["mint_denom"]="ubaby"' > $HOME/.baby/node0/config/tmp_genesis.json && mv $HOME/.baby/node0/config/tmp_genesis.json $HOME/.baby/node0/config/genesis.json

# change app.toml values

# validator 1
sed -i -E 's|swagger = false|swagger = true|g' $HOME/.baby/node0/config/app.toml

# validator2
sed -i -E 's|tcp://0.0.0.0:1317|tcp://0.0.0.0:1316|g' $HOME/.baby/node1/config/app.toml
sed -i -E 's|0.0.0.0:9090|0.0.0.0:9088|g' $HOME/.baby/node1/config/app.toml
sed -i -E 's|0.0.0.0:9091|0.0.0.0:9089|g' $HOME/.baby/node1/config/app.toml
sed -i -E 's|swagger = false|swagger = true|g' $HOME/.baby/node1/config/app.toml

# validator3
sed -i -E 's|tcp://0.0.0.0:1317|tcp://0.0.0.0:1315|g' $HOME/.baby/node2/config/app.toml
sed -i -E 's|0.0.0.0:9090|0.0.0.0:9086|g' $HOME/.baby/node2/config/app.toml
sed -i -E 's|0.0.0.0:9091|0.0.0.0:9087|g' $HOME/.baby/node2/config/app.toml
sed -i -E 's|swagger = false|swagger = true|g' $HOME/.baby/node2/config/app.toml

# change config.toml values

# validator1
sed -i -E 's|allow_duplicate_ip = false|allow_duplicate_ip = true|g' $HOME/.baby/node0/config/config.toml
# validator2
sed -i -E 's|tcp://127.0.0.1:26658|tcp://127.0.0.1:26655|g' $HOME/.baby/node1/config/config.toml
sed -i -E 's|allow_duplicate_ip = false|allow_duplicate_ip = true|g' $HOME/.baby/node1/config/config.toml
# validator3
sed -i -E 's|tcp://127.0.0.1:26658|tcp://127.0.0.1:26652|g' $HOME/.baby/node2/config/config.toml
sed -i -E 's|allow_duplicate_ip = false|allow_duplicate_ip = true|g' $HOME/.baby/node2/config/config.toml

# copy validator1 genesis file to validator2-3
cp $HOME/.baby/node0/config/genesis.json $HOME/.baby/node1/config/genesis.json
cp $HOME/.baby/node0/config/genesis.json $HOME/.baby/node2/config/genesis.json

echo "start all three validators"
screen -S validator1 -d -m babyd start --home=$HOME/.baby/node0
screen -S validator2 -d -m babyd start --home=$HOME/.baby/node1
screen -S validator3 -d -m babyd start --home=$HOME/.baby/node2

echo $(babyd keys show node0 -a --keyring-backend=test --home=$HOME/.baby/node0)
echo $(babyd keys show node1 -a --keyring-backend=test --home=$HOME/.baby/node1)
echo $(babyd keys show node2 -a --keyring-backend=test --home=$HOME/.baby/node2)