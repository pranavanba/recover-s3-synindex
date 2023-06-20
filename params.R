################################
## Required Parameters
################################

INGRESS_BUCKET = 'sc-237179673806-pp-uogqfh4kldop4-s3bucket-152jqu6hxr1zt' 
# S3 bucket whose objects are being copied: recover-dev-ingestion

PRE_ETL_BUCKET = 'sc-237179673806-pp-5yw6pwnyh6ue6-s3bucket-v7r5g2lwvu7y'
# S3 bucket to where objects are being copied into: recover-dev-input-data

AWS_DOWNLOAD_LOCATION = './temp_aws/main/'
# Local location where Source bucket files are synced to

FILE_LIST_OUTPUT = 's3files.txt' 
# file name of the file where the aws ls output is saved

SYNAPSE_PARENT_ID = 'syn51517390'
# Synapse location where the S3 bucket objects are listed

SYNAPSE_FILEVIEW_ID = 'syn51399596'
# Synapse ID of the fileview containing list of all currentlty indexed S3 objects in Synapse