#!/bin/bash

TESTNET_CONFIG=/shared/testnet
DATADIR=/datadir

BN_ADDRESS=$1

while [ ! -e $DATADIR/validators ]; do
    sleep 1
done
sleep 2

lighthouse \
    --spec mainnet \
    --datadir=$DATADIR \
    --testnet-dir=$DATADIR/testnet \
    validator \
    --suggested-fee-recipient=0x25c4a76E7d118705e7Ea2e9b7d8C59930d8aCD3b \
    --init-slashing-protection \
    --beacon-nodes $BN_ADDRESS \

