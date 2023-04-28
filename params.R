################################
## Required Parameters
################################

INGRESS_BUCKET = 'sc-237179673806-pp-a2c32zmbbq566-s3bucket-2vq5unuhcxjo'
# S3 bucket whose objects are being copied

PRE_ETL_BUCKET = 'sc-237179673806-pp-lytud6mnzjczm-s3bucket-edpunhjxp7bs'
# S3 bucket to where objects are being copied into

AWS_DOWNLOAD_LOCATION = 'temp_aws'
# Local location where Source bucket files are synced to

FILE_LIST_OUTPUT = 's3files.txt' 
# file name of the file where the aws ls output is saved

SYNAPSE_PARENT_ID = 'syn51399136'
# Synapse location where the S3 bucket objects are listed