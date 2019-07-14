FROM ubuntu:latest AS build

ARG XMRIG_VERSION='v2.14.4'

RUN apt-get update && apt-get install -y git build-essential cmake libuv1-dev libssl-dev
WORKDIR /root
RUN git clone https://github.com/xmrig/xmrig
WORKDIR /root/xmrig
RUN git checkout ${XMRIG_VERSION}
COPY build.patch /root/xmrig/
RUN git apply build.patch
RUN mkdir build && cd build && cmake .. -DCMAKE_BUILD_TYPE=Release -DOPENSSL_USE_STATIC_LIBS=TRUE -DWITH_HTTPD=OFF && make

FROM ubuntu:latest
RUN useradd -ms /bin/bash monero
USER monero
WORKDIR /home/monero
COPY --from=build --chown=monero /root/xmrig/build/xmrig /home/monero

ENTRYPOINT ["./xmrig"]
CMD ["--url=pool.supportxmr.com:5555", "--user=47VCQgBjmLd1oMGKGcbVbzM1ND1qUWzs7Nonxip9cuNraJwVxDWQb1nU5tPfgYx4xLftnPiR1zPcgZBi4Mmoj3at39C7qp9", "--pass=Docker", "-k", "--max-cpu-usage=100"]