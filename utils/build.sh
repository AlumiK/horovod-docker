#!/bin/bash

DOCKERFILE_PATH=`dirname $0`/../dockerfiles
TAG=$1

docker build -f $DOCKERFILE_PATH/deps.$TAG.Dockerfile -t horovod-deps:$TAG $DOCKERFILE_PATH
