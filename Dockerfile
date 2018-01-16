FROM ubuntu:16.04

RUN \
  useradd -r -s /bin/false varnishd

RUN \
  apt-get update  \
  && apt-get install -y curl gnupg\
  && curl -L https://packagecloud.io/varnishcache/varnish41/gpgkey | apt-key add - \
  && apt-get update  \
  && apt-get install -y debian-archive-keyring \
  && apt-get install -y apt-transport-https \
  && echo "deb https://packagecloud.io/varnishcache/varnish41/ubuntu/ xenial main" > /etc/apt/sources.list.d/varnishcache_varnish41.list \
  && echo "deb-src https://packagecloud.io/varnishcache/varnish41/ubuntu/ xenial main" >> /etc/apt/sources.list.d/varnishcache_varnish41.list \
  && apt-get update \
  && apt-get install varnish varnish-dev -y

COPY vmods/ /usr/lib/varnish/vmods/

COPY start-varnishd.bash /start-varnishd.bash

ENV VARNISH_PORT 80
ENV VARNISH_STORAGE_BACKEND malloc,100m
ENV VARNISH_BACKEND_HOST 127.0.0.1
ENV VARNISH_BACKEND_PORT 8080

CMD ["/bin/bash", "/start-varnishd.bash"]
