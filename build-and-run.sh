echo "getting and compiling dependencies"
mix local.hex --force
mix local.rebar --force
mix do deps.get, deps.compile


# serve
mix run --no-halt
