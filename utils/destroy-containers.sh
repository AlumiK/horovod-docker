#!/bin/bash

for i in {1..16}
do
    docker stop node-$i
    docker rm node-$i
done
