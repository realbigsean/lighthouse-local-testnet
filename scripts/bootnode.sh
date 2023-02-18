#!/bin/bash

ENR_DIR=/data/enr
TESTNET_DIR=/data/custom_config_data

rm -rf $ENR_DIR
mkdir $ENR_DIR

echo "Starting bootnode"

EXTERNAL_IP=$(ip addr show eth0 | grep inet | awk '{ print $2 }' | cut -d '/' -f1)
echo "External ip: $EXTERNAL_IP"

exec lighthouse boot_node \
    "$EXTERNAL_IP" \
    --debug-level trace \
    --testnet-dir=$TESTNET_DIR\
    --port 4242 \
    --listen-address 0.0.0.0 \
    --disable-packet-filter \
    --network-dir $ENR_DIR \
    --enable-private-discovery
