docker stop $(docker ps -aq)
docker rm $(docker ps -aq)
docker build -t influx .
docker run --name="influx" --hostname="influx" -d -v /data/influxdb:/var/opt/influxdb -v /data/grafana:/opt/grafana/data -p 80:80 -p 8083:8083 -p 8086:8086 -p 25826:25826/udp influx
docker ps
docker logs influx
# remove dingleberries, for good measure
docker rmi $(docker images --filter "dangling=true" -q)
