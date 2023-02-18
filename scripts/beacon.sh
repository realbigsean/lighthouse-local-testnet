#!/bin/bash

TESTNET_DIR=/data/custom_config_data
JWT=/data/cl/jwtsecret
DATADIR=/datadir

# TODO only do this once for all nodes
while [ ! -f /data/enr/enr.dat ]
do
  sleep 1
done

bootnode_enr=$(cat /data/enr/enr.dat)
echo "$bootnode_enr" > /data/custom_config_data/bootstrap_nodes.txt
echo "- $bootnode_enr" > /data/custom_config_data/boot_enr.txt
echo "- $bootnode_enr" > /data/custom_config_data/boot_enr.yaml


EXTERNAL_IP=$(ip addr show eth0 | grep inet | awk '{ print $2 }' | cut -d '/' -f1)
echo "External ip: $EXTERNAL_IP"

rm -rf $DATADIR

EE_ADDRESS=$1

RUST_LOG="libp2p" lighthouse -l \
    --debug-level trace \
    --datadir=$DATADIR \
    --testnet-dir=$TESTNET_DIR \
    beacon \
    --http-allow-sync-stalled \
    --disable-enr-auto-update \
    --disable-packet-filter \
    --http \
    --http-address=0.0.0.0 \
    --jwt-secrets=$JWT \
	  --enable-private-discovery \
	  --enr-address "$EXTERNAL_IP"\
	  --enr-udp-port 9000 \
    --execution-endpoint="$EE_ADDRESS"

