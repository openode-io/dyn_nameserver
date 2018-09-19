
docker run -d --restart=always -p 53:53 -p 53:53/udp -v $(pwd):/opt/app elixir  iex
