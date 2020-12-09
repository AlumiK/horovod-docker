#!/bin/bash

docker run -itd --shm-size=1g --name node-0 --privileged -v $1:/root/horovod -v $2:/root/horovod-docker horovod:cpu
