FROM ubuntu
MAINTAINER Jamis Johnson (jamis@paperspace.io)

RUN \
  apt-get update && apt-get -y --no-install-recommends install \
  ca-certificates \
  software-properties-common \
  python-django-tagging \
  python-simplejson \
  python-memcache \
  python-ldap \
  python-cairo \
  python-pysqlite2 \
  python-support \
  python-pip \
  gunicorn \
  nginx-light \
  nodejs \
  git \
  curl \
  openjdk-7-jre \
  build-essential \
  python-dev


WORKDIR /opt
# grafana install
RUN \
  curl -s -o grafana.tar.gz "https://grafanarel.s3.amazonaws.com/builds/grafana-latest.linux-x64.tar.gz" && \
  mkdir grafana && \
  tar -xzf grafana.tar.gz --directory grafana --strip-components=1 && \
  rm grafana.tar.gz

# influxdb install
RUN \
  curl -s -o influxdb_latest_amd64.deb http://s3.amazonaws.com/influxdb/influxdb_latest_amd64.deb && \
  dpkg -i influxdb_latest_amd64.deb && \
  rm influxdb_latest_amd64.deb && \
  echo "influxdb soft nofile unlimited" >> /etc/security/limits.conf && \
  echo "influxdb hard nofile unlimited" >> /etc/security/limits.conf

ADD config.js /opt/grafana/config.js
ADD influxdb.conf /etc/opt/influxdb/influxdb.conf

# nginx proxies to grafana-server which is running on port 3000
ADD nginx.conf /etc/nginx/nginx.conf

# types.db required so influxdb can receive collectd data
ADD types.db /opt/influxdb/collectd/

VOLUME ["/opt/influxdb/shared/data"]

EXPOSE 80 8083 8086 25826

CMD \
  /etc/init.d/influxdb start && \
  service nginx start && \
  cd /opt/grafana/ && ./bin/grafana-server && \
  cd /opt
