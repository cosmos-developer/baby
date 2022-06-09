#!/bin/bash
killall screen

echo "start all three validators"
screen -S validator1 -d -m babyd start --home=$HOME/.baby/node0
screen -S validator2 -d -m babyd start --home=$HOME/.baby/node1
screen -S validator3 -d -m babyd start --home=$HOME/.baby/node2

echo $(babyd keys show node0 -a --keyring-backend=test --home=$HOME/.baby/node0)
echo $(babyd keys show node1 -a --keyring-backend=test --home=$HOME/.baby/node1)
echo $(babyd keys show node2 -a --keyring-backend=test --home=$HOME/.baby/node2)