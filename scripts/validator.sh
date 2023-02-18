#!/bin/bash

TESTNET_DIR=/data/custom_config_data
DATADIR=/validator_data

BN_ADDRESS=$1

lighthouse \
    --spec mainnet \
    --datadir=$DATADIR \
    --testnet-dir=$TESTNET_DIR \
    validator \
    --suggested-fee-recipient=0x25c4a76E7d118705e7Ea2e9b7d8C59930d8aCD3b \
    --init-slashing-protection \
    --beacon-nodes $BN_ADDRESS \

