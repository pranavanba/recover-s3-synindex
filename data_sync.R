##############
# Sync the input and pre-ETL buckets .This is to make a copy
# of the data provided to us by Care Evolution(CE) in the input bucket.
##############
source('awscli_utils.R')

## sync S3 buckets 
# <<values below are test values>>
s3SyncBuckets(source_bucket = 's3://sc-237179673806-pp-hrx2giywqix2s-s3bucket-mhb2u0tf0ift/',
              destination_bucket = 's3://sc-237179673806-pp-daamam3ykuje4-s3bucket-1jslzxl1xq4zm/')

## sync the pre-ETL bucket to local EC2 instance
# <<values below are test values>>
s3SyncToLocal(source_bucket = 's3://sc-237179673806-pp-daamam3ykuje4-s3bucket-1jslzxl1xq4zm/')
