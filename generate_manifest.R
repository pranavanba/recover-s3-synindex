#############
# Get a manifest of files to upload
#############

#############
### Synapse credentials and params
#############
# Set the environment variables .Renviron file in your home folder. Refer to README for more details
# SYNAPSECLIENT_INSTALL_PATH = Sys.getenv('SYNAPSECLIENT_INSTALL_PATH')
source('~/recover-s3-synindex/params.R')
### First run data_sync.R

## The S3 bucket is synced to AWS_DOWNLOAD_LOCATION locally. 
## We will use synapse cmd line client manifest function to replicate the folder structure 
## but NOT upload the files. We will create a datafilehandleid in place later instead of uploading file

# old_path <- Sys.getenv("PATH")

# if(!grepl(SYNAPSECLIENT_INSTALL_PATH,old_path)){
#   Sys.setenv(PATH = paste(old_path, SYNAPSECLIENT_INSTALL_PATH, sep = ":"))
#   ## When we install synapser, it installs synapseclient and along with it the synapse cmd line client
#   ## We need to add the location of synapseclient to the system path so that it can recognize synapse cmd 
# }

SYSTEM_COMMAND <- glue::glue('synapse manifest --parent-id {SYNAPSE_PARENT_ID} --manifest ./current_manifest.tsv {AWS_DOWNLOAD_LOCATION}')

### If the above fails
# SYNAPSE_AUTH_TOKEN = Sys.getenv('SYNAPSE_AUTH_TOKEN')
# SYSTEM_COMMAND <- glue::glue('SYNAPSE_AUTH_TOKEN="{SYNAPSE_AUTH_TOKEN}" synapse manifest --parent-id {SYNAPSE_PARENT_ID} --manifest ./current_manifest.tsv {AWS_DOWNLOAD_LOCATION}')

## Generate manifest file
system(SYSTEM_COMMAND)
