# Пароль jupyterlab
Выставляем пароль: `source /home/volokzhanin/python_venv/env/bin/activate ; jupyter notebook password`<br>
Вставляем и подтверждаем пароль. <br>
В notebook:
```
from IPython.lib import passwd
passwd()
exit
```

# ssl для  JuPyteRLab
* Беру с [nextcloud](https://github.com/VolokzhaninVadim/nextcloud).

## Генерация пароля для tor
1. Устанавливаем tor `sudo pacman -S tor`
1. Генерируем пароль`tor --hash-password mypassword`

# Arch
## Установка драйвера для видеокарты [NVIDIA](https://ru.wikipedia.org/wiki/Nvidia)
![картинка](https://upload.wikimedia.org/wikipedia/commons/thumb/2/21/Nvidia_logo.svg/200px-Nvidia_logo.svg.png)

Автоматическая установка драйвера для видеокарты [NVIDIA](https://ru.wikipedia.org/wiki/Nvidia): 
```
# Автоматическая установка драйвера для видеокарты NVIDIA
sudo mhwd -a pci nonfree 0300
# Проверка установленных драйверов
mhwd -li
```
## Установка Cuda
![картинка](https://upload.wikimedia.org/wikipedia/commons/thumb/5/59/CUDA.png/132px-CUDA.png)

1. Установка [CUDA](https://ru.wikipedia.org/wiki/CUDA) для видеокарт [NVIDIA](https://ru.wikipedia.org/wiki/Nvidia): 
```
sudo pacman -S cuda cuda-sdk cuda-toolkit cudnn cuda-tools
```

## Nvidia и Cuda в Docker

### Запуск контейнеров, использующих графические процессоры nvidia
```
# Запуск контейнеров, использующих графические процессоры nvidia
yay nvidia-container-toolkit
# Перегрузить докер
sudo systemctl restart docker
# Указываем сколько в контейнере разрешено графических процессоров
sudo docker run --gpus 1 nvidia/cuda:11.1-base nvidia-smi
# Указываем, какие GPU следует использовать: 
sudo docker run --gpus '"device=0"' nvidia/cuda:11.1-base nvidia-smi
```
### Устанавливаем NVIDIA Container Runtime
```
# Устанавливаем NVIDIA Container Runtime
yay nvidia-container-runtime 
# Редактируем конфигурационный файл 
sudo nano /etc/docker/daemon.json
{
  "runtimes": {
    "nvidia": {
      "path": "/usr/bin/nvidia-container-runtime",
      "runtimeArgs": []
    }
  }
}
# Перегрузить докер
sudo systemctl restart docker
# Проверяем запуск 
sudo docker run --runtime=nvidia nvidia/cuda:11.1-base nvidia-smi
```
# Ubuntu

### Для успешности всей процедуры следует принимать во внимание нижеизложенную схему взаимодействия компонентов:
* С видеокартой взаимодействуют драйвера
* С драйверами взаимодействует CUDA
* С CUDA взаимодействует pytorch

## 1. Удаление старых драйверов и CUDA
* Команды:  
```shell
sudo apt remove nvidia-*
sudo add-apt-repository --remove ppa:graphics-drivers/ppa
sudo apt remove xserver-xorg-video-nvidia-*
sudo apt update
rm -Rf /usr/local/cuda/
sudo reboot
```
* Перезагрузка обязательна **!!!**  

## 2. Установка драйверов NVidia
* **Важно:** следует сверить матрицу версий желаемой версии CUDA и версии драйвера [тут.](https://docs.nvidia.com/deploy/cuda-compatibility/index.html)  
Конечная цель - желаемая версия pytorch, она и будет диктовать версии остальных компонентов.
* Команды:
```shell
sudo add-apt-repository ppa:graphics-drivers/ppa # возвращаем нужный репозиторий
sudo apt list nvidia-driver-* # вывод всех доступных версий драйвера
sudo apt install nvidia-driver-450 # в данном случае устанавливается 450
sudo apt-get install -y nvidia-docker2 # также следует установить nv-runtime для докера
sudo reboot
```
* Перезагрузка обязательна **!!!** 
* Критерий успешности данного этапа: корректный вывод команды **nvidia-smi** в основной консоли сервера

## 3. Установка CUDA
* Единая точка хранения ссылок на установочные файлы на сайте [NVidia](https://developer.nvidia.com/CUDA-TOOLKIT-ARCHIVE)  
* Выбрав нужные параметры архитектуры и OS следует скачивать **runtime**. Осторожно: тяжелый единичный файл: около 3ГБ.  
* Команды, предлагаемые сайтом NVidia, корректны:
```shell
wget http://developer.download.nvidia.com/compute/cuda/11.0.2/local_installers/cuda_11.0.2_450.51.05_linux.run
sudo sh cuda_11.0.2_450.51.05_linux.run
```
* После запуска в меню установщика следует снять пометку на установку драйверов, т.к. они уже установлены  
* Установщик может ругаться что в системе обнаружены следы предыдущей CUDA, это можно смело игнорировать
* По завершению установки будет предложено вручную добавить новые пути в переменные PATH и LD_LIBRARY_PATH, если не планируется работа вне докера то можно пропустить
* **Важно:** следует самостоятельно проверить что в папке **/usr/local/** папка **cuda/** является симлинком на папку с актуальной версией CUDA. При необходимости создать/поменять.  
* Критерий успешности данного этапа: корректный вывод команды **nvcc -V** в основной консоли сервера

## 4. Необходимые изменения для docker
* Замена версии CUDA внутри **docker-compose.yml** во всех упоминаниях  
* Замена версии CUDA внутри **Dockerfile** во всех упоминаниях
* Критерий успешности данного этапа: корректный вывод команд **nvidia-smi** и **nvcc -V** в консоли контейнера

## 5. Обновление pytorch в контейнере
* Единая точка хранения ссылок на установочные файлы на сайте [pytorch](https://download.pytorch.org/whl/torch_stable.html)  
* Выбор версии должен быть основан исходя из версии python в контейнере и версии CUDA.  
* В первую очередь устанавливать следует torch, за ним torchvision. Остальные пакеты опциональны.  
* Не следует забывать и про соответствие версии torch и torchvision, более подробно можно узнать на сайте [pytorch](https://pytorch.org/get-started/locally/)  
* Критерий успешности данного этапа: результаты выполнения внутри контейнера следующего блока кода:  
```python
import torch
print(torch.cuda.is_available()) # True
print(torch.__version__) # установленная версия соответствует задуманной
```

## 6. Возможные проблемы
* Не удалилась предыдущая версия драйверов. Проверяется командой:
```shell
sudo apt list --installed | grep -e nvidia-driver-[0-9][0-9][0-9] -e nvidia-[0-9][0-9][0-9]
```
* Не установился nvidia runtime для докера. Проверка работы командой ниже. Универсальных рецептов лечения нет, каждый случай следует рассматривать отдельно.
```shell
sudo docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi
```
* GPU не переходят в режим потребления P8 при отсутствующей нагрузке. Следует смотреть на состояние nvidia-persistenced.service и настройки persistence через nvidia-smi
```shell
systemctl list-units --type=service | grep nvidia
```
>  nvidia-persistenced.service                           loaded active running NVIDIA Persistence Daemon 
