FROM centos:centos7

ENV TZ=Europe/Minsk
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN yum install -y git python3 python3-pip setuptools wget mailx sendmail sendmail-cf java-1.8.0-openjdk-devel maven mongodb-org
RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install --upgrade Pillow

RUN git clone https://github.com/Emory-HITI/Niffler.git
WORKDIR ./Niffler
RUN git checkout dev

COPY requirements-dev.txt ./requirements-dev.txt

RUN pip3 install -r requirements.txt
RUN wget https://repo.anaconda.com/archive/Anaconda3-2020.11-Linux-x86_64.sh
RUN sh Anaconda3-2020.11-Linux-x86_64.sh -u -b
RUN source ~/.bashrc
RUN rm Anaconda3-2020.11-Linux-x86_64.sh
RUN echo "true" > init/pip.out

RUN conda install -c conda-forge -y gdcm

RUN chmod +x modules/meta-extraction/service/mdextractor.sh

RUN cp init/disable-thp.service /etc/systemd/system/disable-thp.service
RUN systemctl daemon-reload
RUN systemctl start disable-thp
RUN systemctl enable disable-thp

RUN echo "true" > init/misc.out

RUN cd ..
RUN wget https://sourceforge.net/projects/dcm4che/files/dcm4che3/5.22.5/dcm4che-5.22.5-bin.zip/download -O dcm4che-5.22.5-bin.zip
RUN unzip dcm4che-5.22.5-bin.zip
RUN rm dcm4che-5.22.5-bin.zip
RUN cd Niffler
RUN echo "true" > init/dcm4che.out

RUN cp init/mongodb-org-4.2.repo /etc/yum.repos.d/
RUN systemctl start mongod
RUN systemctl enable mongod
RUN mongo init/mongoinit.js
RUN cp modules/meta-extraction/service/mdextractor.service /etc/systemd/system/
RUN systemctl daemon-reload
RUN systemctl start mdextractor.service
RUN systemctl enable mdextractor.service
RUN echo "true" > init/mongo.out

RUN pip install -r modules/frontend/requirements.txt
RUN chmod +x modules/frontend/service/frontend_service.sh
RUN cp modules/frontend/service/niffler.service /etc/systemd/system/
RUN systemctl daemon-reload
RUN systemctl start niffler.service
RUN systemctl enable niffler.service
RUN "true" > init/service.out