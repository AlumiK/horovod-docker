# TensorFlow version is tightly coupled to CUDA and cuDNN so it should be selected carefully
FROM nvidia/cuda:10.1-cudnn7-devel

ENV TENSORFLOW_VERSION=2.3.0
ENV PYTORCH_VERSION=1.6.0
ENV TORCHVISION_VERSION=0.7.0
ENV MXNET_VERSION=1.6.0.post0

# Python 3.7 is supported by Ubuntu Bionic out of the box
ARG python=3.7
ENV PYTHON_VERSION=${python}

# Set default shell to /bin/bash
SHELL ["/bin/bash", "-cu"]

RUN apt-get update && apt-get install -y --allow-downgrades --allow-change-held-packages --no-install-recommends \
        build-essential \
        cmake \
        g++-4.8 \
        git \
        curl \
        vim \
        wget \
        ca-certificates \
        libjpeg-dev \
        libpng-dev \
        python${PYTHON_VERSION} \
        python${PYTHON_VERSION}-dev \
        python${PYTHON_VERSION}-distutils \
        librdmacm1 \
        libibverbs1 \
        ibverbs-providers

RUN ln -s /usr/bin/python${PYTHON_VERSION} /usr/bin/python

RUN curl -O https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py && \
    rm get-pip.py

# Install TensorFlow, Keras, PyTorch and MXNet
RUN pip install future typing packaging
RUN pip install tensorflow==${TENSORFLOW_VERSION} \
                keras \
                h5py

RUN PYTAGS=$(python -c "from packaging import tags; tag = list(tags.sys_tags())[0]; print(f'{tag.interpreter}-{tag.abi}')") && \
    pip install https://download.pytorch.org/whl/cu101/torch-${PYTORCH_VERSION}%2Bcu101-${PYTAGS}-linux_x86_64.whl \
        https://download.pytorch.org/whl/cu101/torchvision-${TORCHVISION_VERSION}%2Bcu101-${PYTAGS}-linux_x86_64.whl
RUN pip install mxnet-cu101==${MXNET_VERSION}

# Install UCX
RUN mkdir /tmp/ucx && \
    cd /tmp/ucx && \
    wget https://github.com/openucx/ucx/releases/download/v1.9.0/ucx-1.9.0.tar.gz && \
    tar -xvf ucx-1.9.0.tar.gz && \
    cd ucx-1.9.0 && \
    ./contrib/configure-release --prefix=/usr/local/ucx-cuda --with-cuda=/usr/local/cuda && \
    make -j $(nproc) install && \
    rm -rf /tmp/ucx

# Install Open MPI
RUN mkdir /tmp/openmpi && \
    cd /tmp/openmpi && \
    wget https://download.open-mpi.org/release/open-mpi/v4.0/openmpi-4.0.5.tar.gz && \
    tar -xvf openmpi-4.0.5.tar.gz && \
    cd openmpi-4.0.5 && \
    ./configure --enable-orterun-prefix-by-default --with-cuda=/usr/local/cuda --with-ucx=/usr/local/ucx-cuda && \
    make -j $(nproc) all && \
    make install && \
    ldconfig && \
    rm -rf /tmp/openmpi

# Install Horovod, temporarily using CUDA stubs
RUN git clone https://github.com/AlumiK/horovod.git --recursive ~/horovod
RUN cd ~/horovod && \
    ldconfig /usr/local/cuda/targets/x86_64-linux/lib/stubs && \
    HOROVOD_GPU_OPERATIONS=MPI HOROVOD_WITH_TENSORFLOW=1 HOROVOD_WITH_PYTORCH=1 HOROVOD_WITH_MXNET=1 \
        pip install --no-cache-dir -e . && \
    ldconfig

# Install OpenSSH for MPI to communicate between containers
RUN apt-get install -y --no-install-recommends openssh-client openssh-server && \
    mkdir -p /var/run/sshd

# Allow OpenSSH to talk to containers without asking for confirmation
RUN cat /etc/ssh/ssh_config | grep -v StrictHostKeyChecking > /etc/ssh/ssh_config.new && \
    echo "    StrictHostKeyChecking no" >> /etc/ssh/ssh_config.new && \
    mv /etc/ssh/ssh_config.new /etc/ssh/ssh_config

# Copy examples
RUN cp -r ~/horovod/examples /

# Set up SSH files
COPY ./.ssh /root/.ssh
RUN chmod 700 /root/.ssh && \
    chmod 600 /root/.ssh/id_rsa /root/.ssh/authorized_keys

WORKDIR "/examples"

ENTRYPOINT bash -c "service ssh start; /usr/sbin/sshd -p 12345; /bin/bash"
