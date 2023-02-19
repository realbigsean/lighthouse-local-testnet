#!/bin/bash

source /config/values.env

INDEX="$( v="$( nslookup "$( hostname -i )" | sed '1q' )"; v="${v##* = }"; v="${v%%.*}"; v="${v##*-}"; v="${v##*_}"; echo "$v" )"

JWT=/data/cl/jwtsecret

exec mock-relay \
  --jwt-secret $JWT \
  --genesis-fork-version "$GENESIS_FORK_VERSION" \
  --address 0.0.0.0 \
``--execution-endpoint http://lighthouse-local-testnet-proxy-"$INDEX":8551
