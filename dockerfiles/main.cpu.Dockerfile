FROM horovod-deps:cpu

# Install Horovod
RUN git clone https://github.com/horovod/horovod.git --recursive ~/horovod
RUN cd ~/horovod && \
    MAKEFLAGS="-j1" HOROVOD_WITH_TENSORFLOW=1 HOROVOD_WITH_PYTORCH=1 HOROVOD_WITH_MXNET=1 \
        pip install --no-cache-dir -e .

# Copy examples
RUN cp -r ~/horovod/examples /

WORKDIR "/examples"

ENTRYPOINT bash -c "service ssh start; /usr/sbin/sshd -p 12345; /bin/bash"
