FROM rocker/r-ver:4.2.2

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y git python3 python3-pip python3-venv curl && \
    python -m pip install --upgrade pip && \
    pip install --upgrade --force-reinstall synapseclient && \
    sudo yum install -y https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm

RUN SYNASPECLIENT_INSTALL_PATH=$(python3 -c "import synapseclient; print(synapseclient.__path__[0])")

ENV SYNAPSE_AUTH_TOKEN=<synapse_auth_token>
ENV SYNASPECLIENT_INSTALL_PATH=$SYNASPECLIENT_INSTALL_PATH

RUN git clone https://github.com/itismeghasyam/recover-s3-synindex

WORKDIR /recover-s3-synindex

RUN Rscript install_requirements.R

CMD R -e "q()" && bash ingress_pipeline.sh
