#!/bin/bash

UNIQUER="11111"
LOCATION="westus2"

_azuresp_json=$(cat azuresp.json)
export ARM_CLIENT_ID=$(echo "${_azuresp_json}" | jq -r ".clientId")
export ARM_CLIENT_SECRET=$(echo "${_azuresp_json}" | jq -r ".clientSecret")
export ARM_SUBSCRIPTION_ID=$(echo "${_azuresp_json}" | jq -r ".subscriptionId")
export ARM_TENANT_ID=$(echo "${_azuresp_json}" | jq -r ".tenantId")

az login --service-principal --username "${ARM_CLIENT_ID}" --password "${ARM_CLIENT_SECRET}" --tenant "${ARM_TENANT_ID}"
az account set --subscription "${ARM_SUBSCRIPTION_ID}"
az deployment sub create --location "${LOCATION}" --template-file main.bicep # --parameters uniquer="${UNIQUER}" # what-if
