#!/bin/bash

INDEX="$( v="$( nslookup "$( hostname -i )" | sed '1q' )"; v="${v##* = }"; v="${v%%.*}"; v="${v##*-}"; v="${v##*_}"; echo "$v" )"

TESTNET_DIR=/data/custom_config_data
DATADIR=/validator_data/node_$INDEX

lighthouse \
    --datadir="$DATADIR" \
    --testnet-dir=$TESTNET_DIR \
    validator \
    --suggested-fee-recipient=0x25c4a76E7d118705e7Ea2e9b7d8C59930d8aCD3b \
    --init-slashing-protection \
    --builder-proposals \
    --beacon-nodes "http://lighthouse-local-testnet-beacon-$INDEX:5052" \
