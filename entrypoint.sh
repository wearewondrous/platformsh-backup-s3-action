#!/bin/bash

php --version
aws --version
platform --version

FILENAME="backup-$(date +%F-%T)"

platform environment:info --project "$INPUT_PLATFORMSH_PROJECT" --environment "$INPUT_PLATFORMSH_ENVIRONMENT"
