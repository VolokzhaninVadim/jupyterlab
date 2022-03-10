FROM python:3.8-slim-buster
LABEL maintainer="Volokzhanin Vadim"

################# Устанавливаем часовой пояс ##############
ENV TZ=Asia/Vladivostok
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && apt-get update && apt-get install -y tzdata \
    && apt-get autoremove -y \ 
    && apt-get clean all 

################## Устанавливаем git ######################
RUN apt-get update && \
    apt-get install -y \
        git
RUN `git config --global user.name "Volokzhanin Vadim"` \
    && `git config --global user.email "volokzhanin@yandex.ru"`
RUN  apt-get install -y curl   

################## Устанавливаем nodejs + npm + yarn ####################
RUN  curl -sL https://deb.nodesource.com/setup_14.x  | bash - \ 
    && apt-get -y install nodejs \
    && npm install  

RUN curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN apt-get update \
    && apt-get install -y yarn \
    && apt-get install -y build-essential

################# Устанавливаем пакеты ###################
ADD requirements_torch.txt requirements_torch.txt
ADD requirements.txt requirements.txt
RUN pip install --upgrade pip 
RUN pip install -r requirements_torch.txt
RUN pip install numpy \ 
     && pip install -r requirements.txt

################### Устанавливаем tesseract ##############
RUN apt-get install -y wget \
     && apt-get -y install tesseract-ocr-eng && apt-get install tesseract-ocr-rus 
RUN wget https://github.com/tesseract-ocr/tessdata/raw/4.00/eng.traineddata -O /usr/share/tesseract-ocr/4.00/tessdata/eng.traineddata \
    &&  wget https://github.com/tesseract-ocr/tessdata/raw/4.00/rus.traineddata -O /usr/share/tesseract-ocr/4.00/tessdata/rus.traineddata 

RUN jupyter contrib nbextension install

RUN mkdir -p /root/jupyterlab

########################### Устанавливаем и настраиваем R ####
RUN apt-get install -y build-essential \
                       libcurl4-gnutls-dev \
                       libxml2-dev \
                       libssl-dev  \
                       r-base

RUN su - -c "R -e \"install.packages('IRkernel')\"" \
&& su - -c "R -e \"IRkernel::installspec()\""

################ Создаем папку и копируем туда настройки ####
WORKDIR /root/jupyterlab
COPY jupyter_notebook_config.py /root/.jupyter/jupyter_notebook_config.py
COPY ipython_kernel_config.py /root/.ipython/profile_default/ipython_kernel_config.py

################ Устанавливаем оболочку ############
RUN apt-get update \
    && apt-get -y install zsh nano 
RUN git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git /root/.oh-my-zsh
COPY .zshrc /root/.zshrc

################ Устанавливаем chrome ##############
ARG CHROME_VERSION="google-chrome-stable"
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
&& echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
&& apt-get update -qqy \
&& apt-get -qqy install \
${CHROME_VERSION:-google-chrome-stable} \
&& rm /etc/apt/sources.list.d/google-chrome.list \
&& rm -rf /var/lib/apt/lists/* /var/cache/apt/*

############### Устанавливаем chrome driver #########
# Получим последнюю стабильную версию драйвера chrome: 
RUN CHROME_DRIVER_VERSION=`curl -sS https://chromedriver.storage.googleapis.com/LATEST_RELEASE` \ 
# Установим Chrome driver:
&& wget -N https://chromedriver.storage.googleapis.com/$CHROME_DRIVER_VERSION/chromedriver_linux64.zip -P ~/ \
&& unzip ~/chromedriver_linux64.zip -d ~/ \
&& rm ~/chromedriver_linux64.zip \
&& mv -f ~/chromedriver /usr/local/bin/chromedriver \
&& chown root:root /usr/local/bin/chromedriver \
&& chmod 0755 /usr/local/bin/chromedriver 

############### Устанавливаем Spark #########
RUN echo "deb http://security.debian.org/debian-security stretch/updates main" >> /etc/apt/sources.list \                                                 
&& apt-get update -y \
&& apt-get install -y openjdk-8-jdk 

############### Устанавливаем git  #########
RUN pip install --upgrade jupyterlab jupyterlab-git \
&& jupyter lab build

# Подставляем jupyterlab port и cmd
EXPOSE 8888
# CMD jupyter-lab
ENTRYPOINT jupyter-lab 
