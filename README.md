# Horovod Docker

Docker files for Horovod development.

## Install Docker Engine

Before you install Docker Engine for the first time on a new host machine, you need to set up the Docker repository. Afterward, you can install and update Docker from the repository.

### Set Up the Repository

Update the apt package index and install packages to allow apt to use a repository over HTTPS:

```
sudo apt update
sudo apt install apt-transport-https \
                 ca-certificates \
                 curl \
                 gnupg-agent \
                 software-properties-common
```

Add Docker’s official GPG key:

```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```

Use the following command to set up the stable repository. To add the nightly or test repository, add the word nightly or test (or both) after the word stable in the commands below.

Note: The `lsb_release -cs` sub-command below returns the name of your Ubuntu distribution, such as `xenial`. Sometimes, in a distribution like Linux Mint, you might need to change `$(lsb_release -cs)` to your parent Ubuntu distribution. For example, if you are using Linux Mint Tessa, you could use bionic. Docker does not offer any guarantees on untested and unsupported Ubuntu distributions.

```
sudo add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"
```

### Install Docker Engine

Update the apt package index, and install the latest version of Docker Engine and containerd:

```
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io
```

## Install NVIDIA Container Toolkit

The NVIDIA Container Toolkit for Docker is required to run CUDA images.

Setup the stable repository and the GPG key:

```
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) && \
    curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - && \
    curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
```

Install the nvidia-docker2 package (and dependencies) after updating the package listing:

```
sudo apt update
sudo apt install nvidia-docker2
```

Restart the Docker daemon to complete the installation after setting the default runtime:

```
sudo systemctl restart docker
```

## Build & Run

### Build Images

`type` can be `cpu`, `cuda-mpi` or `cuda-nccl`.

```
docker build -f <type>.Dockerfile -t <image tag> .
```

### Create Containers

Create Docker network:

```
docker network create <network name> --subnet <subnet in CIDR format>
```

Create containers:

- With CUDA:

    ```
    docker run -itd --network=<network name> --runtime=nvidia --shm-size=1g \
        --name <node name> --privileged --ip <ip address> <image tag>
    ```

- Without CUDA:

    ```
    docker run -itd --network=<network name> --shm-size=1g \
        --name <node name> --privileged --ip <ip address> <image tag>
    ```

### Run Example Scripts 

To run on 4 machines with 2 GPUs each:

```
horovodrun -np 8 -H node-1:2,node-2:2,node-3:2,node-4:2 -p 12345 python train.py
```

Or use a host file:

```
horovodrun -np 8 -hostfile myhost -p 12345 python train.py
```

```sh
$ cat myhost

node-1 slot=2
node-2 slot=2
node-3 slot=2
node-4 slot=2
```

`node-1`, `node-2`, `node-3` and `node-4` are the node names specified in the previous step.
