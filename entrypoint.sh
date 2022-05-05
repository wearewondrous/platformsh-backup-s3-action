#!/bin/bash

red='\033[31m'
green='\033[32m'
reset='\033[0m'

ENVIRONMENT="$INPUT_PLATFORMSH_ENVIRONMENT"

php --version
platform --version
git --version

sed -i 's/#   StrictHostKeyChecking ask.*/StrictHostKeyChecking accept-new/' /etc/ssh/ssh_config
FILENAME="backup-$(date +%F-%T)"

platform environment:info --project "$INPUT_PLATFORMSH_PROJECT" --environment "$INPUT_PLATFORMSH_ENVIRONMENT"

#--- database backup---
#echo -e "${red}Starting Database Backup...${reset}"
#platform db:dump -v --yes --project "$INPUT_PLATFORMSH_PROJECT" --environment "$INPUT_PLATFORMSH_ENVIRONMENT" --gzip -f "$FILENAME".sql.gz
##todo upload
#echo -e "${green}Finished Database Backup...${reset}"

#--- public files backup---
#echo -e "${red}Starting Public Files Backup...${reset}"
#platform mount:download -e "$INPUT_PLATFORMSH_ENVIRONMENT" --target "$INPUT_PUBLIC_FILES_PATH" --mount "$INPUT_PUBLIC_FILES_PATH" --exclude 'styles' --exclude 'css' --exclude 'js' --exclude 'config_*' --exclude 'translations' -y
##todo upload
#echo -e "${green}Finished Public Files Backup...${reset}"


#---private files backup---
#if [ "$INPUT_WITH_PRIVATE_FILES" = 'yes' ]
#then
#  echo -e "${red}Starting Private Files Backup...${reset}"
#  platform mount:download -e "$INPUT_PLATFORMSH_ENVIRONMENT" --target "$INPUT_PRIVATE_FILES_PATH" --mount "$INPUT_PRIVATE_FILES_PATH" --exclude 'twig' -y
#  echo -e "${green}Finished Private Files Backup...${reset}"
#fi

#---repo backup---
echo -e "${red}Starting Source Backup...${reset}"
git clone https://"$INPUT_GH_USER":"$GH_ACCESS_TOKEN"@github.com/"$INPUT_GH_REPOSITORY".git repo_backup
ls
echo -e "${green}Finished Private Files Backup...${reset}"

