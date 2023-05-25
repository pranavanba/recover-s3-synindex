FROM rocker/tidyverse

RUN apt-get update -y && apt-get upgrade -y && apt-get install -y python3 python3-pip python3-venv curl unzip git

RUN python3 -m pip install --upgrade pip
RUN pip install synapseclient
# RUN SYNASPECLIENT_INSTALL_PATH=$(python3 -c "import synapseclient; print(repr(synapseclient.__path__[0]))")
# ENV SYNASPECLIENT_INSTALL_PATH=$SYNASPECLIENT_INSTALL_PATH
# ENV SYNASPECLIENT_INSTALL_PATH="'/usr/local/lib'"

RUN git clone -b testing-docker-workflow https://github.com/pranavanba/recover-s3-synindex /recover-s3-synindex
RUN Rscript /recover-s3-synindex/install_requirements.R

RUN /recover-s3-synindex/aws_ssm_setup.sh

CMD R -e "q()" && bash /recover-s3-synindex/ingress_pipeline.sh
