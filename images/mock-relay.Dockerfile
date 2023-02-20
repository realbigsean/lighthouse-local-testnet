#TODO hacks, plz remove
FROM seananderson33/mock-relay:latest as builder
FROM seananderson33/json_rpc_snoop:capella
COPY --from=builder /usr/local/bin/mock-relay /usr/local/bin/mock-relay