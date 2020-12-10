#!/bin/bash

cd ~/horovod
rm -rf build/ dist/

HOROVOD_WITH_TENSORFLOW=1 HOROVOD_WITH_PYTORCH=1 HOROVOD_WITH_MXNET=1 \
    pip install --no-cache-dir -e .
