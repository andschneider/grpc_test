cmake_minimum_required(VERSION 3.13)

project(GrpcExample)

# using this method rebuild grpc every time a .cc file changes
#add_subdirectory(third_party/grpc EXCLUDE_FROM_ALL)
#message(STATUS "Using gRPC via add_subdirectory.")

# After using add_subdirectory, we can now use the grpc targets directly from
# this build.
#set(_PROTOBUF_LIBPROTOBUF libprotobuf)
#if(CMAKE_CROSSCOMPILING)
#    find_program(_PROTOBUF_PROTOC protoc)
#else()
#    set(_PROTOBUF_PROTOC $<TARGET_FILE:protobuf::protoc>)
#endif()
#set(_GRPC_GRPCPP_UNSECURE grpc++_unsecure)
#if(CMAKE_CROSSCOMPILING)
#    find_program(_GRPC_CPP_PLUGIN_EXECUTABLE grpc_cpp_plugin)
#else()
#    set(_GRPC_CPP_PLUGIN_EXECUTABLE $<TARGET_FILE:grpc_cpp_plugin>)
#endif()

# using this method does not
set(protobuf_MODULE_COMPATIBLE TRUE)
find_package(Protobuf CONFIG REQUIRED)
message(STATUS "Using protobuf ${protobuf_VERSION}")

set(_PROTOBUF_LIBPROTOBUF protobuf::libprotobuf)
if(CMAKE_CROSSCOMPILING)
    find_program(_PROTOBUF_PROTOC protoc)
else()
    set(_PROTOBUF_PROTOC $<TARGET_FILE:protobuf::protoc>)
endif()

# Find gRPC installation
# Looks for gRPCConfig.cmake file installed by gRPC's cmake installation.
find_package(gRPC CONFIG REQUIRED)
message(STATUS "Using gRPC ${gRPC_VERSION}")

set(_GRPC_GRPCPP_UNSECURE gRPC::grpc++_unsecure)
if(CMAKE_CROSSCOMPILING)
    find_program(_GRPC_CPP_PLUGIN_EXECUTABLE grpc_cpp_plugin)
else()
    set(_GRPC_CPP_PLUGIN_EXECUTABLE $<TARGET_FILE:gRPC::grpc_cpp_plugin>)
endif()

get_filename_component(hw_proto "./protos/test.proto" ABSOLUTE)
get_filename_component(hw_proto_path "${hw_proto}" PATH)

# Generated sources
set(hw_proto_srcs "${CMAKE_CURRENT_BINARY_DIR}/test.pb.cc")
set(hw_proto_hdrs "${CMAKE_CURRENT_BINARY_DIR}/test.pb.h")
set(hw_grpc_srcs "${CMAKE_CURRENT_BINARY_DIR}/test.grpc.pb.cc")
set(hw_grpc_hdrs "${CMAKE_CURRENT_BINARY_DIR}/test.grpc.pb.h")
add_custom_command(
      OUTPUT "${hw_proto_srcs}" "${hw_proto_hdrs}" "${hw_grpc_srcs}" "${hw_grpc_hdrs}"
      COMMAND ${_PROTOBUF_PROTOC}
      ARGS --grpc_out "${CMAKE_CURRENT_BINARY_DIR}"
        --cpp_out "${CMAKE_CURRENT_BINARY_DIR}"
        -I "${hw_proto_path}"
        --plugin=protoc-gen-grpc="${_GRPC_CPP_PLUGIN_EXECUTABLE}"
        "${hw_proto}"
      DEPENDS "${hw_proto}")

# Include generated *.pb.h files
include_directories("${CMAKE_CURRENT_BINARY_DIR}")

foreach(_target
  client server) 
  add_executable(${_target} "${_target}.cc"
    ${hw_proto_srcs}
    ${hw_grpc_srcs})
  target_link_libraries(${_target}
    ${_GRPC_GRPCPP_UNSECURE}
    ${_PROTOBUF_LIBPROTOBUF})
endforeach()