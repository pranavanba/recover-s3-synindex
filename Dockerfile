FROM rocker/tidyverse

RUN apt-get update -y && apt-get upgrade -y && apt-get install -y python3 python3-pip python3-venv curl unzip git

RUN python3 -m pip install --upgrade pip
RUN pip install synapseclient
# RUN SYNASPECLIENT_INSTALL_PATH=$(python3 -c "import synapseclient; print(repr(synapseclient.__path__[0]))")
# ENV SYNASPECLIENT_INSTALL_PATH=$SYNASPECLIENT_INSTALL_PATH
# ENV SYNASPECLIENT_INSTALL_PATH="'/usr/local/lib'"

RUN git clone -b testing-docker-workflow https://github.com/pranavanba/recover-s3-synindex /recover-s3-synindex
RUN Rscript /recover-s3-synindex/install_requirements.R

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb" \
    && dpkg -i session-manager-plugin.deb \
    && curl -o synapse_creds.sh https://raw.githubusercontent.com/Sage-Bionetworks-IT/service-catalog-ssm-access/main/synapse_creds.sh \
    && chmod +x synapse_creds.sh \
    && mkdir -p /.aws \
    && curl -sSL https://raw.githubusercontent.com/Sage-Bionetworks-IT/service-catalog-ssm-access/main/config | sed "s|<PERSONAL_ACCESS_TOKEN>|${AWS_TOKEN}|g" > /.aws/config

CMD R -e "q()" && bash /recover-s3-synindex/ingress_pipeline.sh
