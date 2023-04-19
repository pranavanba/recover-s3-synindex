##############
# Sync the input and pre-ETL buckets .This is to make a copy
# of the data provided to us by Care Evolution(CE) in the input bucket.
##############
source('awscli_utils.R')

#############
# Parameters
#############
SOURCE_BUCKET = 'sc-237179673806-pp-hrx2giywqix2s-s3bucket-mhb2u0tf0ift'
# S3 bucket whose objects are being copied

DESTINATION_BUCKET = 'sc-237179673806-pp-daamam3ykuje4-s3bucket-1jslzxl1xq4zm'
# S3 bucket to where objects are being copied into

LOCAL_SYNC_BUCKET = 'sc-237179673806-pp-i7vklp56the66-s3bucket-eal8qlgc87kj'
# S3 bucket to be synced locally
    
AWS_DOWNLOAD_LOCATION = 'temp_aws_2'
# Local location where Source bucket files are synced to

#############
# Sync S3 buckets 
#############
# <<values below are test values>>
s3SyncBuckets(source_bucket = paste0('s3://', SOURCE_BUCKET,'/'),
              destination_bucket = paste0('s3://', DESTINATION_BUCKET,'/'))
#############
# Sync the pre-ETL bucket to local EC2 instance
#############
# <<values below are test values>>
s3SyncToLocal(source_bucket = paste0('s3://', LOCAL_SYNC_BUCKET,'/'), local_destination = AWS_DOWNLOAD_LOCATION)
