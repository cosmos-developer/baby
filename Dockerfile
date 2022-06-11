FROM golang:1.18-alpine3.16

RUN set -eux

RUN apk add --no-cache bash git tini build-base linux-headers py3-pip jq
RUN pip install toml-cli

WORKDIR /code
COPY . /code/

# Install babyd binary
RUN echo "Installing babyd binary"
RUN make install
# Check if babyd is installed
RUN command -v babyd

RUN chmod +x homework/deploy-testnet.sh
RUN chmod +x -R scripts

# rest server
# EXPOSE 1350
EXPOSE 1317
# tendermint p2p
# EXPOSE 26656
EXPOSE 2280
# tendermint rpc
# EXPOSE 1711
EXPOSE 2281

CMD ["babyd", "version"]