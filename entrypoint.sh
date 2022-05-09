#!/bin/bash

red='\033[31m'
green='\033[32m'
reset='\033[0m'

php --version
platform --version
git --version

sed -i 's/#   StrictHostKeyChecking ask.*/StrictHostKeyChecking accept-new/' /etc/ssh/ssh_config
DAY=$(date +%F-%T)
FILENAME_DB="backup-db-$DAY"
FILENAME_PUBLIC="backup-public-files-$DAY"
FILENAME_PRIVATE="backup-private-files-$DAY"
FILENAME_SOURCE="backup-source-$DAY"

#--- database backup---
#echo -e "${red}Starting Database Backup...${reset}"
#platform db:dump -v --yes --project "$INPUT_PLATFORMSH_PROJECT" --environment "$INPUT_PLATFORMSH_ENVIRONMENT" --gzip -f "$FILENAME_DB".sql.gz
#aws s3 cp "$FILENAME_DB".sql.gz s3://"$INPUT_AWS_S3_BUCKET"/"$INPUT_PROJECT_NAME"/"$DAY"/ --quiet
#echo -e "${green}Finished Database Backup...${reset}"

#--- public files backup---
echo -e "${red}Starting Public Files Backup...${reset}"
platform mount:download -e "$INPUT_PLATFORMSH_ENVIRONMENT" --target "yyy" --mount "$INPUT_PUBLIC_FILES_PATH" --exclude 'styles' --exclude 'css' --exclude 'js' --exclude 'config_*' --exclude 'translations' -y
ls
zip -r "$FILENAME_PUBLIC".zip "yyy" -q
aws s3 cp "$FILENAME_PUBLIC".zip s3://"$INPUT_AWS_S3_BUCKET"/"$INPUT_PROJECT_NAME"/"$DAY"/ --quiet
echo -e "${green}Finished Public Files Backup...${reset}"


#---private files backup---
if [ "$INPUT_WITH_PRIVATE_FILES" = 'yes' ]
then
  echo -e "${red}Starting Private Files Backup...${reset}"
  platform mount:download -e "$INPUT_PLATFORMSH_ENVIRONMENT" --target "xxx" --mount "$INPUT_PRIVATE_FILES_PATH" --exclude 'twig' -y -q
  ls
  zip -r "$FILENAME_PRIVATE".zip "xxx" -q
  aws s3 cp "$FILENAME_PRIVATE".zip s3://"$INPUT_AWS_S3_BUCKET"/"$INPUT_PROJECT_NAME"/"$DAY"/ --quiet
  echo -e "${green}Finished Private Files Backup...${reset}"
fi

#---repo backup---
#echo -e "${red}Starting Source Code Backup...${reset}"
#git clone https://"$INPUT_GH_USER":"$GH_ACCESS_TOKEN"@github.com/"$INPUT_GH_REPOSITORY".git "$FILENAME_SOURCE" --quiet
#zip -r "$FILENAME_SOURCE".zip "$FILENAME_SOURCE" -q
#aws s3 cp "$FILENAME_SOURCE".zip s3://"$INPUT_AWS_S3_BUCKET"/"$INPUT_PROJECT_NAME"/"$DAY"/ --quiet
#echo -e "${green}Finished Source Code Backup...${reset}"
