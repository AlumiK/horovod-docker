#!/bin/bash

for i in {1..16}
    do docker run -itd --network=horovod --runtime=nvidia --shm-size=1g --name node-$i --privileged --ip 172.21.0.$((1 + $i)) horovod:cuda-mpi
done
