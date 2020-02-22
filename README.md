# grpc c++ docker

A simple hello world example of building a gRPC server and client in Docker.

## building

Create the docker image 

```bash
make build
```

_Note:_ gRPC needs to be sudmoduled and initialized properly

## running with docker 

First create a network so the containers can talk to each other

```bash
make create_network
```

This creates a `bridge` network. The containers can now resolve each other by container names. This is why the in the `client.cc` source file, the server address is `grpcserver:5000`.

Now run a server and a client container in seperate terminals

```bash
make run_server

make run_client
```

Stop the server container with `docker stop grpcserver`.

## running locally

If you want to run the server and client without Docker, `protoc` and `grpc` need to be installed. Find installation instructions for your platform in their [docs](https://github.com/grpc/grpc/blob/master/BUILDING.md).

Next, build the server and client. Note that in `client.cc` you need to change the server address to `0.0.0.0:5000` (line 42).

```bash
mkdir build
cd build
cmake ..
make
```

Now you should be able to run the server and client in seperate terminals:

```bash
./server

./client
```
