#include <string>

#include <grpcpp/grpcpp.h>
#include "test.grpc.pb.h"

using grpc::Channel;
using grpc::ClientContext;
using grpc::Status;

using test::GrpcTest;
using test::ClientRequest;
using test::ServerResponse ;

class GrpcTestClient {
    public:
        GrpcTestClient(std::shared_ptr<Channel> channel) : stub_(GrpcTest::NewStub(channel)) {}

    int sendRequest(std::string message) {
        ClientRequest request;

        request.set_client_input(message);

        ServerResponse reply;

        ClientContext context;

        Status status = stub_->SendRequest(&context, request, &reply);

        if(status.ok()){
            return reply.code();
        } else {
            std::cout << status.error_code() << ": " << status.error_message() << std::endl;
            return -1;
        }
    }

    private:
        std::unique_ptr<GrpcTest::Stub> stub_;
};

void Run() {
    std::string address("grpcserver:5000");
    GrpcTestClient client(
        grpc::CreateChannel(
            address, 
            grpc::InsecureChannelCredentials()
        )
    );

    int response;

    std::string message = "hello world";

    response = client.sendRequest(message);
    std::cout << "Answer received: " << response << std::endl;
}

int main(int argc, char* argv[]){
    Run();

    return 0;
}