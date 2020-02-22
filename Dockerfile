FROM ubuntu:18.04

RUN apt-get update && apt-get install -y \
  build-essential autoconf libtool git pkg-config curl \
  automake libtool curl make g++ unzip wget \
  && apt-get clean

RUN wget -qO- "https://cmake.org/files/v3.16/cmake-3.16.4-Linux-x86_64.tar.gz" | tar --strip-components=1 -xz -C /usr/local

WORKDIR /app
COPY third_party/grpc third_party/grpc
RUN apt-get install libssl-dev

RUN cd third_party/grpc && \
    mkdir -p cmake/build && \
    cd cmake/build && \
    cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DgRPC_INSTALL=ON \
    -DgRPC_BUILD_TESTS=OFF \
    -DgRPC_SSL_PROVIDER=package \
    ../.. && \
    make -j7

# WORKDIR /app
COPY CMakeLists.txt .

COPY src/ .
RUN cmake . && make -j