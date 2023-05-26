##############
# Sync the input and pre-ETL buckets .This is to make a copy
# of the data provided to us by Care Evolution(CE) in the input bucket.
##############
## Required functions and parameters
source('~/recover-s3-synindex/awscli_utils.R')
source('~/recover-s3-synindex/params.R')

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

#############
# Get bucket params and file list
#############
# We will work with the locally replicated structure 
# all folders inside the AWS_DOWNLOAD_LOCATION, i.e all folders at AWS_DOWNLOAD_LOCATION/
localDirs <- list.dirs(path = AWS_DOWNLOAD_LOCATION, full.names = FALSE, recursive = FALSE) 

## The folders we want to show in synapse
## This would depend on the how the data is organized in the main S3 INGRESS bucket
FOLDERS_TO_SYNC_SYNAPSE <- c('adults',
                             'pregnant',
                             'pediatric') 

# When we create dataFileHandleId in synapse it will create some folders in the source S3 bucket
# we don't need those
## From the local AWS location remove all folders that are not the ones selected above
dirs_to_delete <- dplyr::setdiff(localDirs, c(FOLDERS_TO_SYNC_SYNAPSE, "")) # "" is the local directory, a result of list.dirs(.. full.names=FALSE)

## delete the unwanted directories before creating a upload manifest
for(dir_ in dirs_to_delete){
  unlink(paste0(AWS_DOWNLOAD_LOCATION,"/",dir_), recursive = TRUE)
}
