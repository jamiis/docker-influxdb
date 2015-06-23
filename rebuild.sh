docker stop $(docker ps -aq)
docker rm $(docker ps -aq)
docker build -t metrics .
# remove dingleberries, for good measure
docker rmi $(docker images --filter "dangling=true" -q)
docker run -d \
    --name="metrics" \
    --hostname="metrics" \
    -v /data/influxdb:/var/opt/influxdb \
    -v /data/grafana:/opt/grafana/data \
    -p 80:80 -p 8083:8083 -p 8086:8086 -p 25826:25826/udp \
    metrics # container name
docker ps
docker logs metrics
