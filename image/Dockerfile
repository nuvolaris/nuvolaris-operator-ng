# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#
FROM ubuntu:22.04
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
ENV JAVA_VERSION=8.0.402-tem
ENV PYENV_VERSION=3.11.7
ENV DOCKER_VERSION=18.06.3-ce
ENV NUV_BRANCH=3.0.0-testing
ENV TZ=Europe/London
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update && apt-get -y upgrade && \
    apt-get -y install \
        curl wget gpg zip unzip \
        software-properties-common apt-utils \
        unzip vim silversearcher-ag \
        sudo socat telnet \
        inetutils-ping \
        lsb-release \
        ca-certificates \
        apt-transport-https \
        build-essential gettext-base \
        git gnupg curl wget jq kafkacat \
        zlib1g-dev libbz2-dev libncurses5-dev \
        libgdbm-dev libnss3-dev libssl-dev \
        libreadline-dev libffi-dev libsqlite3-dev liblzma-dev 

# Download and instal task and nuv
RUN sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b /usr/bin
RUN \
    BRANCH=3.0.0-testing ;\ 
    BUILD="$(curl -sL https://raw.githubusercontent.com/nuvolaris/olaris/$BRANCH/nuvroot.json | jq -r  .version)" \
    ARCH="$(dpkg --print-architecture)" ;\
    FILE="nuv_$(echo $BUILD)_$ARCH.deb" ;\
    URL="https://github.com/nuvolaris/nuv/releases/download/$BUILD/$FILE" ;\
        rm -Rvf /tmp/nuv-installer ;\
        mkdir /tmp/nuv-installer ;\
        wget $URL -O "/tmp/nuv-installer/$FILE" ;\
        dpkg -i "/tmp/nuv-installer/$FILE"

# Download docker client
RUN \
  curl -sL https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz \
  | tar xzvf -  -C /usr/bin --strip 1 docker/docker 

# Download kubectl
RUN \
    KVER="v1.23.0" ;\
    ARCH="$(dpkg --print-architecture)" ;\
    KURL="https://dl.k8s.io/release/$KVER/bin/linux/$ARCH/kubectl" ;\
    curl -sL $KURL -o /usr/bin/kubectl && chmod +x /usr/bin/kubectl

# Download Kustomize
RUN \
    VER="v4.5.7" ;\
    ARCH="$(dpkg --print-architecture)" ;\
    URL="https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F$VER/kustomize_${VER}_linux_${ARCH}.tar.gz" ;\
    curl -sL "$URL" | tar xzvf - -C /usr/bin

# Download WSK
RUN \
    WSK_VERSION=1.2.0 ;\
    WSK_BASE=https://github.com/apache/openwhisk-cli/releases/download ;\
    ARCH=$(dpkg --print-architecture) ;\
    WSK_URL="$WSK_BASE/$WSK_VERSION/OpenWhisk_CLI-$WSK_VERSION-linux-$ARCH.tgz" ;\
    curl -sL "$WSK_URL" | tar xzvf - -C /usr/bin/

# Download MINIO client
RUN \
    rm -Rvf /tmp/minio-binaries ;\
    mkdir /tmp/minio-binaries ;\
    MINIO_BASE=https://dl.min.io/client/mc/release/linux ;\
    ARCH=$(dpkg --print-architecture) ;\
    MC_VER=RELEASE.2023-03-23T20-03-04Z ;\
    MINIO_URL="$MINIO_BASE-$ARCH/archive/mc.${MC_VER}" ;\
    curl -sL "$MINIO_URL" --create-dirs -o /tmp/minio-binaries/mc ;\
    chmod +x /tmp/minio-binaries/mc ;\
    mv /tmp/minio-binaries/mc /usr/bin/mc ;\
    rm -Rvf /tmp/minio-binaries

# Nuvolaris user
RUN groupadd --gid 1000 nuvolaris
RUN useradd -m nuvolaris -s /bin/bash --uid 1000 --gid 1000 --groups root
RUN echo "nuvolaris ALL=(ALL:ALL) NOPASSWD: ALL" >>/etc/sudoers

# install java and python
USER nuvolaris
WORKDIR /home/nuvolaris
RUN curl -s "https://get.sdkman.io" | bash 
RUN git clone https://github.com/pyenv/pyenv.git /home/nuvolaris/.pyenv 
RUN git clone https://github.com/nuvolarisinc/nuvolaris-operator-ng operator
RUN echo "source ~/.sdkman/bin/sdkman-init.sh" >>~/.bashrc ;\
    echo 'eval "$(pyenv init --path)"' >>~/.bashrc ;\
    echo 'eval "$(pyenv init)"' >>~/.bashrc ;\
    echo "source ~/operator/aliases" >>~/.bashrc 
# operator
ENV PATH=/home/nuvolaris/.pyenv/bin:/home/nuvolaris/.local/bin:/usr/local/bin:/usr/bin:/sbin:/bin:/usr/nuvolaris
RUN bash -c "source ~/.sdkman/bin/sdkman-init.sh ; sdk install java $JAVA_VERSION"
RUN bash -c "source ~/.bashrc ; pyenv install $PYENV_VERSION"
# openwhisk
COPY openwhisk/bin/openwhisk-standalone.jar openwhisk/openwhisk-standalone.jar
COPY runtimes.json standalone.conf openwhisk
WORKDIR /home/nuvolaris/operator
#RUN curl -sSL https://install.python-poetry.org | python3 -
#RUN poetry install
# USER root
# RUN chown -R nuvolaris /home/nuvolaris ;\
#      chgrp -R root /home/nuvolaris ;\
#      chmod -R 0775 /home/nuvolaris
# USER nuvolaris
# CMD sleep inf
