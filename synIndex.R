################################
## Index S3 Objects in Synapse
################################

#############
### Synapse credentials
#############
synapse_creds <- read.table('synapse_creds.txt', header = F, sep = '=', stringsAsFactors = F) 
SYNAPSE_USERNAME <- synapse_creds$V2[1]
SYNAPSE_PASSWORD <- synapse_creds$V2[2]

#############
# Required functions and libraries
#############
library(tidyverse)
library(synapser)
library(synapserutils)
library(rjson)
synapser::synLogin(SYNAPSE_USERNAME, SYNAPSE_PASSWORD)
source('awscli_utils.R')

#############
# Required Parameters
#############
source('params.R')
SYNAPSE_FILEVIEW_ID = 'syn51399596'

#############
# NOTE
#############
### First run data_sync.R and sync the S3 bucket to the local EC2 instance

#############
# Get bucket params and file list
#############
## Get a list of all Objects in the PRE_ETL S3 bucket 
# s3lsBucketObjects(source_bucket = paste0('s3://', PRE_ETL_BUCKET,'/'),
#                   output_file = FILE_LIST_OUTPUT)

# Get bucket params
bucket_params <- list(uploadType='S3',
                      concreteType='org.sagebionetworks.repo.model.project.ExternalS3StorageLocationSetting',
                      bucket=PRE_ETL_BUCKET)

# The above list is just to verify/reference, 
# since we will replicate the structure locally
# we will work with that

# all folders inside the AWS_DOWNLOAD_LOCATION
# When we create dataFileHandleId in synapse it will create some folders in the source S3 bucket
# we don't need those
localDirs <- list.dirs(path = AWS_DOWNLOAD_LOCATION, full.names = FALSE) 


## The folders we want to show in synapse
## This would depend on the how the data is organized in the main S3 INGRESS bucket
FOLDERS_TO_SYNC_SYNAPSE <- c('adults',
                             'pregnant',
                             'pediatric') 

## From the local AWS location remove all folders that are not the ones selected above
dirs_to_delete <- dplyr::setdiff(localDirs, c(FOLDERS_TO_SYNC_SYNAPSE, "")) # "" is the local directory, a result of list.dirs(.. full.names=FALSE)

## delete the unwanted directories before creating a upload manifest
for(dir_ in dirs_to_delete){
  unlink(paste0(AWS_DOWNLOAD_LOCATION,"/",dir_), recursive = TRUE)
}


# localFileList <- list.files(path = AWS_DOWNLOAD_LOCATION,
#                             all.files = TRUE, # get hidden files too
#                             recursive = TRUE, # get files inside sub-folders (if any)
#                             full.names = FALSE) # to get the directory path prepended to the file name

#############
# Get a manifest of files to upload
#############
## The S3 bucket is synced to AWS_DOWNLOAD_LOCATION locally. 
## We will use synapse cmd line client manifest function to replicate the folder structure 
## but NOT upload the files. We will create a datafilehandleid in place later instead of uploading file

old_path <- Sys.getenv("PATH")
Sys.setenv(PATH = paste(old_path, "/home/ubuntu/R/x86_64-pc-linux-gnu-library/3.6/PythonEmbedInR/bin", sep = ":"))
## When we install synapser, it installs synapseclient and along with it the synapse cmd line client

SYSTEM_COMMAND <- glue::glue('synapse -u "{SYNAPSE_USERNAME}" -p "{SYNAPSE_PASSWORD}" manifest --parent-id {SYNAPSE_PARENT_ID} --manifest current_manifest.tsv {AWS_DOWNLOAD_LOCATION}')

## Generate manifest file
system(SYSTEM_COMMAND)
###########
## Get a list of all files to upload and their synapse locations(parentId) 
###########
STR_LEN_AWS_DOWNLOAD_LOCATION = stringr::str_length(AWS_DOWNLOAD_LOCATION)

synapse_manifest <- read.csv('current_manifest.tsv', sep = '\t', stringsAsFactors = F) %>% 
  dplyr::filter(path != paste0(AWS_DOWNLOAD_LOCATION,'/owner.txt')) %>%  # need not create a dataFileHandleId for owner.txt
  dplyr::rowwise() %>% 
  dplyr::mutate(file_key = stringr::str_sub(string = path, start = STR_LEN_AWS_DOWNLOAD_LOCATION+2)) %>% # location of file from home folder of S3 bucket 
  dplyr::ungroup()

synapse_fileview <- synapser::synTableQuery(paste0('SELECT * FROM ', SYNAPSE_FILEVIEW_ID))$asDataFrame()


## find those files that are not in the fileview
synapse_manifest_to_upload <- synapse_manifest %>% 
  dplyr::anti_join(synapse_fileview %>% 
                     dplyr::select(parent = parentId,
                                   file_key = dataFileKey))


#############
# Index in Synapse
#############
## For each file index it in Synapse given a parent synapse folder
# for(file_ in localFileList){
#   print(file_)
#   absolute_file_path <- tools::file_path_as_absolute(paste0(AWS_DOWNLOAD_LOCATION,'/',file_))
#   print(absolute_file_path)
# }

if(nrow(synapse_manifest_to_upload) > 0){ # there are some files to upload
  for(file_number in seq(nrow(synapse_manifest_to_upload))){
    
    # file and related synapse parent id 
    file_= synapse_manifest_to_upload$path[file_number]
    parent_id = synapse_manifest_to_upload$parent[file_number]
    s3_file_key = synapse_manifest_to_upload$file_key[file_number]
    # this would be the location of the file in the S3 bucket, in the local it is at {AWS_DOWNLOAD_LOCATION}/
    # that is why we remove that part of the string
    
    # print(file_)
    # print(parent_id)
    
    absolute_file_path <- tools::file_path_as_absolute(file_) # local absolute path
    # print(absolute_file_path)
    
    temp_syn_obj <- synapser::synCreateExternalS3FileHandle(
      bucket_name = bucket_params$bucket,
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

