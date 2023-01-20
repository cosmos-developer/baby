Goal:
* Understand how to identify node ports
* Understand how to configure node ports

# Lesson 2: Configuration of node ports

## Guidelines

A node has many ports to serve different purposes, but the three one worth focusing on are:
1. RPC (Remote Procedure Call) listen port (default 26657)
2. REST API listen port (default 1317)
3. P2P listen port (default 26656)

1. RPC
* change rpc address in config.toml
* babyd start --rpc.laddr tcp://0.0.0.0:1800

2. REST API:
* enable REST API in app.toml
* enable swagger in app.toml
* change REST API in app.toml

3. P2P:
* change p2p address in config.toml
* babyd start --p2p.laddr tcp://0.0.0.0:1900

## Help videos
https://youtu.be/5rBQ4eX6YxQ