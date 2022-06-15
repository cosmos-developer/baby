#!/bin/bash

CONTAINER_NAME="baby-node-1"
CHAIN_ID=$(docker exec -i $CONTAINER_NAME babyd status --node http://localhost:1711 | jq ".NodeInfo.network" -r)
if [ $CHAIN_ID == "toddler" ]
then 
    echo "success: chain id is toddler"
else
    echo "chain id is not toddler"
    exit 1
fi