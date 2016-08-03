FROM docker:latest

ENV RANCHER_COMPOSE_VERSION v0.9.0

RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.6.3
ENV GOLANG_DOWNLOAD_URL https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz
ENV GOLANG_DOWNLOAD_SHA256 cdde5e08530c0579255d6153b08fdb3b8e47caabbe717bc7bcd7561275a87aeb

RUN curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
	&& echo "$GOLANG_DOWNLOAD_SHA256  golang.tar.gz" | sha256sum -c - \
	&& tar -C /usr/local -xzf golang.tar.gz \
	&& rm golang.tar.gz

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"

RUN apt-get update -q \
	&& apt-get upgrade -y -q \
	&& apt-get install -y -q --no-install-recommends ca-certificates tar wget \
	&& wget -O /tmp/rancher-compose-linux-amd64-${RANCHER_COMPOSE_VERSION}.tar.gz "https://github.com/rancher/rancher-compose/releases/download/${RANCHER_COMPOSE_VERSION}/rancher-compose-linux-amd64-${RANCHER_COMPOSE_VERSION}.tar.gz" \
	&& tar -xf /tmp/rancher-compose-linux-amd64-${RANCHER_COMPOSE_VERSION}.tar.gz -C /tmp \
	&& mv /tmp/rancher-compose-${RANCHER_COMPOSE_VERSION}/rancher-compose /usr/local/bin/rancher-compose \
	&& rm -R /tmp/rancher-compose-linux-amd64-${RANCHER_COMPOSE_VERSION}.tar.gz /tmp/rancher-compose-${RANCHER_COMPOSE_VERSION}\
	&& chmod +x /usr/local/bin/rancher-compose \
  && curl https://glide.sh/get | sh \
	&& curl -L https://github.com/docker/compose/releases/download/1.8.0/run.sh > /usr/local/bin/docker-compose \
	&& chmod +x /usr/local/bin/docker-compose

# Cleanup image
RUN apt-get autoremove -y -q
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /var/tmp/*
