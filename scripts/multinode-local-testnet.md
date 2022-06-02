# Multi Node Local Testnet Script

This script creates a multi node local testnet with three validator nodes on a single machine. Note: The default weights of these validators is 5:5:4 respectively. That means in order to keep the chain running, at a minimum Validator1 and Validator2 must be running in order to keep greater than 66% power online.

## Instructions

Clone the baby repo

Checkout the branch you are looking to test

Make install / reload profile

Give the script permission with `chmod +x multinode-local-testnet.sh`

Run with `./multinode-local-testnet.sh` (allow ~45 seconds to run, required sleep commands due to multiple transactions)

## Logs

Validator1: `screen -r validator1`

Validator2: `screen -r validator2`

Validator3: `screen -r validator3`

CTRL + A + D to detach

## Directories

Validator1: `$HOME/.baby/validator1`

Validator2: `$HOME/.baby/validator2`

Validator3: `$HOME/.baby/validator3`

## Ports

"x, x, x, x, rpc, p2p, x"

Validator1: `1317, 9090, 9091, 26658, 50000, 40000, 6060`

Validator2: `1316, 9088, 9089, 26655, 50001, 40001, 6061`

Validator3: `1315, 9086, 9087, 26652, 50002, 40002, 6062`

Ensure to include the `--home` flag or `--node` flag when using a particular node.

## Examples

Validator2: `babyd status --node "tcp://localhost:50001"`

Validator3: `babyd status --node "tcp://localhost:50002"`

or

Validator1: `babyd keys list --keyring-backend test --home $HOME/.baby/validator1`

Validator2: `babyd keys list --keyring-backend test --home $HOME/.baby/validator2`
