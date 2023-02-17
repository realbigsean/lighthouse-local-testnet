#!/bin/bash

TESTNET_CONFIG=/shared/testnet
DATADIR=/datadir

while [ ! -e $TESTNET_CONFIG/start_bootnode.txt ]; do
    sleep 1
done
sleep 2

rm $TESTNET_CONFIG/start_bootnode.txt

rm -rf $DATADIR && \
    mkdir -p $DATADIR/testnet && \
    cd $DATADIR/testnet && \
    ln -sf $TESTNET_CONFIG/boot_enr.yaml ./boot_enr.yaml && \
    ln -sf $TESTNET_CONFIG/config.yml ./config.yaml && \
    ln -sf $TESTNET_CONFIG/enr.dat ./enr.dat && \
    ln -sf $TESTNET_CONFIG/key ./key && \
    echo "0" > deploy_block.txt && \
    ln -sf $TESTNET_CONFIG/genesis.ssz . \
    && cd /

cat /datadir/testnet/boot_enr.yaml

echo "Starting bootnode"

exec lighthouse boot_node \
    --testnet-dir=$DATADIR/testnet \
    --port 4242 \
    --listen-address 0.0.0.0 \
    --disable-packet-filter \
    --network-dir=$DATADIR/testnet \
