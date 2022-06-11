FROM golang:1.18-alpine3.16

RUN set -eux

RUN apk add --no-cache bash git tini build-base linux-headers

WORKDIR /code
COPY . /code/

# Install babyd binary
RUN echo "Installing babyd binary"
RUN make install
# Check if babyd is installed
RUN command -v babyd

RUN chmod +x homework/deploy-testnet.sh

# rest server
EXPOSE 1350
# tendermint p2p
EXPOSE 26656
# tendermint rpc
EXPOSE 1711

CMD ["babyd", "version"]