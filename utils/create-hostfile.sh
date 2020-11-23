#!/bin/bash

NUM_CONTAINERS=16

for i in $(seq 1 $END)
    echo "node-$i slot=2" >> hostfile
done
