#!/bin/bash
# Build str2str using Docker on Debian x64
set -e

docker build -t rtklib-str2str-builder - <<EOF
FROM debian:stable-slim
RUN apt-get update && \
    apt-get install -y git build-essential make && \
    rm -rf /var/lib/apt/lists/*
WORKDIR /RTKLIB
COPY . /RTKLIB
WORKDIR /RTKLIB/app/consapp/str2str/gcc
RUN make
EOF

docker run --rm -v "$(pwd)":/output rtklib-str2str-builder \
    cp /RTKLIB/app/consapp/str2str/gcc/str2str /output/str2str_docker_build

echo "str2str built and copied to ./str2str_docker_build"
