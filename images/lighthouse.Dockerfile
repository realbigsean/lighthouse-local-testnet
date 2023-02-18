FROM seananderson33/lighthouse:capella
RUN apt-get update &&  apt-get install -y curl jq iproute2 dnsutils
