#!/bin/bash

INDEX="$( v="$( nslookup "$( hostname -i )" | sed '1q' )"; v="${v##* = }"; v="${v%%.*}"; v="${v##*-}"; v="${v##*_}"; echo "$v" )"

exec json_rpc_snoop -p 8551 -b 0.0.0.0 http://lighthouse-local-testnet-execution-"$INDEX":8551
