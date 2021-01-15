#!/bin/bash

cd ~/horovod
rm -rf build/ dist/ horovod.egg-info/

HOROVOD_WITH_TENSORFLOW=1 MAKEFLAGS="-j8" \
    pip install --no-cache-dir -e .

cp build/lib.linux-x86_64-3.8/horovod/metadata.json horovod/metadata.json
