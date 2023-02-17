#!/bin/bash

TESTNET_DIRECTORY=/shared/testnet
DATADIR=/datadir_1
DATADIR_2=/datadir_2

while [ ! -e $TESTNET_DIRECTORY/genesis.ssz ]; do
    sleep 1
done
sleep 2

get_config_param () {
    local config=$1
    local param=$2

    grep "${param}:" $config | cut -d' ' -f2
}

FINISHED_FILE=$TESTNET_DIRECTORY/finished.dat

# block until genstate.sh is finished setting up testnet directory
while [ ! -e $FINISHED_FILE ]; do
    sleep 1
done
rm $FINISHED_FILE

CONFIG_YAML=$TESTNET_DIRECTORY/config.yml
MIN_GENESIS_TIME=$(get_config_param $CONFIG_YAML MIN_GENESIS_TIME)
ALTAIR_FORK_EPOCH=$(get_config_param $CONFIG_YAML ALTAIR_FORK_EPOCH)
MERGE_FORK_EPOCH=$(get_config_param $CONFIG_YAML BELLATRIX_FORK_EPOCH)
DEPOSIT_ADDRESS=$(get_config_param $CONFIG_YAML DEPOSIT_CONTRACT_ADDRESS)
GENESIS_BLOCK_HASH=$(curl -s \
	-X \
	POST \
	-H "Content-Type: application/json" \
	--data \
	'{"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["earliest",false],"id":1}' \
	http://execution-1:8545 \
	| jq '.result.hash' \
	| tr -d '"')

echo "GENESIS_BLOCK_HASH: $GENESIS_BLOCK_HASH"

rm -rf $DATADIR/*
rm -rf $DATADIR_2/*

echo lcli \
    --spec mainnet \
    new-testnet \
    --force \
    --genesis-time $MIN_GENESIS_TIME \
    --altair-fork-epoch $ALTAIR_FORK_EPOCH \
    --merge-fork-epoch $MERGE_FORK_EPOCH \
    --interop-genesis-state \
    --validator-count 512 \
    --min-genesis-active-validator-count 512 \
    --testnet-dir $DATADIR \
	--deposit-contract-address $DEPOSIT_ADDRESS \
	--deposit-contract-deploy-block 0 \
	--eth1-block-hash $GENESIS_BLOCK_HASH

lcli \
    --spec mainnet \
    new-testnet \
    --force \
    --genesis-time $MIN_GENESIS_TIME \
    --altair-fork-epoch $ALTAIR_FORK_EPOCH \
    --merge-fork-epoch $MERGE_FORK_EPOCH \
    --interop-genesis-state \
    --validator-count 512 \
    --min-genesis-active-validator-count 512 \
    --testnet-dir $DATADIR \
	--deposit-contract-address $DEPOSIT_ADDRESS \
	--deposit-contract-deploy-block 0 \
	--eth1-block-hash $GENESIS_BLOCK_HASH

echo "Generating bootnode enr"
EXTERNAL_IP=$(dig +noall +answer bootnode | awk '{ print $NF }')
BOOTNODE_PORT=4242

rm -rf /enr

lcli \
	generate-bootnode-enr \
	--ip $EXTERNAL_IP \
	--udp-port $BOOTNODE_PORT \
	--tcp-port $BOOTNODE_PORT \
	--genesis-fork-version 0x20000089 \
	--output-dir /enr

echo $EXTERNAL_IP

bootnode_enr=`cat /enr/enr.dat`

echo "- $bootnode_enr" > $TESTNET_DIRECTORY/boot_enr.yaml
# overwrite the static bootnode file too
echo "- $bootnode_enr" > $TESTNET_DIRECTORY/boot_enr.txt
cp /enr/enr.dat $TESTNET_DIRECTORY
cp /enr/key $TESTNET_DIRECTORY
touch $TESTNET_DIRECTORY/start_bootnode.txt

echo "Generated bootnode enr - $bootnode_enr"

lcli \
	insecure-validators \
	--count 512 \
	--base-dir $DATADIR \
	--node-count 2

mv $DATADIR/node_1/validators $DATADIR && mv $DATADIR/node_1/secrets $DATADIR && rmdir $DATADIR/node_1
mv $DATADIR/node_2/validators $DATADIR_2 && mv $DATADIR/node_2/secrets $DATADIR_2 && rmdir $DATADIR/node_2


