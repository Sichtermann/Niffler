#!/bin/sh
# adjusted to Ubuntu.. not working yet

echo "Configuring Niffler"
chmod -R 777 .

PIP=`head -n 1 init/pip.out`
if [ "$PIP" = false ] ; then
    
    echo "Installing pip"
    pip install -r requirements.txt
    wget https://repo.anaconda.com/archive/Anaconda3-2020.11-Linux-x86_64.sh
    sh Anaconda3-2020.11-Linux-x86_64.sh -u -b
    source ~/.bashrc
    rm Anaconda3-2020.11-Linux-x86_64.sh
    echo "true" > init/pip.out
fi

MISC=`head -n 1 init/misc.out`
if [ "$MISC" = false ] ; then
    echo "Installing gdcm and mail"
    conda install -c conda-forge -y gdcm
    chmod +x modules/meta-extraction/service/mdextractor.sh
    echo "Disable THP"
    cp init/disable-thp.service /etc/systemd/system/disable-thp.service
    systemctl daemon-reload
    systemctl start disable-thp
    systemctl enable disable-thp
    echo "true" > init/misc.out
fi

DCM4CHE=`head -n 1 init/dcm4che.out`
if [ "$DCM4CHE" = false ] ; then
    echo "Installing DCM4CHE"
    cd ..
    wget https://sourceforge.net/projects/dcm4che/files/dcm4che3/5.22.5/dcm4che-5.22.5-bin.zip/download -O dcm4che-5.22.5-bin.zip
    unzip dcm4che-5.22.5-bin.zip
    rm dcm4che-5.22.5-bin.zip
    cd Niffler
    echo "true" > init/dcm4che.out
fi

MONGO=`head -n 1 init/mongo.out`
if [ "$MONGO" = false ] ; then
    echo "Installing mongo"
    wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | apt-key add -
    echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-5.0.list
    apt-get install -y mongodb-org
    systemctl start mongod
    systemctl enable mongod
    mongo init/mongoinit.js
    cp modules/meta-extraction/service/mdextractor.service /etc/systemd/system/
    systemctl daemon-reload
    systemctl start mdextractor.service
    systemctl enable mdextractor.service
    echo "true" > init/mongo.out
fi

SERVICE=`head -n 1 init/service.out`
if [ "$SERVICE" = false ] ; then
    echo "Installing Niffler Frontend"
    pip install -r modules/frontend/requirements.txt
    chmod +x modules/frontend/service/frontend_service.sh
    cp modules/frontend/service/niffler.service /etc/systemd/system/
    systemctl daemon-reload
    systemctl start niffler.service
    systemctl enable niffler.service
    echo "true" > init/service.out
fi
