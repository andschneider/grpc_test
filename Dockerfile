FROM ubuntu:18.04 as builder

RUN apt-get update && apt-get install -y \
    autoconf \
    automake \
    build-essential \
    curl \
    g++ \
    git \
    libssl-dev\
    libtool \
    make \
    pkg-config \
    unzip \
    wget \
    && apt-get clean

RUN wget -qO- "https://cmake.org/files/v3.16/cmake-3.16.4-Linux-x86_64.tar.gz" | tar --strip-components=1 -xz -C /usr/local

WORKDIR /build
COPY third_party/grpc third_party/grpc

RUN cd third_party/grpc && \
    mkdir -p cmake/build && \
    cd cmake/build && \
    cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DgRPC_INSTALL=ON \
    -DgRPC_BUILD_TESTS=OFF \
    -DgRPC_SSL_PROVIDER=package \
    ../.. && \
    make -j7 && \
    make install

COPY CMakeLists.txt .

COPY src/ src/
RUN cmake . && make -j

FROM ubuntu:18.04 as runner

WORKDIR /app
COPY --from=builder /build/client .
COPY --from=builder /build/server .
