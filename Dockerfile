FROM ubuntu:20.04

ENV TZ=Europe/Minsk
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install -y --no-install-recommends --fix-missing \
    python3-pip python3-setuptools python3-dev \
    git systemd wget unzip mailutils sendmail sendmail-cf \
    openjdk-8-jdk maven \
    gnupg

RUN rm -rf /var/cache/apt/* /var/lib/apt/lists/* && \
    apt-get autoremove -y && apt-get clean

RUN python3 -m pip install --upgrade pip setuptools wheel && \
    pip3 install --no-cache-dir numpy

RUN git clone https://github.com/Emory-HITI/Niffler.git
WORKDIR ./Niffler
RUN git checkout dev

COPY docker_install.sh ./Niffler/docker_install.sh
RUN bash ./Niffler/docker_install.sh
