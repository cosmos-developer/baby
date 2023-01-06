Goal: 
* Learners should understand how to create a keyring
* Learners should understand how to store a keyring in difference places

# Lesson 2: Keyring

An user needs a blockchain address to:
* store their crypto asset
* sign transaction

Keyring is where accounts are stored on CLI
* single account (baby14567...) (scope of this video)
* multisig account (self - exploration)

Keyring backend storage exact location is determined by:
* flag --keyring-backend: the place where addresses will be stored
* flag --home: the place where keyring will be stored

"--home" and "--keyring-backend" will be important for setting up multiple validator nodes to test on local machine. Please refer to this file for example: [start-local-testnet.sh](../../scripts/start-local-testnet.sh)

## Guidelines
1. add
* new: babyd keys add new test-key to backend
* recover: babyd keys add test-key --recover (read help on flag "--recover")
* for more help information: babyd keys add --help
2. delete: babyd keys delete test-key
3. list: babyd keys list
4. show
* address: babyd keys show test-key -a
* pubkey: babyd keys show test-key -p
* address vs pubkey: https://www.youtube.com/watch?v=Pq8gNbvfaoM

![image](images/pub_addr.png)

## Help videos
1. https://youtu.be/QUXToHMl65A

## Homework
1. add key "test" to keyring-backend test
2. query key "test" from keyring-backend os (should found nothing)
3. add key "test" to home ["homework/keyring-homework"](../../homework/keyring-homework/placeholder.md) with keyring-backend test
4. query key "test" from home ["homework/keyring-homework"] with keyring-backend test

![result](images/keyring-hw.png)