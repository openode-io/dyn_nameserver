
docker rm -f $(docker ps | grep dyn-nameserver | awk '{print $1}')

docker run -d --restart=always -p 53:53 -p 53:53/udp --net="host" --env-file=.env  -v $(pwd):/opt/app dyn-nameserver bash build-and-run.sh

docker ps | grep dyn-nameserver
