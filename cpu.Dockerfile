FROM ubuntu:18.04

ENV TENSORFLOW_VERSION=2.3.1
ENV PYTORCH_VERSION=1.7.0
ENV TORCHVISION_VERSION=0.8.1
ENV MXNET_VERSION=1.6.0.post0

ENV OPENMPI_VERSION=4.0.5

# Python 3.8 is supported by Ubuntu Bionic out of the box
ARG python=3.8
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
RUN pip install future typing
RUN pip install tensorflow-cpu==${TENSORFLOW_VERSION} \
                keras \
                h5py
RUN pip install torch==${PYTORCH_VERSION} torchvision==${TORCHVISION_VERSION}
RUN pip install mxnet==${MXNET_VERSION}

# Install Open MPI
RUN mkdir /tmp/openmpi && \
    cd /tmp/openmpi && \
    wget https://download.open-mpi.org/release/open-mpi/v4.0/openmpi-${OPENMPI_VERSION}.tar.gz && \
    tar zxf openmpi-${OPENMPI_VERSION}.tar.gz && \
    cd openmpi-${OPENMPI_VERSION} && \
    ./configure --enable-orterun-prefix-by-default && \
    make -j $(nproc) all && \
    make install && \
    ldconfig && \
    rm -rf /tmp/openmpi

# Install Horovod
RUN git clone https://github.com/horovod/horovod.git --recursive ~/horovod
RUN cd ~/horovod && \
    MAKEFLAGS="-j1" HOROVOD_WITH_TENSORFLOW=1 HOROVOD_WITH_PYTORCH=1 HOROVOD_WITH_MXNET=1 \
        pip install --no-cache-dir -e .

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
