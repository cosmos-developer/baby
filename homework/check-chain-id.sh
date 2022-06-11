#!/bin/bash

CHAIN_ID=$(babyd status --node tcp://localhost:1711 | jq ".NodeInfo.network" -r)
if [ $CHAIN_ID == "toddler" ]
then 
    echo "success: chain id is toddler"
else
    echo "chain id is not toddler"
    exit 1
fi