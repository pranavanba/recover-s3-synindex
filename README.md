# recover-s3-synindex

## Purpose
This repository helps index S3 objects in Synapse from a S3 bucket attached to a Synapse project/folder. The code is written in R and run from a Rstudio EC2 instance.

## Installation/Pre-requisites
1. Spin up a new EC2 Rstudio Notebook instance.
2. Install synapseclient in the terminal using the folloiwing command
`pip install synapseclient`. 
Note: If you are having issues during installation, consider upgrading your pip `python -m pip install --upgrade pip` before trying to reinstall synapseclient - this should clear most issues. If you still have issues try force re-install synapseclient from the terminal `pip install --upgrade --force-reinstall synapseclient`
3. Create a `.Renviron` file in the home folder with the environment variables `SYNAPSE_USERNAME`, `SYNAPSE_PASSWORD` and `SYNASPECLIENT_INSTALL_PATH`, where `SYNAPSECLIENT_INSTALL_PATH` is the path where synapseclient was installed in step 2.

## Setting up SSM Access to the S3 bucket
Please follow instructions as mentioned in [SSM access to an instance](https://sagebionetworks.jira.com/wiki/spaces/SC/pages/938836322/Service+Catalog+Provisioning#SSM-access-to-an-Instance
) in Confluence docs. 

Note: After setting this step, you should be able to run data_sync.R, i.e be able to sync data between two buckets, and also from a bucket to the local EC2 instance.

## 
