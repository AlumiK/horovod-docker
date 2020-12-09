FROM horovod-deps:cuda-nccl

# Install Horovod, temporarily using CUDA stubs
RUN git clone http://10.10.1.209/AlumiK/horovod.git --recursive ~/horovod
RUN cd ~/horovod && \
    ldconfig /usr/local/cuda/targets/x86_64-linux/lib/stubs && \
    HOROVOD_GPU_OPERATIONS=NCCL HOROVOD_WITH_TENSORFLOW=1 HOROVOD_WITH_PYTORCH=1 HOROVOD_WITH_MXNET=1 \
        pip install --no-cache-dir -e . && \
    ldconfig

# Copy examples
RUN cp -r ~/horovod/examples ~/examples

WORKDIR "/root/examples"

ENTRYPOINT bash -c "service ssh start; /usr/sbin/sshd -p 12345; /bin/bash"
