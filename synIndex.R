################################
## Index S3 Objects in Synapse
################################

## First run data_sync.R and generate_manifest.R in that order, before executing code below

#############
### Synapse credentials
#############
# Set the environment variables .Renviron file in your home folder. Refer to README for more details
SYNAPSE_AUTH_TOKEN = Sys.getenv('SYNAPSE_AUTH_TOKEN')

#############
# Required functions and libraries
#############
library(tidyverse)
library(synapser)
library(synapserutils)
library(rjson)
synapser::synLogin(authToken=SYNAPSE_AUTH_TOKEN)
source('~/recover-s3-synindex/awscli_utils.R')

#############
# Required Parameters
#############
source('~/recover-s3-synindex/params.R')

###########
## Get a list of all files to upload and their synapse locations(parentId) 
###########
STR_LEN_AWS_DOWNLOAD_LOCATION = stringr::str_length(AWS_DOWNLOAD_LOCATION)

## All files present locally from manifest
synapse_manifest <- read.csv('./current_manifest.tsv', sep = '\t', stringsAsFactors = F) %>% 
  dplyr::filter(path != paste0(AWS_DOWNLOAD_LOCATION,'owner.txt')) %>%  # need not create a dataFileHandleId for owner.txt
  dplyr::rowwise() %>% 
  dplyr::mutate(file_key = stringr::str_sub(string = path, start = STR_LEN_AWS_DOWNLOAD_LOCATION+1)) %>% # location of file from home folder of S3 bucket
  dplyr::mutate(file_key = paste0('staging/', file_key)) %>% # the namespace for files in the S3 bucket is S3::bucket/staging/
  dplyr::mutate(md5_hash = as.character(tools::md5sum(path))) %>% 
  dplyr::ungroup()

## All currently indexed files in Synapse
synapse_fileview <- synapser::synTableQuery(paste0('SELECT * FROM ', SYNAPSE_FILEVIEW_ID))$asDataFrame()

## find those files that are not in the fileview - files that need to be indexed
synapse_manifest_to_upload <- synapse_manifest %>% 
  dplyr::anti_join(synapse_fileview %>% 
                     dplyr::select(parent = parentId,
                                   file_key = dataFileKey,
                                   md5_hash = dataFileMD5Hex))

#############
# Index in Synapse
#############
## For each file index it in Synapse given a parent synapse folder
if(nrow(synapse_manifest_to_upload) > 0){ # there are some files to upload
  for(file_number in seq(nrow(synapse_manifest_to_upload))){
    
    # file and related synapse parent id 
    file_= synapse_manifest_to_upload$path[file_number]
    parent_id = synapse_manifest_to_upload$parent[file_number]
    s3_file_key = synapse_manifest_to_upload$file_key[file_number]
    # this would be the location of the file in the S3 bucket, in the local it is at {AWS_DOWNLOAD_LOCATION}/
    
    absolute_file_path <- tools::file_path_as_absolute(file_) # local absolute path
    
    temp_syn_obj <- synapser::synCreateExternalS3FileHandle(
      bucket_name = PRE_ETL_BUCKET,
      s3_file_key = s3_file_key, #
      file_path = absolute_file_path,
      parent = parent_id
    )
    
    f <- File(dataFileHandleId=temp_syn_obj$id,
              parentId=parent_id,
              name = temp_syn_obj$fileName) ## set file name same as the one from realpath
    
    f <- synStore(f)
    
  }
}


