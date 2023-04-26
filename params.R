################################
## Required Parameters
################################

INGRESS_BUCKET = 'sc-237179673806-pp-hrx2giywqix2s-s3bucket-mhb2u0tf0ift'
# S3 bucket whose objects are being copied

PRE_ETL_BUCKET = 'sc-237179673806-pp-daamam3ykuje4-s3bucket-1jslzxl1xq4zm'
# S3 bucket to where objects are being copied into

AWS_DOWNLOAD_LOCATION = 'temp_aws'
# Local location where Source bucket files are synced to

FILE_LIST_OUTPUT = 's3files.txt' 
# file name of the file where the aws ls output is saved

SYNAPSE_PARENT_ID = 'syn51364759'
# Synapse location where the objects are listed