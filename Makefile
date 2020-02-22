LDFLAGS = -L/usr/local/lib `pkg-config --libs protobuf grpc++`\
           -Wl,--no-as-needed -lgrpc++_reflection -Wl,--as-needed\
           -ldl

CXX = g++
CPPFLAGS += `pkg-config --cflags protobuf grpc`
CXXFLAGS += -std=c++11

GRPC_CPP_PLUGIN = grpc_cpp_plugin
GRPC_CPP_PLUGIN_PATH ?= `which $(GRPC_CPP_PLUGIN)`

PROTO_DIR = ./protos
vpath %.proto $(PROTO_DIR)

all: client server

client: test.pb.o test.grpc.pb.o client.o
	$(CXX) $^ $(LDFLAGS) -o $@

server: test.pb.o test.grpc.pb.o server.o
	$(CXX) $^ $(LDFLAGS) -o $@

%.grpc.pb.cc: %.proto
	protoc -I $(PROTO_DIR) --grpc_out=. --plugin=protoc-gen-grpc=$(GRPC_CPP_PLUGIN_PATH) $<

%.pb.cc: %.proto
	protoc -I $(PROTO_DIR) --cpp_out=. $<

clean:
	rm -f *.o *.pb.cc *.pb.h client server