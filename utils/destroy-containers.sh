#!/bin/bash

for ((i=1; i<=$1; i++))
do
    docker stop node-$i -t 0
    docker rm node-$i
done

docker network remove horovod
