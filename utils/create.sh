#!/bin/bash

DOCKERFILE_PATH=`dirname $0`/../dockerfiles
NUM_NODES=$1
NUM_SLOTS=$2
TAG=$3
HOROVOD_DOCKER_PATH=$4
SUBNET=$5

docker build --no-cache -f $DOCKERFILE_PATH/main.$TAG.Dockerfile -t horovod:$TAG $DOCKERFILE_PATH
docker network create horovod --subnet ${SUBNET:-172.21.0.0/24}

for (( i=1; i<=$NUM_NODES; i++ ))
do
    if [[ $TAG == *"cuda"* ]]
    then
        docker run -itd --network=horovod --runtime=nvidia --shm-size=1g --name node-$i \
            --privileged -v $HOROVOD_DOCKER_PATH:/root/horovod-docker horovod:$TAG
    else
        docker run -itd --network=horovod --shm-size=1g --name node-$i \
            --privileged -v $HOROVOD_DOCKER_PATH:/root/horovod-docker horovod:$TAG
    fi
    echo "node-$i slot=$NUM_SLOTS" >> `dirname $0`/hostfile
done
