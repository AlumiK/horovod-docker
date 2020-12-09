#!/bin/bash

DOCKERFILE_PATH=`dirname $0`/../dockerfiles

docker build -f $DOCKERFILE_PATH/deps.$1.Dockerfile -t horovod-deps:$1 $DOCKERFILE_PATH
