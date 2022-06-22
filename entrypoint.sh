#!/bin/bash

green='\033[32m'
yellow="\033[33m"
blue="\033[34m"
reset='\033[0m'

sed -i 's/#   StrictHostKeyChecking ask.*/StrictHostKeyChecking accept-new/' /etc/ssh/ssh_config

#--- set variables ---
REPOSITORY_NAME=$(echo $GITHUB_REPOSITORY | awk -F '/' '{print $2}')
DATETIME=$(date +%FT%T)
S3_BASE_URI="s3://$INPUT_AWS_S3_BUCKET/$REPOSITORY_NAME"
S3_BACKUP_URI="$S3_BASE_URI/$DATETIME/"

FILE_PREFIX="$REPOSITORY_NAME--$INPUT_TARGET_BRANCH--$DATETIME"
FILENAME_DB="$FILE_PREFIX--database"
FILENAME_PUBLIC="$FILE_PREFIX--public-files"
FILENAME_PRIVATE="$FILE_PREFIX--private-files"
FILENAME_SOURCE="$FILE_PREFIX--source-code"

PLATFORM_CLI_DEFAULT_ARGS="--yes --quiet --project $INPUT_PLATFORMSH_PROJECT --environment $INPUT_TARGET_BRANCH"
#--- database backup ---
echo -e "${yellow}Starting Database Backup...${reset}"
platform db:dump $PLATFORM_CLI_DEFAULT_ARGS --gzip -f "$FILENAME_DB".sql.gz
aws s3 cp "$FILENAME_DB".sql.gz "$S3_BACKUP_URI" --only-show-errors
echo -e "${green}Finished Database Backup...${reset}"

#--- public files backup ---
echo -e "${yellow}Starting Public Files Backup...${reset}"
platform mount:download $PLATFORM_CLI_DEFAULT_ARGS --target "public-temp" --mount "$INPUT_PUBLIC_FILES_PATH" --exclude 'styles' --exclude 'css' --exclude 'js' --exclude 'config_*' --exclude 'translations'
zip -r "$FILENAME_PUBLIC".zip "public-temp" -q
aws s3 cp "$FILENAME_PUBLIC".zip "$S3_BACKUP_URI" --only-show-errors
echo -e "${green}Finished Public Files Backup...${reset}"

#--- private files backup ---
echo -e "${yellow}Starting Private Files Backup...${reset}"
platform mount:download $PLATFORM_CLI_DEFAULT_ARGS --target "private-temp" --mount "$INPUT_PRIVATE_FILES_PATH" --exclude 'twig'
zip -r "$FILENAME_PRIVATE".zip "private-temp" -q
aws s3 cp "$FILENAME_PRIVATE".zip "$S3_BACKUP_URI" --only-show-errors
echo -e "${green}Finished Private Files Backup...${reset}"

#--- repo backup ---
echo -e "${yellow}Starting Source Code Backup...${reset}"

REMOTE_REPO_URL="https://$INPUT_GH_USER:$GH_ACCESS_TOKEN@github.com/$GITHUB_REPOSITORY.git"

git clone --branch "$INPUT_TARGET_BRANCH" "$REMOTE_REPO_URL" "$FILENAME_SOURCE" --quiet
zip -r "$FILENAME_SOURCE".zip "$FILENAME_SOURCE" -q
aws s3 cp "$FILENAME_SOURCE".zip "$S3_BACKUP_URI" --only-show-errors
echo -e "${green}Finished Source Code Backup...${reset}"

echo -e "${green}Files generated locally ${reset}"
ls -d "$REPOSITORY_NAME--"*

#--- cleanup s3 folder ---
if [[ $INPUT_DAYS_TO_BACKUP != '0' ]]
then
  echo -e "${yellow}Cleaning up Backups older than $INPUT_DAYS_TO_BACKUP days... ${reset}"

  # get aws ls output into an array
  IFS=$'\n' read -r -d '' -a BUCKETLIST < <( aws s3 ls "$S3_BASE_URI/" && printf '\0' )

  # remove last line from ls output, a summary line
  unset 'BUCKETLIST[${#BUCKETLIST[@]}-1]'

  if [[ ${#BUCKETLIST[@]} -gt 0 ]]
  then
    for BUCKET in "${BUCKETLIST[@]}"; do
      # trim ls output to only contain the folder name formatted as ISO 8601 date
      # expecting something like "PRE 2022-06-20T12:00:00/"
      FOLDER_NAME=$(echo $BUCKET | cut -c5-23)

      CREATE_TIMESTAMP=`date -d"$FOLDER_NAME" +%s`
      BEFORE_TIMESTAMP=`date -d"-$INPUT_DAYS_TO_BACKUP days" +%s`

      if [[ $CREATE_TIMESTAMP -lt $BEFORE_TIMESTAMP ]]
        then
          S3_OUTDATED_BACKUP_URI="$S3_BASE_URI/$FOLDER_NAME/"

          echo -e "${blue}deleting $FOLDER_NAME ${reset}"

          aws s3 rm "$S3_OUTDATED_BACKUP_URI" --recursive --only-show-errors
      fi
    done
  else
    echo -e "${green}Nothing to cleanup...${reset}"
  fi

  echo -e "${green}Finished cleanup...${reset}"
else
  echo -e "${green}Skipping cleanup...${reset}"
fi
