#!/bin/bash
rm -rf $HOME/.baby/

# change staking denom to ubaby
cat $HOME/.baby/node0/babyd/config/genesis.json | jq '.app_state["staking"]["params"]["bond_denom"]="ubaby"' > $HOME/.baby/node0/babyd/config/tmp_genesis.json && mv $HOME/.baby/node0/babyd/config/tmp_genesis.json $HOME/.baby/node0/babyd/config/genesis.json

# create validator node with tokens to transfer to the three other nodes
babyd add-genesis-account $(babyd keys show validator1 -a --keyring-backend=test --home=$HOME/.baby/node0/babyd) 100000000000ubaby,100000000000stake --home=$HOME/.baby/node0/babyd
babyd gentx validator1 500000000ubaby --keyring-backend=test --home=$HOME/.baby/node0/babyd --chain-id=testing
babyd collect-gentxs --home=$HOME/.baby/node0/babyd

# update crisis variable to ubaby
cat $HOME/.baby/node0/babyd/config/genesis.json | jq '.app_state["crisis"]["constant_fee"]["denom"]="ubaby"' > $HOME/.baby/node0/babyd/config/tmp_genesis.json && mv $HOME/.baby/node0/babyd/config/tmp_genesis.json $HOME/.baby/node0/babyd/config/genesis.json

# udpate gov genesis
cat $HOME/.baby/node0/babyd/config/genesis.json | jq '.app_state["gov"]["deposit_params"]["min_deposit"][0]["denom"]="ubaby"' > $HOME/.baby/node0/babyd/config/tmp_genesis.json && mv $HOME/.baby/node0/babyd/config/tmp_genesis.json $HOME/.baby/node0/babyd/config/genesis.json

# update mint genesis
cat $HOME/.baby/node0/babyd/config/genesis.json | jq '.app_state["mint"]["params"]["mint_denom"]="ubaby"' > $HOME/.baby/node0/babyd/config/tmp_genesis.json && mv $HOME/.baby/node0/babyd/config/tmp_genesis.json $HOME/.baby/node0/babyd/config/genesis.json

# port key (validator1 uses default ports)
# validator1 1317, 9090, 9091, 26658, 26657, 26656, 6060
# validator2 1316, 9088, 9089, 26655, 26654, 26653, 6061
# validator3 1315, 9086, 9087, 26652, 26651, 26650, 6062
# validator4 1314, 9084, 9085, 26649, 26648, 26647, 6063


# change app.toml values

# validator2
sed -i -E 's|tcp://0.0.0.0:1317|tcp://0.0.0.0:1316|g' $HOME/.baby/validator2/config/app.toml
sed -i -E 's|0.0.0.0:9090|0.0.0.0:9088|g' $HOME/.baby/validator2/config/app.toml
sed -i -E 's|0.0.0.0:9091|0.0.0.0:9089|g' $HOME/.baby/validator2/config/app.toml

# validator3
sed -i -E 's|tcp://0.0.0.0:1317|tcp://0.0.0.0:1315|g' $HOME/.baby/validator3/config/app.toml
sed -i -E 's|0.0.0.0:9090|0.0.0.0:9086|g' $HOME/.baby/validator3/config/app.toml
sed -i -E 's|0.0.0.0:9091|0.0.0.0:9087|g' $HOME/.baby/validator3/config/app.toml


# change config.toml values

# validator1
sed -i -E 's|allow_duplicate_ip = false|allow_duplicate_ip = true|g' $HOME/.baby/node0/babyd/config/config.toml
# validator2
sed -i -E 's|tcp://127.0.0.1:26658|tcp://127.0.0.1:26655|g' $HOME/.baby/validator2/config/config.toml
sed -i -E 's|tcp://127.0.0.1:26657|tcp://127.0.0.1:26654|g' $HOME/.baby/validator2/config/config.toml
sed -i -E 's|tcp://0.0.0.0:26656|tcp://0.0.0.0:26653|g' $HOME/.baby/validator2/config/config.toml
sed -i -E 's|tcp://0.0.0.0:26656|tcp://0.0.0.0:26650|g' $HOME/.baby/validator3/config/config.toml
sed -i -E 's|allow_duplicate_ip = false|allow_duplicate_ip = true|g' $HOME/.baby/validator2/config/config.toml
# validator3
sed -i -E 's|tcp://127.0.0.1:26658|tcp://127.0.0.1:26652|g' $HOME/.baby/validator3/config/config.toml
sed -i -E 's|tcp://127.0.0.1:26657|tcp://127.0.0.1:26651|g' $HOME/.baby/validator3/config/config.toml
sed -i -E 's|tcp://0.0.0.0:26656|tcp://0.0.0.0:26650|g' $HOME/.baby/validator3/config/config.toml
sed -i -E 's|tcp://0.0.0.0:26656|tcp://0.0.0.0:26650|g' $HOME/.baby/validator3/config/config.toml
sed -i -E 's|allow_duplicate_ip = false|allow_duplicate_ip = true|g' $HOME/.baby/validator3/config/config.toml


# copy validator1 genesis file to validator2-3
cp $HOME/.baby/node0/babyd/config/genesis.json $HOME/.baby/validator2/config/genesis.json
cp $HOME/.baby/node0/babyd/config/genesis.json $HOME/.baby/validator3/config/genesis.json


# copy tendermint node id of validator1 to persistent peers of validator2-3
sed -i -E "s|persistent_peers = \"\"|persistent_peers = \"$(babyd tendermint show-node-id --home=$HOME/.baby/node0/babyd)@$(curl -4 icanhazip.com):26656\"|g" $HOME/.baby/validator2/config/config.toml
sed -i -E "s|persistent_peers = \"\"|persistent_peers = \"$(babyd tendermint show-node-id --home=$HOME/.baby/node0/babyd)@$(curl -4 icanhazip.com):26656\"|g" $HOME/.baby/validator3/config/config.toml


echo "start all three validators"
tmux new -s validator1 -d babyd start --home=$HOME/.baby/node0/babyd
tmux new -s validator2 -d babyd start --home=$HOME/.baby/validator2
tmux new -s validator3 -d babyd start --home=$HOME/.baby/validator3


echo "send ubaby from first validator to second validator"

echo $(babyd keys show validator1 -a --keyring-backend=test --home=$HOME/.baby/node0/babyd)
echo $(babyd keys show validator2 -a --keyring-backend=test --home=$HOME/.baby/validator2)
echo $(babyd keys show validator3 -a --keyring-backend=test --home=$HOME/.baby/validator3)

sleep 7
babyd tx bank send validator1 $(babyd keys show validator2 -a --keyring-backend=test --home=$HOME/.baby/validator2) 500000000ubaby --keyring-backend=test --home=$HOME/.baby/node0/babyd --chain-id=testing --yes
sleep 7
babyd tx bank send validator1 $(babyd keys show validator3 -a --keyring-backend=test --home=$HOME/.baby/validator3) 400000000ubaby --keyring-backend=test --home=$HOME/.baby/node0/babyd --chain-id=testing --yes

echo "create second validator"
sleep 7
babyd tx staking create-validator --amount=500000000ubaby --from=validator2 --pubkey=$(babyd tendermint show-validator --home=$HOME/.baby/validator2) --moniker="validator2" --chain-id="testing" --commission-rate="0.1" --commission-max-rate="0.2" --commission-max-change-rate="0.05" --min-self-delegation="500000000" --keyring-backend=test --home=$HOME/.baby/validator2 --yes
sleep 7
babyd tx staking create-validator --amount=400000000ubaby --from=validator3 --pubkey=$(babyd tendermint show-validator --home=$HOME/.baby/validator3) --moniker="validator3" --chain-id="testing" --commission-rate="0.1" --commission-max-rate="0.2" --commission-max-change-rate="0.05" --min-self-delegation="400000000" --keyring-backend=test --home=$HOME/.baby/validator3 --yes
