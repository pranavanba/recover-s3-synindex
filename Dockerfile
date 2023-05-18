FROM rocker/r-ver:4.2.2

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y git python3 python3-pip python3-venv curl wget && \
    python -m pip install --upgrade pip

RUN pip install --upgrade --force-reinstall synapseclient
    
RUN sudo yum install -y https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm

RUN SYNASPECLIENT_INSTALL_PATH=$(python3 -c "import synapseclient; print(synapseclient.__path__[0])")
ENV SYNASPECLIENT_INSTALL_PATH=$SYNASPECLIENT_INSTALL_PATH

RUN wget https://github.com/Sage-Bionetworks-IT/service-catalog-ssm-access/raw/main/synapse_creds.sh
RUN chmod +x synapse_creds.sh

RUN mkdir -p ~/.aws/
RUN echo "[profile service-catalog]" >> ~/.aws/config && \
    echo "region=us-east-1" >> ~/.aws/config && \
    echo "credential_process = \"synapse_creds.sh\" \"https://sc.sageit.org\" \"${AWS_CLI_TOKEN}\"" >> ~/.aws/config

RUN git clone https://github.com/itismeghasyam/recover-s3-synindex

WORKDIR /recover-s3-synindex

RUN Rscript install_requirements.R

CMD R -e "q()" && bash ingress_pipeline.sh
