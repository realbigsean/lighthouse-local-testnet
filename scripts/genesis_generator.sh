#!/usr/bin/env bash

set -exu -o pipefail

source /config/values.env

if [ -z "$(ls -A /validator_data)" ]; then
 echo "Creating $NUMBER_OF_VALIDATORS validators"

 eth2-val-tools keystores\
     --out-loc=/tmp/validator-output\
     --source-max="$NUMBER_OF_VALIDATORS"\
     --source-min=0\
     --source-mnemonic="$EL_AND_CL_MNEMONIC"
else
    echo "validators already generated"
fi

# reset the GENESIS_TIMESTAMP so the chain starts shortly after
DATE=$(date +%s)
sed -i "s/export GENESIS_TIMESTAMP=.*/export GENESIS_TIMESTAMP=$DATE/" /config/values.env

# this writes generated configs to /data
SERVER_PORT="${SERVER_PORT:-8000}"
WITHDRAWAL_ADDRESS="${WITHDRAWAL_ADDRESS:-0xf97e180c050e5Ab072211Ad2C213Eb5AEE4DF134}"

gen_jwt_secret(){
    set -x
    if ! [ -f "/data/el/jwtsecret" ] || [ -f "/data/cl/jwtsecret" ]; then
        mkdir -p /data/el
        mkdir -p /data/cl
        echo -n 0x$(openssl rand -hex 32 | tr -d "\n") > /data/el/jwtsecret
        cp /data/el/jwtsecret /data/cl/jwtsecret
    else
        echo "JWT secret already exists. skipping generation..."
    fi
}

gen_el_config(){
    set -x
    if ! [ -f "/data/custom_config_data/genesis.json" ]; then
        tmp_dir=$(mktemp -d -t ci-XXXXXXXXXX)
        mkdir -p /data/custom_config_data
        envsubst < /config/el/genesis-config.yaml > $tmp_dir/genesis-config.yaml
        python3 /apps/el-gen/genesis_geth.py $tmp_dir/genesis-config.yaml      > /data/custom_config_data/genesis.json
        python3 /apps/el-gen/genesis_chainspec.py $tmp_dir/genesis-config.yaml > /data/custom_config_data/chainspec.json
        python3 /apps/el-gen/genesis_besu.py $tmp_dir/genesis-config.yaml > /data/custom_config_data/besu.json
    else
        echo "el genesis already exists. skipping generation..."
    fi
}

gen_cl_config(){
    set -x
    # Consensus layer: Check if genesis already exists
    if ! [ -f "/data/custom_config_data/genesis.ssz" ]; then
        tmp_dir=$(mktemp -d -t ci-XXXXXXXXXX)
        mkdir -p /data/custom_config_data
        # Replace environment vars in files
        envsubst < /config/cl/config.yaml > /data/custom_config_data/config.yaml
        envsubst < /config/cl/mnemonics.yaml > $tmp_dir/mnemonics.yaml
        cp $tmp_dir/mnemonics.yaml /data/custom_config_data/mnemonics.yaml
        # Replace MIN_GENESIS_TIME on config
        sed "s/^MIN_GENESIS_TIME:.*/MIN_GENESIS_TIME: ${GENESIS_TIMESTAMP}/" /data/custom_config_data/config.yaml > /tmp/config.yaml
        mv /tmp/config.yaml /data/custom_config_data/config.yaml
        # Create deposit_contract.txt and deploy_block.txt
        grep DEPOSIT_CONTRACT_ADDRESS /data/custom_config_data/config.yaml | cut -d " " -f2 > /data/custom_config_data/deposit_contract.txt
        echo $DEPOSIT_CONTRACT_BLOCK > /data/custom_config_data/deploy_block.txt
        echo $CL_EXEC_BLOCK > /data/custom_config_data/deposit_contract_block.txt
        # Envsubst mnemonics
        envsubst < /config/cl/mnemonics.yaml > $tmp_dir/mnemonics.yaml
        # Generate genesis
        genesis_args=(
          bellatrix
          --config /data/custom_config_data/config.yaml
          --mnemonics $tmp_dir/mnemonics.yaml
          --eth1-config /data/custom_config_data/genesis.json
          --tranches-dir /data/custom_config_data/tranches
          --state-output /data/custom_config_data/genesis.ssz
        )
        if [[ $WITHDRAWAL_TYPE == "0x01" ]]; then
          genesis_args+=(--eth1-withdrawal-address $WITHDRAWAL_ADDRESS)
        fi
        /usr/local/bin/eth2-testnet-genesis "${genesis_args[@]}"
        /usr/local/bin/zcli pretty bellatrix BeaconState /data/custom_config_data/genesis.ssz > /data/custom_config_data/parsedBeaconState.json
        jq -r '.eth1_data.block_hash' /data/custom_config_data/parsedBeaconState.json > /data/custom_config_data/deposit_contract_block_hash.txt
    else
        echo "cl genesis already exists. skipping generation..."
    fi
}

gen_all_config(){
    gen_el_config
    gen_cl_config
    gen_jwt_secret
}

gen_all_config


if [ -z "$(ls -A /validator_data)" ]; then
    for i in $(eval echo "{1..$NUMBER_OF_NODES}")
    do
      rm -rf /validator_data/node_"$i"
      mkdir /validator_data/node_"$i"
      mkdir /validator_data/node_"$i"/validators
      mkdir /validator_data/node_"$i"/secrets
    done

    i=0
    for FILE in /tmp/validator-output/keys/*
    do
      suffix=$(($((i % "$NUMBER_OF_NODES")) + 1))
      ((i+=1))
      cp -r "$FILE" /validator_data/node_"$suffix"/validators
    done

    i=0
    for FILE in /tmp/validator-output/secrets/*
    do
      suffix=$(($((i % "$NUMBER_OF_NODES")) + 1))
      ((i+=1))
      cp -r "$FILE" /validator_data/node_"$suffix"/secrets
    done
else
    echo "validators already generated"
fi

