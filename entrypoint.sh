#!/bin/bash

red='\033[31m'
green='\033[32m'
reset='\033[0m'

php --version
platform --version

FILENAME="backup-$(date +%F-%T)"

platform environment:info --project "$INPUT_PLATFORMSH_PROJECT" --environment "$INPUT_PLATFORMSH_ENVIRONMENT"

#--- database backup---
echo -e "${red}Starting Database Backup...${reset}"
platform db:dump -v --yes --project "$INPUT_PLATFORMSH_PROJECT" --environment "$INPUT_PLATFORMSH_ENVIRONMENT" --gzip -f "$FILENAME".sql.gz
#todo upload
echo -e "${green}Finished Database Backup...${reset}"

#--- public files backup---
echo -e "${red}Starting Public Files Backup...${reset}"
rsync -azv --exclude 'styles' --exclude 'css' --exclude 'js' --exclude 'config_*' `platform ssh --pipe -e "$INPUT_PLATFORMSH_ENVIRONMENT"`:/app/"$INPUT_WITH_PUBLIC_FILES" ./"$INPUT_WITH_PUBLIC_FILES"/
#todo upload
echo -e "${green}Finished Public Files Backup...${reset}"
#---private files backup---
if [ "$INPUT_WITH_PRIVATE_FILES" = 'yes' ]
then
  echo -e "${red}Starting Private Files Backup...${reset}"
  rsync -azv `platform ssh --pipe -e "$INPUT_PLATFORMSH_ENVIRONMENT"`:/"$INPUT_WITH_PRIVATE_FILES" ./"$INPUT_WITH_PRIVATE_FILES"/
  #todo upload
  echo -e "${green}Starting Private Files Backup...${reset}"
fi

#---repo backup---

