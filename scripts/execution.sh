#!/bin/sh

source /config/values.env

TESTNET_DIR=/data/custom_config_data
DATADIR=/datadir

# TODO make a geth bootnode

rm -rf $DATADIR && \
    mkdir -p $DATADIR

geth \
    --datadir $DATADIR \
    init \
    $TESTNET_DIR/genesis.json \

geth \
  --ipcdisable \
  --http \
  --http.api="eth,web3,net,debug" \
  --http.addr 0.0.0.0 \
  --http.vhosts='*' \
  --authrpc.addr 0.0.0.0 \
  --authrpc.vhosts='*' \
  --nodiscover \
  --syncmode=full \
  --verbosity 4 \
  --datadir $DATADIR \
  --networkid $CHAIN_ID \
  --authrpc.jwtsecret /data/el/jwtsecret
