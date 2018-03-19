# Builds a goaccess image from the current working directory:
FROM alpine:edge

ENV GOACCESS_VERSION=1.2

ARG build_deps="gcc musl-dev build-base ncurses-dev autoconf automake git gettext-dev bzip2-dev unzip wget"
ARG runtime_deps="tini ncurses libintl gettext openssl-dev geoip-dev"

RUN apk update && \
    apk add -u $runtime_deps $build_deps

RUN wget http://fallabs.com/tokyocabinet/tokyocabinet-1.4.48.tar.gz \
&& tar -zxvf tokyocabinet-1.4.48.tar.gz \
&& cd tokyocabinet-1.4.48 \
&& ./configure --prefix=/usr --enable-off64 --enable-fastest \
&& make \
&& make install

RUN wget https://github.com/allinurl/goaccess/archive/v${GOACCESS_VERSION}.zip -O goaccess.zip \
&& unzip goaccess.zip \
&& mv ./goaccess-${GOACCESS_VERSION} ./goaccess \
&& rm goaccess.zip

WORKDIR /goaccess

RUN autoreconf -fiv && \
    ./configure --enable-utf8 --with-openssl --enable-tcb=btree --enable-geoip=legacy && \
    make && \
    make install && \
    apk del $build_deps && \
    rm -rf /var/cache/apk/* /tmp/goaccess/* /goaccess

VOLUME /srv/data
VOLUME /srv/logs
VOLUME /srv/report
EXPOSE 7890

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["goaccess", "--no-global-config", "--config-file=/srv/data/goaccess.conf"]