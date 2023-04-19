#############
# Index S3 Objects in Synapse
#############
library(tidyverse)
library(synapser)
library(rjson)
synapser::synLogin()

### First run data_sync.R and sync the S3 bucket to the local EC2 instance

source('awscli_utils.R')

## Get a list of all Objects in the S3 bucket
s3lsBucketObjects(source_bucket = 's3://sc-237179673806-pp-daamam3ykuje4-s3bucket-1jslzxl1xq4zm/',
                  output_file = 's3files.txt')

# Get bucket params
bucket_params <- list(uploadType='S3',
                    concreteType='org.sagebionetworks.repo.model.project.ExternalS3StorageLocationSetting',
                    bucket='sc-237179673806-pp-daamam3ykuje4-s3bucket-1jslzxl1xq4zm')

# The above list is just to verify/reference, 
# since we will replicate the structure locally
# we will work with that

## Get a list of all local files
localFileList <- list.files(path = 'temp_aws',
                            all.files = TRUE, # get hidden files too
                            recursive = TRUE, # get files inside sub-folders (if any)
                            full.names = FALSE) # to get the directory path prepended to the file name

## For each file index it in Synapse given a parent synapse folder
for(file_ in localFileList){
  print(file_)
  absolute_file_path <- tools::file_path_as_absolute(paste0('temp_aws/',file_))
  
  temp_syn_obj <- synapser::synCreateExternalS3FileHandle(
    bucket_name = bucket_params$bucket,
    s3_file_key = file_, # 
    file_path = absolute_file_path,
    parent = 'syn51273216'
  )
  
  f <- File(dataFileHandleId=temp_syn_obj$id, 
            parentId='syn51273216',
            name = temp_syn_obj$fileName) ## set file name same as the one from realpath
  
  f <- synStore(f)
  
}

