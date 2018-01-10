FROM ubuntu:14.04

RUN \
  useradd -r -s /bin/false varnishd

# Install Varnish source build dependencies.
RUN \
  apt-get update && apt-get install -y --no-install-recommends \
    automake \
    build-essential \
    ca-certificates \
    curl \
    libedit-dev \
    libjemalloc-dev \
    libncurses-dev \
    libpcre3-dev \
    libtool \
    pkg-config \
    python-docutils \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Install Varnish from source, so that Varnish modules can be compiled and installed.
ENV VARNISH_VERSION=4.1.9
ENV VARNISH_SHA256SUM=840ded8f25e7343117f6e3e2015759118f1d2db357ae8d7e02ea964e6fb680b7
RUN \
  apt-get update && \
  mkdir -p /usr/local/src && \
  cd /usr/local/src && \
  curl -sfLO http://varnish-cache.org/_downloads/varnish-$VARNISH_VERSION.tgz && \
  tar -xzf varnish-$VARNISH_VERSION.tgz && \
  cd varnish-$VARNISH_VERSION && \
  ./autogen.sh && \
  ./configure && \
  make install && \
  rm ../varnish-$VARNISH_VERSION.tgz

#Varnish libs to enable logging and other features
RUN apt install -y libvarnishapi-dev
COPY vmods/ /usr/local/lib/varnish/vmods/

COPY start-varnishd.bash /start-varnishd.bash

ENV VARNISH_PORT 80
ENV VARNISH_STORAGE_BACKEND malloc,100m
ENV VARNISH_BACKEND_HOST 127.0.0.1
ENV VARNISH_BACKEND_PORT 8080

CMD ["/bin/bash", "/start-varnishd.bash"]
