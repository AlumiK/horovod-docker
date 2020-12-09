#!/bin/bash

DOCKERFILE_PATH=`dirname $0`/../dockerfiles

docker build --no-cache -f $DOCKERFILE_PATH/main.$2.Dockerfile -t horovod:$2 $DOCKERFILE_PATH

docker network create horovod --subnet ${4:-172.21.0.0/24}

for ((i=1; i<=$1; i++))
do
    if [[ $2 == *"cuda"* ]]
    then
        docker run -itd --network=horovod --runtime=nvidia --shm-size=1g --name node-$i \
            --privileged --ip 172.21.0.$((1 + $i)) -v $3:/root/horovod-docker horovod:$2
    else
        docker run -itd --network=horovod --shm-size=1g --name node-$i \
            --privileged --ip 172.21.0.$((1 + $i)) -v $3:/root/horovod-docker horovod:$2
    fi
done
