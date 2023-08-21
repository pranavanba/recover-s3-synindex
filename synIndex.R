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
  dplyr::mutate(s3_file_key = paste0('main/', file_key)) %>% # the namespace for files in the S3 bucket is S3::bucket/main/
  dplyr::mutate(md5_hash = as.character(tools::md5sum(path))) %>% 
  dplyr::ungroup()

## All currently indexed files in Synapse
synapse_fileview <- synapser::synTableQuery(paste0('SELECT * FROM ', SYNAPSE_FILEVIEW_ID))$asDataFrame()

## find those files that are not in the fileview - files that need to be indexed
synapse_manifest_to_upload <- synapse_manifest %>% 
  dplyr::anti_join(synapse_fileview %>% 
                     dplyr::select(parent = parentId,
                                   s3_file_key = dataFileKey,
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
    s3_file_key = synapse_manifest_to_upload$s3_file_key[file_number]
    # this would be the location of the file in the S3 bucket, in the local it is at {AWS_DOWNLOAD_LOCATION}/
    
    absolute_file_path <- tools::file_path_as_absolute(file_) # local absolute path
    
    temp_syn_obj <- synapser::synCreateExternalS3FileHandle(
      bucket_name = PRE_ETL_BUCKET,
      s3_file_key = s3_file_key, #
      file_path = absolute_file_path,
      parent = parent_id
    )
    
    # synapse does not accept ':' (colon) in filenames, so replacing it with '_colon_'
    new_fileName <- stringr::str_replace_all(temp_syn_obj$fileName, ':', '_colon_')
    
    f <- File(dataFileHandleId=temp_syn_obj$id,
              parentId=parent_id,
              name = new_fileName) ## set the new file name
    
    f <- synStore(f)
    
  }
}

#############
# Rename folders with '_' to have '\' for eg., 'adults_v1' to 'adults\v1'
# to match with the next sync from S3 bucket
# This is to undo the renaming donw in data_sync.R
#############
# We will work with the locally replicated structure 
# all folders inside the AWS_DOWNLOAD_LOCATION, i.e all folders at AWS_DOWNLOAD_LOCATION/
localDirs <- list.dirs(path = AWS_DOWNLOAD_LOCATION, full.names = FALSE, recursive = FALSE) 

# The folders are named as 'adults\v1', 'pregnant\v1' and 'pediatric\v1'. We want to remove the
# '\' and replace it with '_'
for(dir_ in localDirs){
  dir_newName <- stringr::str_replace_all(dir_,'_',"\\\\")
  # rename each folder
  file.rename(paste0(AWS_DOWNLOAD_LOCATION,"/",dir_), paste0(AWS_DOWNLOAD_LOCATION,"/",dir_newName))
}

# Get newly renamed folders
localDirs <- list.dirs(path = AWS_DOWNLOAD_LOCATION, full.names = FALSE, recursive = FALSE) 


