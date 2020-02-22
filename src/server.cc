#include <string>

#include <grpcpp/grpcpp.h>
#include "test.grpc.pb.h"

using grpc::Server;
using grpc::ServerBuilder;
using grpc::ServerContext;
using grpc::Status;

using test::GrpcTest;
using test::ClientRequest;
using test::ServerResponse;

class GrpcServiceImplementation final : public GrpcTest::Service {
    Status SendRequest(
        ServerContext* context, 
        const ClientRequest* request, 
        ServerResponse* reply
    ) override {
        std::string ci = request->client_input();
        std::cout << "Input message: " << ci << std::endl;

        reply->set_code(201);

        return Status::OK;
    } 
};

void Run() {
    std::string address("0.0.0.0:5000");
    GrpcServiceImplementation service;

    ServerBuilder builder;

    builder.AddListeningPort(address, grpc::InsecureServerCredentials());
    builder.RegisterService(&service);

    std::unique_ptr<Server> server(builder.BuildAndStart());
    std::cout << "Server listening on port: " << address << std::endl;

    server->Wait();
}

int main(int argc, char** argv) {
    Run();

    return 0;
}