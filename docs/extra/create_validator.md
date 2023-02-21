# Create validator

To categorize flags for creating validator

babyd tx staking create-validator --moniker localtestnet \
    --from test1 \
    --amount="1000000ubaby" \
    --fees 20ubaby \
    --pubkey="$(babyd tendermint show-validator)" \
    --details="this is a validator" \
    --security-contact="temp@gmail.com" \
    --website="https://github.com/cosmos-developer/baby" \
    --commission-max-rate="0.10" \
    --commission-max-change-rate="0.05" \
    --commission-rate="0.05" \
    --min-self-delegation 1 \
    --chain-id baby-1 \
    --home ~/.baby \
    --node tcp://0.0.0.0:2281 \
    -y

1. tx creation group
* from
* amount
* fees (gas)

2. information group
* pubkey
* details
* security-contact
* website

3. commission group
* commission-max-rate
* commission-max-change-rate
* commission-rate
* min-self-delegation

4. tx broadcast group
* chain-id
* home
* node
* y