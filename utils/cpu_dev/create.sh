#!/bin/bash

HOROVOD_DOCKER_PATH=$1

docker run -itd --shm-size=1g --name node-dev --privileged -p 11022:11022 \
    -v $HOROVOD_DOCKER_PATH:/root/horovod-docker \
    horovod-dev:cpu
