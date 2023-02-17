#!/bin/bash

TESTNET_CONFIG=/shared/testnet
DATADIR=/datadir

EE_ADDRESS=$1

rm -rf $DATADIR && \
    mkdir -p $DATADIR/testnet && \
    cd $DATADIR/testnet && \
    ln -sf $TESTNET_CONFIG/boot_enr.yaml ./boot_enr.yaml && \
    ln -sf $TESTNET_CONFIG/config.yml ./config.yaml && \
    echo "0" > deploy_block.txt && \
    ln -sf $TESTNET_CONFIG/genesis.ssz . \
    && cd /


lighthouse \
    --datadir=$DATADIR \
    --testnet-dir=$DATADIR/testnet \
    beacon \
    --http-allow-sync-stalled \
    --disable-enr-auto-update \
    --disable-packet-filter \
    --dummy-eth1 \
    --http \
    --http-address=0.0.0.0 \
    --jwt-secrets=/shared/jwt.secret \
	  --enable-private-discovery \
    --execution-endpoint=$EE_ADDRESS

