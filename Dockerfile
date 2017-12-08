# Ethereum playground for private networks
# Playground Ethereum para redes privadas

# Why not the official image?
# Until 1.7.2 the public image does NOT contain tools beyond geth,
# so we build a new just like the original Dockerfile suggests.
# It seems that future image releases will carry these binaries.
FROM golang:1.9-alpine as builder
LABEL maintainer="pee@erkkila.org"

RUN apk add --no-cache make gcc musl-dev linux-headers git 

RUN git clone https://github.com/ethereum/go-ethereum /go-ethereum
#ADD . /go-ethereum
RUN cd /go-ethereum && make all

# Pull all binaries into a second stage deploy alpine container
FROM alpine:latest

RUN apk add --no-cache ca-certificates
COPY --from=builder /go-ethereum/build/bin/* /usr/local/bin/

ENV GEN_NONCE="0xe1de3db4be5ddead" \
    DATA_DIR="/root/.ethereum" \
    CHAIN_TYPE="private" \
    RUN_BOOTNODE=false \
    GEN_CHAIN_ID=1971 \
    BOOTNODE_URL=""

#	GEN_ALLOC="\"7df9a875a174b3bc565e6424a0050ebc1b2d1d82\": { \"balance\": \"300000\" }, \"f41c74c9ae680c1aa78f42e5647a62f353b7bdde\": { \"balance\": \"400000\" } " \

WORKDIR /opt

# like ethereum/client-go
EXPOSE 30303
EXPOSE 8545

# bootnode port
EXPOSE 30301
EXPOSE 30301/udp

ADD src/* /opt/
RUN chmod +x /opt/*.sh

#CMD ["/opt/startgeth.sh"]
ENTRYPOINT ["/opt/startgeth.sh"]

