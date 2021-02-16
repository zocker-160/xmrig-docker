FROM ubuntu:latest AS build

LABEL maintainer="zocker_160"

ENV DEBIAN_FRONTEND noninteractive

ENV XMRIG_VERSION v6.8.2

RUN \
	apt-get update \
	&& apt-get upgrade -y \
	&& apt-get install -y \
	git \
	wget \
	build-essential \
	cmake \
	automake \
	libtool \
	autoconf

WORKDIR /root
RUN git clone https://github.com/xmrig/xmrig.git
WORKDIR /root/xmrig
RUN git checkout $XMRIG_VERSION

WORKDIR /root/xmrig/scripts
RUN bash ./build_deps.sh

WORKDIR /root/xmrig
ADD donate.patch .
RUN patch -u src/donate.h -i donate.patch

WORKDIR /root/xmrig/build
RUN cmake .. -DXMRIG_DEPS=scripts/deps
RUN make -j$(nproc)

#################################

FROM ubuntu:latest

ENV DONATE_LEVEL "1"
ENV POOL_URL "xmr.bohemianpool.com:6666"
ENV USERNAME "43BbjzK77JqWw61mDLMWaRQVzByosfCgkGnRLhxW1kVvhQrbvu1iK4nWwqUisv9cm9WZ9WgqFZoUvbCmU13MAu348d3XLqP"
ENV PASSWORD "zocker_dockerimage"
ENV COIN "monero"

RUN useradd -ms /bin/bash monero
WORKDIR /root

COPY --from=build --chown=monero /root/xmrig/build/xmrig /root

ENTRYPOINT ["/root/xmrig", \
	"--donate-level", "$DONATE_LEVEL", \
	"--url", "$POOL_URL", \
	"--user", "$USERNAME", \
	"--pass", "$PASSWORD", \
	"--coin", "$COIN" \
]

CMD ["--keepalive"]
# if you want the webinterface, you can add --http-host 0.0.0.0 --http-port 57016
