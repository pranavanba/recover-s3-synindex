# recover-s3-synindex

## Purpose
This repository helps index S3 objects in Synapse from a S3 bucket attached to a Synapse project/folder. The code is written in R and run from a Rstudio EC2 instance.

## Installation/Pre-requisites
1. Spin up a new EC2 Rstudio Notebook instance.
2. In the terminal, upgrade pip `python -m pip install --upgrade pip` before trying to install synapseclient.
3. Install synapseclient in the terminal using the folloiwing command
`pip install synapseclient`. 

Note: If you are having issues during installation, consider upgrading your pip `python -m pip install --upgrade pip` before trying to reinstall synapseclient - this should clear most issues. If you still have issues try force re-install synapseclient from the terminal `pip install --upgrade --force-reinstall synapseclient`

4. Create a `.Renviron` file in the home folder with the environment variables `SYNAPSE_USERNAME`, `SYNAPSE_PASSWORD` and `SYNASPECLIENT_INSTALL_PATH`, where `SYNAPSECLIENT_INSTALL_PATH` is the path where synapseclient was installed in step 2.

## Setting up SSM Access to the S3 bucket
5. Please follow instructions to [Create a Synapse personal access token(for AWS SSM Access)](https://sagebionetworks.jira.com/wiki/spaces/SC/pages/938836322/Service+Catalog+Provisioning#Create-a-Synapse-personal-access-token) 
6. Please follow instructions 3-5 to set up [SSM Access to an Instance](https://sagebionetworks.jira.com/wiki/spaces/SC/pages/938836322/Service+Catalog+Provisioning#SSM-access-to-an-Instance). (Note: AWS CLI version that is installed on the EC2 offering is ver 2.x)

Note: After setting this step, you should be able to run data_sync.R, i.e be able to sync data between two buckets, and also from a bucket to the local EC2 instance.

## Cloning repo and Installing required R libraries
7. Clone this repository and create a new project (Project -> Create Project -> Version Control). Switch to the new project.
8. Run [install_requirements.R](install_requirements.R).
9. Start new Rsession (type `q()` in Console).

## Ingress pipeline
10. Run [ingress_pipeline.sh](ingress_pipeline.sh) in the terminal using the command `bash ~/<path to>/ingress_pipeline.sh`
11. Set up [ingress_pipeline.sh](ingress_pipeline.sh) on a cronjob of your required frequency.
