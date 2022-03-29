FROM ubuntu:20.04

RUN apt-get update && apt-get install -y --no-install-recommends --fix-missing \
    python3-pip python3-setuptools python3-dev \
    git

RUN rm -rf /var/cache/apt/* /var/lib/apt/lists/* && \
    apt-get autoremove -y && apt-get clean

RUN python3 -m pip install --upgrade pip setuptools wheel && \
    pip3 install --no-cache-dir numpy

RUN git clone https://github.com/Emory-HITI/Niffler
RUN git checkout dev

RUN bash ./Niffler/install.sh