################################
## Index S3 Objects in Synapse
################################

#############
# Required functions and libraries
#############
library(tidyverse)
library(synapser)
library(rjson)
synapser::synLogin()
source('awscli_utils.R')

#############
# Parameters
#############
source('params.R')

#############
# NOTE
#############
### First run data_sync.R and sync the S3 bucket to the local EC2 instance

#############
# Get bucket params and file list
#############
## Get a list of all Objects in the PRE_ETL S3 bucket 
s3lsBucketObjects(source_bucket = paste0('s3://', PRE_ETL_BUCKET,'/'),
                  output_file = FILE_LIST_OUTPUT)

# Get bucket params
bucket_params <- list(uploadType='S3',
                    concreteType='org.sagebionetworks.repo.model.project.ExternalS3StorageLocationSetting',
                    bucket=SOURCE_BUCKET)

# The above list is just to verify/reference, 
# since we will replicate the structure locally
# we will work with that

## Get a list of all local files
localFileList <- list.files(path = AWS_DOWNLOAD_LOCATION,
                            all.files = TRUE, # get hidden files too
                            recursive = TRUE, # get files inside sub-folders (if any)
                            full.names = FALSE) # to get the directory path prepended to the file name

#############
# Index in Synapse
#############
## For each file index it in Synapse given a parent synapse folder
for(file_ in localFileList){
  print(file_)
  absolute_file_path <- tools::file_path_as_absolute(paste0(AWS_DOWNLOAD_LOCATION,'/',file_))
  
  temp_syn_obj <- synapser::synCreateExternalS3FileHandle(
    bucket_name = bucket_params$bucket,
    s3_file_key = file_, # 
    file_path = absolute_file_path,
    parent = SYNAPSE_PARENT_ID
  )
  
  f <- File(dataFileHandleId=temp_syn_obj$id, 
            parentId=SYNAPSE_PARENT_ID,
            name = temp_syn_obj$fileName) ## set file name same as the one from realpath
  
  f <- synStore(f)
  
}

