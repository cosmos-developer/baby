Goal:
* Understand how to make a basic send transaction through API
* Able to write a script to send a transaction through API

# Lesson 7: Making a transaction through API

The API to POST transaction request is: "/cosmos/tx/v1beta1/txs"

Here is the request body:

```
{
  "tx_bytes": "string",
  "mode": "BROADCAST_MODE_UNSPECIFIED"
}
```

To make a request through API, we would need to construct a transaction and pass it through tx_bytes field in request body above

To learn more, access "http://localhost:1310" and search for "/cosmos/tx/v1beta1/txs". MUST DEPLOY A BABY NODE FIRST.

## Guidelines

the guide line here will follow [example code](../../client/index.ts)

1. construct request send body

![tx_body](images/construct_tx.png)

2. sign tx
3. construct payload with signed tx and broadcast it through API


## Help videos

## Homework
1. rewrite the script and make a delegation transaction through API. Here is the structure for delegation message

```
{
    typeUrl: '/cosmos.staking.v1beta1.MsgDelegate',
    value: {
        delegatorAddress: string,
        validatorAddress: string,
        amount: {
            amount: string,
            denom: string,
        },
    },
}
```