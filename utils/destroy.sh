#!/bin/bash

NUM_NODES=$1

for (( i=1; i<=$NUM_NODES; i++ ))
do
    docker stop node-$i -t 0
    docker rm node-$i
done

docker network remove horovod
rm `dirname $0`/hostfile
