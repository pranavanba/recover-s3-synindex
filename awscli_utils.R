##########
## AWS CLI helper functions
## Uses synapse STS token to access AWS token
##########

####
# Sync between two buckets - source and destination
####
s3SyncBuckets <- function(source_bucket, destination_bucket){
  command_in <- glue::glue('aws --profile service-catalog s3 sync {source_bucket} {destination_bucket}')
  print(paste0('RUNNING: ',command_in))
  system(command_in)
}

####
# Sync to local location from a source bucket
####
s3SyncToLocal <- function(source_bucket, local_destination = './temp_aws'){
  command_in <- glue::glue('aws --profile service-catalog s3 sync {source_bucket} {local_destination}')
  print(paste0('RUNNING: ',command_in))
  system(command_in)
}

####
# Get a list of all files in a bucket, Stores to a txt file in the local working directory
####
s3lsBucketObjects <- function(source_bucket, output_file='s3files.txt'){
  command_in <- glue::glue('aws --profile service-catalog s3 ls {source_bucket} --recursive --output text > {output_file}')
  print(paste0('RUNNING: ',command_in))
  system(command_in)
}
