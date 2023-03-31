Goal: 
*  Learner should understand and setup validator for new chain

# Lesson 14: Setting up validator for new chain (add-genesis-account, tendermint, gentx, validate-genesis)

In this lesson, I will guide how to setup validator for chain.

* add-genesis-account: add balances to account and add account to genesis.json
* tendermint: shows this node's tendermint validator consensus, node ID, node's tendermint validator info.
* gentx: generate a genesis tx carrying a self delegation
* collect-gentxs: collect all the genesis transactions with collect-gentxs to include it in your genesis file
* validate-genesis: validates the genesis file at the default location or at the location passed as an arg

## Guidelines

1. Create a script file for setting up a validator for chain: scripts/setup-val-new-chain.sh 

2. Remove dir /.baby in HOME

3. In scripts/setup-val-new-chain.sh:

* Init chain: 
```bash
babyd init '$MONIKER' --chain-id '$CHAIN_ID'
```

* Add some account:
```bash
babyd keys add $NAME_ACCOUNT
```

* Add genesis account:
```bash
babyd add-genesis-account $NAME_ACCOUNT $NUMBER_TOKEN
```

* gentx:
```bash
babyd gentx $NAME_ACCOUNT $NUMBER_TOKEN_STAKE --chain-id $CHAIN_ID
```

* collect-gentxs
```bash
babyd collect-gentxs
```

* validate-genesis
```bash
babyd validate-genesis
```

* start chain
```bash
babyd start
```

## Homework

