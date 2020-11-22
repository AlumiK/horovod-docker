# Horovod Docker

Docker files for Horovod development.

## Install Docker on Ubuntu

Before you install Docker Engine for the first time on a new host machine, you need to set up the Docker repository. Afterward, you can install and update Docker from the repository.

### Set Up the Repository

Update the apt package index and install packages to allow apt to use a repository over HTTPS:

```sh
$ sudo apt update
$ sudo apt install apt-transport-https \
                   ca-certificates \
                   curl \
                   gnupg-agent \
                   software-properties-common
```

Add Docker’s official GPG key:

```sh
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```

Use the following command to set up the stable repository. To add the nightly or test repository, add the word nightly or test (or both) after the word stable in the commands below.

Note: The `lsb_release -cs` sub-command below returns the name of your Ubuntu distribution, such as `xenial`. Sometimes, in a distribution like Linux Mint, you might need to change `$(lsb_release -cs)` to your parent Ubuntu distribution. For example, if you are using Linux Mint Tessa, you could use bionic. Docker does not offer any guarantees on untested and unsupported Ubuntu distributions.

```sh
$ sudo add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"
```

### Install Docker Engine

Update the apt package index, and install the latest version of Docker Engine and containerd:

```sh
$ sudo apt update
$ sudo apt install docker-ce docker-ce-cli containerd.io
```

## Build Images

```sh
$ docker build -f cuda-mpi.Dockerfile -t alumik/horovod:cuda-mpi .
```

## Create Containers

Create docker network:

```sh
$ docker network create horovod --subnet 172.21.0.0/24
```

Create containers:

- With CUDA:

    ```sh
    $ docker run -it --network=horovod \
                     --runtime=nvidia \
                     --shm-size=1g \
                     --name node-1 \
                     --privileged \
                     --ip 172.21.0.2 \
                     alumik/horovod:cuda-mpi
    ```

- Without CUDA:

    ```sh
    $ docker run -it --network=horovod \
                     --shm-size=1g \
                     --name node-1 \
                     --privileged \
                     --ip 172.21.0.2 \
                     alumik/horovod:cpu
    ```

## Run Example Scripts 

Master node:

```sh
$ horovodrun -np 8 -H node-1:2,node-2:2,node-3:2,node-4:2 -p 12345 python tensorflow2_keras_mnist.py
```

Slave nodes:

```
$ sleep infinity
```
