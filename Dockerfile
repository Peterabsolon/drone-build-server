FROM ubuntu:18.04

###############################################
# Setup Drone
###############################################
ARG DRONE_BUILD_SCRIPTS_PATH=/usr/local/drone_build_scripts
ENV DRONE_BUILD_SCRIPTS_PATH=$DRONE_BUILD_SCRIPTS_PATH

###############################################
# Shared dependencies
###############################################
RUN apt-get clean && apt-get update -y && \
    apt-get install wget build-essential sudo python3-distutils git-core curl build-essential openssl libssl-dev -y

###############################################
# Golang
###############################################
ENV GO_VERSION go1.13.5
ENV CGO_ENABLED 1
RUN wget -q https://dl.google.com/go/${GO_VERSION}.linux-amd64.tar.gz
RUN tar -xzf ${GO_VERSION}.linux-amd64.tar.gz -C /usr/local
ENV PATH ${PATH}:/usr/local/go/bin

###############################################
# GCloud SDK
###############################################
RUN apt-get -y install apt-transport-https ca-certificates gnupg lsb-release unzip
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
RUN sudo apt-get update && sudo apt-get install google-cloud-sdk -y


###############################################
# GCloud service account ssh util
###############################################
RUN curl -O https://raw.githubusercontent.com/GoogleCloudPlatform/python-docs-samples/master/compute/oslogin/service_account_ssh.py
RUN mv service_account_ssh.py /usr/local/service_account_ssh.py
RUN sudo chmod +x /usr/local/service_account_ssh.py
RUN sudo apt-get update && sudo apt-get install python python-pip -y
RUN pip install requests
RUN pip install --upgrade google-api-python-client

###############################################
# GCloud SQL Proxy
###############################################
RUN wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O /usr/local/cloud_sql_proxy
RUN sudo chmod +x /usr/local/cloud_sql_proxy

###############################################
# PostgreSQL
###############################################
RUN touch /etc/apt/sources.list.d/pgdg.list
RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main' >> /etc/apt/sources.list.d/pgdg.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt-get update
RUN apt-get install -y postgresql-client-12

###############################################
# DB migrate tool
###############################################
RUN curl -L https://github.com/golang-migrate/migrate/releases/download/v4.8.0/migrate.linux-amd64.tar.gz | tar xvz
RUN mv migrate.linux-amd64 /usr/local/bin/migrate

###############################################
# Node
###############################################
ARG VERSION=13.9.0
RUN curl -sL https://deb.nodesource.com/setup_${VERSION}} | bash
RUN apt-get install nodejs npm -y
RUN sudo npm install -g yarn 

###############################################
# SSH
###############################################
COPY secrets/id_rsa /root/.ssh/
RUN apt-get install openssh-client -y
RUN chmod 0600 /root/.ssh/id_rsa \
    && eval $(ssh-agent) \
    && ssh-add ~/.ssh/id_rsa

###############################################
# Script for running GCloud SQL Proxy
###############################################
COPY run_cloud_sql_proxy.sh /usr/local/run_cloud_sql_proxy.sh
RUN sudo chmod +x /usr/local/run_cloud_sql_proxy.sh

###############################################
# GCloud auth
###############################################
ENV GOOGLE_APPLICATION_CREDENTIALS=/usr/local/ssh-master-account-key.json
COPY secrets/ssh-master-account-key.json $GOOGLE_APPLICATION_CREDENTIALS

###############################################
# Project build scripts
###############################################
COPY scripts ${DRONE_BUILD_SCRIPTS_PATH}