FROM rocker/r-ver:4.2.2

RUN apt-get update -y && apt-get upgrade -y && apt-get install -y python3 python3-pip curl unzip git

RUN python3 -m pip install --upgrade pip

RUN pip install synapseclient

# RUN SYNASPECLIENT_INSTALL_PATH=$(python3 -c "import synapseclient; print(synapseclient.__path__[0])")
# ENV SYNASPECLIENT_INSTALL_PATH=$SYNASPECLIENT_INSTALL_PATH
RUN echo "SYNASPECLIENT_INSTALL_PATH='/usr/local/lib'" > ~/.Renviron

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install

RUN curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_arm64/session-manager-plugin.deb" -o "session-manager-plugin.deb" && \
    dpkg -i session-manager-plugin.deb

RUN curl -o synapse_creds.sh https://raw.githubusercontent.com/Sage-Bionetworks-IT/service-catalog-ssm-access/a1beccb32fad020687568450f89398c6d7daac34/synapse_creds.sh

RUN chmod +x synapse_creds.sh

RUN mkdir -p ~/.aws

RUN echo "[profile service-catalog]\n\
region=us-east-1\n\
credential_process = \"synapse_creds.sh\" \"https://sc.sageit.org\" \"\${AWS_TOKEN}\"\n" > ~/.aws/config

RUN git clone -b add-docker-workflow https://github.com/pranavanba/recover-s3-synindex

WORKDIR /recover-s3-synindex

RUN Rscript install_requirements.R

CMD R -e "q()" && bash ./ingress_pipeline.sh
