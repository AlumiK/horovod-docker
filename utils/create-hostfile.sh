#!/bin/bash

for ((i=1; i<=$1; i++))
do
    echo "node-$i slot=$2" >> hostfile
done
