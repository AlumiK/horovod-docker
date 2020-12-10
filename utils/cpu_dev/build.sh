#!/bin/bash

DOCKERFILE_PATH=`dirname $0`/../../dockerfiles

docker build --no-cache -f $DOCKERFILE_PATH/dev.cpu.Dockerfile -t horovod-dev:cpu $DOCKERFILE_PATH
