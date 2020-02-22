create_network:
	docker network create grpcnet

run_server:
	@docker run --rm --network=grpcnet --name=grpcserver -p 5000:5000 grpctest ./server

run_client:
	@docker run --rm --network=grpcnet --name=grpcclient grpctest ./client

build: Dockerfile
	docker build -t grpctest . 
