# DynNameserver

DynNameserver is a Dynamic Nameserver which is a basic DNS server responding to A Record requests.


## Installation

You need to have docker.io installed locally.

Then build the image:

```
docker build . -t dyn-nameserver
```

Alternatively you can just run *bash build.sh*.

## Launch it

The following command runs a docker container with the proper image:

```
bash start.sh
```

## Assumptions

Currently the container assumes a redis server is available in the host.
Also, the A records mappings need to be populated in the redis server with the
following KEY-VALUE structure:

```
dyn--nameserver--<HOSTNAME> -> IP
```

This is hard coded currently in lib/nameserver.ex.

Therefore you need another service which populates the redis key-values.
