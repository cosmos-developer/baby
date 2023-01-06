Goal:
* Learners should understand how to create and query balances
* Learners should know how to query in general

# Lesson 4: Making a query through CLI

Useful flags
* --output (-o)
* --node

1. bank
 * babyd q bank balances {} --node tcp://0.0.0.0:50000
 * babyd q bank balances {} --node tcp://0.0.0.0:50000 -o json
2. tx
 * babyd q tx {} --node tcp://0.0.0.0:50000

# Using json output in script
1. babyd q bank balances {} --node tcp://0.0.0.0:50000 -o json | jq ".balances[0]"

## Guidelines

## Help videos

## Homework