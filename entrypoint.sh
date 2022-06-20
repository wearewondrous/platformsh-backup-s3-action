#!/bin/bash

red='\033[31m'
green='\033[32m'
reset='\033[0m'

php --version
platform --version
git --version

sed -i 's/#   StrictHostKeyChecking ask.*/StrictHostKeyChecking accept-new/' /etc/ssh/ssh_config

#--- set variables ---
REPOSITORY_NAME=$(echo $GITHUB_REPOSITORY | awk -F '/' '{print $2}')
DATETIME=$(date +%FT%T)
S3_BASE_URI="s3://$INPUT_AWS_S3_BUCKET/$REPOSITORY_NAME"
S3_BACKUP_URI="S3_BASE_URI/$DATETIME/"

FILE_PREFIX="$REPOSITORY_NAME--$GITHUB_REF_NAME--$DATETIME"
FILENAME_DB="$FILE_PREFIX--database"
FILENAME_PUBLIC="$FILE_PREFIX--public-files"
FILENAME_PRIVATE="$FILE_PREFIX--private-files"
FILENAME_SOURCE="$FILE_PREFIX--source-code"

#--- database backup ---
echo -e "${red}Starting Database Backup...${reset}"
platform db:dump -v --yes --project "$INPUT_PLATFORMSH_PROJECT" --environment "$GITHUB_REF_NAME" --gzip -f "$FILENAME_DB".sql.gz
aws s3 cp "$FILENAME_DB".sql.gz "$S3_BACKUP_URI" --quiet
echo -e "${green}Finished Database Backup...${reset}"

#--- public files backup ---
echo -e "${red}Starting Public Files Backup...${reset}"
platform mount:download -e "$GITHUB_REF_NAME" --target "public-temp" --mount "$INPUT_PUBLIC_FILES_PATH" --exclude 'styles' --exclude 'css' --exclude 'js' --exclude 'config_*' --exclude 'translations' -y -q
ls
zip -r "$FILENAME_PUBLIC".zip "public-temp" -q
aws s3 cp "$FILENAME_PUBLIC".zip "$S3_BACKUP_URI" --quiet
echo -e "${green}Finished Public Files Backup...${reset}"

#--- private files backup ---
if [[ -d "$INPUT_PRIVATE_FILES_PATH" ]]
then
  echo -e "${red}Starting Private Files Backup...${reset}"
  platform mount:download -e "$GITHUB_REF_NAME" --target "private-temp" --mount "$INPUT_PRIVATE_FILES_PATH" --exclude 'twig' -y -q
  ls
  zip -r "$FILENAME_PRIVATE".zip "private-temp" -q
  aws s3 cp "$FILENAME_PRIVATE".zip "$S3_BACKUP_URI" --quiet
  echo -e "${green}Finished Private Files Backup...${reset}"
fi

#--- repo backup ---
echo -e "${red}Starting Source Code Backup...${reset}"
git clone https://"$INPUT_GH_USER":"$GH_ACCESS_TOKEN"@github.com/"$INPUT_GH_REPOSITORY".git "$FILENAME_SOURCE" --quiet
zip -r "$FILENAME_SOURCE".zip "$FILENAME_SOURCE" -q
aws s3 cp "$FILENAME_SOURCE".zip "$S3_BACKUP_URI" --quiet
echo -e "${green}Finished Source Code Backup...${reset}"
