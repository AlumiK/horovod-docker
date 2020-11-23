#!/bin/bash

NUM_CONTAINERS=16

for i in $(seq 1 $END)
    do docker run -itd --network=horovod --runtime=nvidia --shm-size=1g --name node-$i --privileged --ip 172.21.0.$((1 + $i)) alumik/horovod:cuda-mpi
done
