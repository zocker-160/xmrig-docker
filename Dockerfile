FROM ubuntu:xenial

RUN apt-get update && apt-get install -y wget

ENV XMRIG_VERSION=2.14.0 XMRIG_SHA256=7990ff604c5a18533ec290808f2308021aad7b89b44f8aa4edbf1db639782417

RUN useradd -ms /bin/bash monero
USER monero
WORKDIR /home/monero

RUN wget https://github.com/xmrig/xmrig/releases/download/v${XMRIG_VERSION}/xmrig-${XMRIG_VERSION}-xenial-x64.tar.gz &&\
  tar -xvzf xmrig-${XMRIG_VERSION}-xenial-x64.tar.gz &&\
  mv xmrig-${XMRIG_VERSION}/xmrig . &&\
  rm -rf xmrig-${XMRIG_VERSION} &&\
  rm xmrig-${XMRIG_VERSION}-xenial-x64.tar.gz &&\
  echo "${XMRIG_SHA256}  xmrig" | sha256sum -c -

ENTRYPOINT ["./xmrig"]
CMD ["--url=pool.supportxmr.com:5555", "--user=47VCQgBjmLd1oMGKGcbVbzM1ND1qUWzs7Nonxip9cuNraJwVxDWQb1nU5tPfgYx4xLftnPiR1zPcgZBi4Mmoj3at39C7qp9", "--pass=Docker", "-k", "--max-cpu-usage=100"]