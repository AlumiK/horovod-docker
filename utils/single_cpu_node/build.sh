#!/bin/bash

DOCKERFILE_PATH=`dirname $0`/../../dockerfiles

docker build --no-cache -f $DOCKERFILE_PATH/main.cpu.Dockerfile -t horovod:cpu $DOCKERFILE_PATH
