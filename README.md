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

### Create containers for development

To build dependency images:

```
./utils/build.sh <tag>
```

To build main images and containers:

```
./utils/create.sh <num_nodes> <num_slots> <tag> <horovod_docker_path> <subnet>
```

- `tag` can be `cpu`, `cuda-mpi` or `cuda-nccl`.
- `horovod_docker_path` is your local directory of horovod-docker, e.g., `~/repos/horovod-docker`.
- `subnet` is the ip address of the Horovod subnet in CIDR format, defaults to `172.21.0.0/24`.

### Run python scripts

```
horovodrun -np <num_processes> -hostfile ~/horovod-docker/utils/hostfile -p 12345 python train.py
```

### Destroy containers

```
./utils/destroy.sh <num_nodes>
```

You should destroy and recreate containers every time you want any changes in the Horovod source code to take effect.
