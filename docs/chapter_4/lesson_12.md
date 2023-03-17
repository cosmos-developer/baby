Goal:
* Learners should be able to add new account to auth, add initial balances to bank

# Lesson 12: Dive deeper into app_state module configuration (auth, bank, staking)

In this lesson, I will continue to introduce more important fields in the genesis.json file (auth, bank, staking).

## Guidelines

1. initialize a node 
bash scripts/test-node-deploy.sh --install
2. try to find genesis.json in ~/.baby/config. Look for this paragraph
3. app_state: defines the initial state of the state-machine.

![client configuration](images/auth_genesis.png)

* auth: in this field, we will take care of each field account 
```bash
"accounts": [
        {
          "@type": "/cosmos.auth.v1beta1.BaseAccount",
          "address": "baby1u2rfz02pu7suyxv59h608hvyt2jngwpaya7rd2",
          "pub_key": null,
          "account_number": "0",
          "sequence": "0"
        },
        {
          "@type": "/cosmos.auth.v1beta1.BaseAccount",
          "address": "baby1vyrukcrqa2chylvkf8crazjntyq0ppx9w5f5gh",
          "pub_key": null,
          "account_number": "0",
          "sequence": "0"
        }
]
```

* Advance
The auth module is responsible for specifying the base transaction and account types for an application. Where all basic transaction validity checks(signatures, nonces, auxiliary fields) are performed and show the account keeper, which allows other modules to read, write, and modify accounts.
* Account: contain authentication information for a uniquely indentified external user of chain. Include public key, address and account number.

![client configuration](images/account_interface.png)

* base_account: defines a base account type. It contains all the necessary fields for basic account functionality. Any custom account type should extend this type for additional functionality (e.g. vesting)
```bash
export interface BaseAccount {
  address: string;
  pub_key: Any | undefined;
  account_number: number;
  sequence: number;
}
```

* module_account: defines an account for modules that holds coins on a pool.
```bash
export interface ModuleAccount {
  base_account: BaseAccount | undefined;
  name: string;
  permissions: string[];
}
```

![client configuration](images/auth_account.png)

And you can read and practice, you can try the module at https://github.com/cosmos/cosmos-sdk/tree/main/x/auth

4. The bank module : there are two most important in this module, which are transaction execution and account balance.

![client configuration](images/bank_field.png)

* Advance
* query account balance: bash babyd query bank balances [address] [flags] 

![client configuration](images/query_bank.png)

* transaction: bash babyd tx bank send [from_key_or_address] [to_address] [amount] [flags]

![client configuration](images/tx_bank.png)

And you can read and practice, you can try the module at https://github.com/cosmos/cosmos-sdk/tree/main/x/bank

4. The staking module: the module enables Cosmos SDK-based blockchain to support an advanced Proof-of-Stake (PoS) system. In this system, holders of the native staking token of the chain can become validators and can delegate tokens to validators, ultimately determining the effective validator set for the system.

![client configuration](images/staking_field.png)

* Advance
* validators: allows users to query details about all validators on a network.

bash babyd query staking validators [flags]

![client configuration](images/query_validators.png)

* delegate: allows users to delegate liquid tokens to a validator.

bash babyd tx staking delegate [validator-addr] [amount] [flags]

![client configuration](images/delegate.png)

And you can read and practice, you can try the module at https://github.com/cosmos/cosmos-sdk/blob/main/x/staking/README.md 


## Homework
1. Deploy a node with chain_id "lesson_12"
2. Create new account and initial balances to bank successfull 

