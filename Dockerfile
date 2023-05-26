FROM rocker/tidyverse

RUN apt-get update -y && apt-get upgrade -y && apt-get install -y python3 python3-pip python3-venv curl unzip git

RUN python3 -m pip install --upgrade pip
RUN pip install synapseclient

RUN git clone -b add-docker-workflow https://github.com/pranavanba/recover-s3-synindex /root/recover-s3-synindex
RUN Rscript /root/recover-s3-synindex/install_requirements.R

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install

RUN curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb" \
    && dpkg -i session-manager-plugin.deb

RUN curl -o /root/synapse_creds.sh https://raw.githubusercontent.com/Sage-Bionetworks-IT/service-catalog-ssm-access/main/synapse_creds.sh \
    && chmod +x /root/synapse_creds.sh

RUN mkdir -p /root/.aws \
    && curl -sSL https://raw.githubusercontent.com/Sage-Bionetworks-IT/service-catalog-ssm-access/main/config | sed -e "s|\"<PERSONAL_ACCESS_TOKEN>\"|\"\${AWS_TOKEN}\"\n|g" -e "s|/absolute/path/to/synapse_creds.sh|/root/synapse_creds.sh|g" > /root/.aws/config

CMD R -e "q()" && sed -i "s|\${AWS_TOKEN}|$AWS_TOKEN|g" /root/.aws/config && bash /root/recover-s3-synindex/ingress_pipeline.sh
