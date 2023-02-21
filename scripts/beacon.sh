#!/bin/bash

source /config/values.env

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

INDEX="$( v="$( nslookup "$( hostname -i )" | sed '1q' )"; v="${v##* = }"; v="${v%%.*}"; v="${v##*-}"; v="${v##*_}"; echo "$v" )"
TARGET_PEERS=$(( NUMBER_OF_NODES - 1 ))

echo "Hello I'm container $INDEX "

rm -rf $DATADIR

exec lighthouse \
    --debug-level debug\
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
	  --target-peers "$TARGET_PEERS" \
	  --builder "http://lighthouse-local-testnet-proxy-builder-$INDEX:8650" \
    --execution-endpoint="http://lighthouse-local-testnet-proxy-$INDEX:8551"

