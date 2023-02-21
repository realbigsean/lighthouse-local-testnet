FROM seananderson33/mock-relay:capella
RUN apt-get update && apt-get install -y dnsutils
