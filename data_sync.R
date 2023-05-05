##############
# Sync the input and pre-ETL buckets .This is to make a copy
# of the data provided to us by Care Evolution(CE) in the input bucket.
##############
## Required functions and parameters
source('awscli_utils.R')
source('params.R')

#############
# Sync S3 buckets 
#############
# <<values below are test values>>
s3SyncBuckets(source_bucket = paste0('s3://', INGRESS_BUCKET,'/'),
              destination_bucket = paste0('s3://', PRE_ETL_BUCKET,'/staging/'))
#############
# Sync the pre-ETL bucket to local EC2 instance
#############
# <<values below are test values>>
s3SyncToLocal(source_bucket = paste0('s3://', PRE_ETL_BUCKET,'/staging'), local_destination = AWS_DOWNLOAD_LOCATION)
