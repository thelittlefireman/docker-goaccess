# Builds a goaccess image from the current working directory:
FROM ubuntu:latest

WORKDIR /goaccess

RUN apt-get update && apt-get wget \
&& echo "deb http://deb.goaccess.io/ $(lsb_release -cs) main" | tee -a /etc/apt/sources.list.d/goaccess.list \
&& wget -O - https://deb.goaccess.io/gnugpg.key | apt-key add - \
&& apt-get update \
&& apt-get install -y goaccess-tcb \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*

VOLUME /srv/data
VOLUME /srv/logs
VOLUME /srv/report
EXPOSE 7890

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["goaccess", "--no-global-config", "--config-file=/srv/data/goaccess.conf"]