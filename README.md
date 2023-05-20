# JuPyteRLab
![main-logo.svg](https://jupyter.org/assets/homepage/main-logo.svg)


## Get password
`jupyter notebook password`<br>
Set password and confirm it.<br>
In notebook:
```
from IPython.lib import passwd
passwd()
exit
```

## SSL 
Certs from [nextcloud](https://github.com/VolokzhaninVadim/nextcloud).

# [NVIDIA](https://ru.wikipedia.org/wiki/Nvidia), [CUDA](https://ru.wikipedia.org/wiki/CUDA) in Docker
![img](https://camo.githubusercontent.com/b6355d32448a4186269f6ae67964bdd82d6cb8c4c24b928d59b4b84299ee7905/68747470733a2f2f75706c6f61642e77696b696d656469612e6f72672f77696b6970656469612f636f6d6d6f6e732f7468756d622f322f32312f4e76696469615f6c6f676f2e7376672f32303070782d4e76696469615f6c6f676f2e7376672e706e67)

## 1. Delete old drivers and CUDA
* Scripts:  
```shell
sudo apt remove nvidia-*
sudo add-apt-repository --remove ppa:graphics-drivers/ppa
sudo apt remove xserver-xorg-video-nvidia-*
sudo apt update
rm -Rf /usr/local/cuda/
sudo reboot
```
* Restart system **!!!**  

## 2. Install drivers NVIDIA
* [Check cuda matrix and drivers.](https://docs.nvidia.com/deploy/cuda-compatibility/index.html)  
* Scripts:
```shell
sudo add-apt-repository ppa:graphics-drivers/ppa # get repo
sudo apt list nvidia-driver-* # get all drivers
sudo apt install nvidia-driver-450 # install 450 driver
sudo apt-get install -y nvidia-docker2 # need  nv-runtime for docker
sudo reboot
```
* Restart system **!!!** 
* Check install:  **nvidia-smi** in server terminal

## 3. Install CUDA
* [NVidia](https://developer.nvidia.com/CUDA-TOOLKIT-ARCHIVE)  
* Choose architecture parameters and OS.
* Scripts:
```shell
wget http://developer.download.nvidia.com/compute/cuda/11.0.2/local_installers/cuda_11.0.2_450.51.05_linux.run
sudo sh cuda_11.0.2_450.51.05_linux.run
```
* Check install: **nvcc -V** in terminal.

## 4. Docker changes
* Change CUDA version in **docker-compose.yml**  
* Change CUDA version in **Dockerfile**
* Check install: **nvidia-smi** и **nvcc -V** in container
