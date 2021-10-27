#!/bin/bash

declare LOCATION=$1
declare RESOURCES_PREFIX=$2
declare RESOURCES_SUFFIX=$3
declare KEY_VAULT_RESOURCE_GROUP_NAME=$4
declare KEY_VAULT_NAME=$5

declare -r USAGE_HELP="Usage: ./deploy.sh <LOCATION> <RESOURCES_PREFIX> <RESOURCES_SUFFIX> <KEY_VAULT_RESOURCE_GROUP_NAME> <KEY_VAULT_NAME>"

if [ $# -ne 5 ]; then
    echo "${USAGE_HELP}"
    exit 1
fi

# Check for programs
if ! [ -x "$(command -v az)" ]; then
    echo "az is not installed!"
    exit 1
fi

if [ -f "devvars.sh" ]; then
    . devvars.sh
fi

RESOURCE_GROUP_NAME="${RESOURCES_PREFIX}${RESOURCES_SUFFIX}rg"

if [ $(az group exists --name "${RESOURCE_GROUP_NAME}") = false ]; then
    az group create --name "${RESOURCE_GROUP_NAME}" --location "${LOCATION}"
fi

az deployment group create \
--resource-group "${RESOURCE_GROUP_NAME}" \
--template-file main.bicep \
--parameters keyVaultRgName="${KEY_VAULT_RESOURCE_GROUP_NAME}" keyVaultName="${KEY_VAULT_NAME}" resourcesPrefix="${RESOURCES_PREFIX}" resourcesSuffix="${RESOURCES_SUFFIX}"