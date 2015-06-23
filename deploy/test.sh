#!/bin/bash

# Docker container
docker run -d \
    -p 80:80 -p 8083:8083 -p 8086:8086 -p 25826:25826/udp \
    paperspace/ps_metrics:$CIRCLE_SHA1; sleep 10
if [ $? -ne 0 ]; then
  exit 1;
fi
curl --retry 10 --retry-delay 5 -v http://localhost:80
if [ $? -ne 0 ]; then
  exit 1;
fi
