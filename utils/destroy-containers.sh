#!/bin/bash

NUM_CONTAINERS=16

for i in $(seq 1 $END)
do
    docker stop node-$i
    docker rm node-$i
done
