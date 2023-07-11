library(synapser)
library(arrow)
library(dplyr)

synapser::synLogin(authToken = daemon_pat)
# synapser::synLogin()

PARQUET_FOLDER <- "syn51406699"

# Get STS credentials
token <- synapser::synGetStsStorageToken(
  entity = PARQUET_FOLDER,
  permission = "read_only",
  output_format = "json")

# Pass STS credentials to Arrow filesystem interface
s3 <- arrow::S3FileSystem$create(
  access_key = token$accessKeyId,
  secret_key = token$secretAccessKey,
  session_token = token$sessionToken,
  region="us-east-1")

# List Parquet datasets
base_s3_uri <- paste0(token$bucket, "/", token$baseKey)
parquet_datasets <- s3$GetFileInfo(arrow::FileSelector$create(base_s3_uri, recursive=T))
for (dataset in parquet_datasets) {
  print(dataset$path)
}

AWS_DOWNLOAD_LOCATION <- './temp_aws_parquet'

list.files('./temp_aws_parquet/', recursive = T) %>% length()

patterns <- c("*owner.txt", "*archive*")
out <- list()
for (dataset in parquet_datasets) {
  for (file in dataset$path) {
    if (!grepl(paste(patterns, collapse = "|"), file)) {
      # s3$CopyFile(file, paste0(AWS_DOWNLOAD_LOCATION, gsub(base_s3_uri, "", file)))
      # print(paste0(AWS_DOWNLOAD_LOCATION, gsub(base_s3_uri, "", file)))
      out <- c(out, paste0(AWS_DOWNLOAD_LOCATION, gsub(base_s3_uri, "", file)))
    }
  }
}

# configure the environment with AWS token
Sys.setenv('AWS_ACCESS_KEY_ID'=token$accessKeyId,
           'AWS_SECRET_ACCESS_KEY'=token$secretAccessKey,
           'AWS_SESSION_TOKEN'=token$sessionToken)

aws.s3::s3sync(path = AWS_DOWNLOAD_LOCATION, bucket = 'recover-processed-data', prefix = 'main/parquet', direction = "download", region = "us-east-1")

source('~/recover-s3-synindex/awscli_utils.R')


s3SyncToLocal(source_bucket = paste0('s3://', base_s3_uri),
              local_destination = AWS_DOWNLOAD_LOCATION)

SYSTEM_COMMAND <- glue::glue('synapse manifest --parent-id {SYNAPSE_PARENT_ID} --manifest ./current_manifest.tsv {AWS_DOWNLOAD_LOCATION}')
system(SYSTEM_COMMAND)


