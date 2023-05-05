#############
# Get a manifest of files to upload
#############

#############
### Synapse credentials and params
#############
# Set the environment variables .Renviron file in your home folder. Refer to README for more details
SYNAPSE_USERNAME= Sys.getenv('SYNAPSE_USERNAME')
SYNAPSE_PASSWORD= Sys.getenv('SYNAPSE_PASSWORD')
source('params.R')
### First run data_sync.R

## The S3 bucket is synced to AWS_DOWNLOAD_LOCATION locally. 
## We will use synapse cmd line client manifest function to replicate the folder structure 
## but NOT upload the files. We will create a datafilehandleid in place later instead of uploading file

old_path <- Sys.getenv("PATH")

if(!grepl("/home/ubuntu/R/x86_64-pc-linux-gnu-library/3.6/PythonEmbedInR/bin",old_path)){
  Sys.setenv(PATH = paste(old_path, "/home/ubuntu/R/x86_64-pc-linux-gnu-library/3.6/PythonEmbedInR/bin", sep = ":"))
  ## When we install synapser, it installs synapseclient and along with it the synapse cmd line client
  ## We need to add the location of synapseclient to the system path so that it can recognize synapse cmd 
}


SYSTEM_COMMAND <- glue::glue('synapse -u "{SYNAPSE_USERNAME}" -p "{SYNAPSE_PASSWORD}" manifest --parent-id {SYNAPSE_PARENT_ID} --manifest ./current_manifest.tsv {AWS_DOWNLOAD_LOCATION}')

## Generate manifest file
system(SYSTEM_COMMAND)
