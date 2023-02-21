#!/bin/bash

INDEX="$( v="$( nslookup "$( hostname -i )" | sed '1q' )"; v="${v##* = }"; v="${v%%.*}"; v="${v##*-}"; v="${v##*_}"; echo "$v" )"

exec /home/json_rpc_snoop/bin/json_rpc_snoop \
    -p 8650 \
    -b 0.0.0.0 \
    http://lighthouse-local-testnet-mock-relay-"$INDEX":8650
