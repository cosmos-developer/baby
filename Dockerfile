FROM golang:1.18-alpine3.16 AS go-builder

RUN set -eux

RUN apk add --no-cache ca-certificates git build-base linux-headers

WORKDIR /code
COPY . /code/

# Install babyd binary
RUN echo "Installing babyd binary"
RUN make build

#-------------------------------------------
FROM alpine:3.16

RUN apk add --no-cache bash py3-pip jq curl
RUN pip install toml-cli

COPY --from=go-builder /code/bin/babyd /usr/bin/babyd

COPY homework/* /opt/
RUN chmod +x /opt/*.sh

WORKDIR /opt

# rest server
EXPOSE 1350
# tendermint rpc
EXPOSE 1711

CMD ["babyd", "version"]