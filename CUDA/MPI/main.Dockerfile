FROM alumik/horovod-prereq:cuda-mpi

# Install Horovod, temporarily using CUDA stubs
RUN cd ~/horovod && \
    ldconfig /usr/local/cuda/targets/x86_64-linux/lib/stubs && \
    HOROVOD_GPU_ALLREDUCE=MPI HOROVOD_GPU_OPERATIONS=MPI HOROVOD_WITH_TENSORFLOW=1 HOROVOD_WITH_PYTORCH=1 HOROVOD_WITH_MXNET=1 \
        pip install --no-cache-dir -e . && \
    ldconfig

WORKDIR "/examples"

ENTRYPOINT bash -c "service ssh start; /usr/sbin/sshd -p 12345; /bin/bash"
