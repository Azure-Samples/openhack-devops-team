#!/bin/bash

UNIQUER="99999"
LOCATION="westus2"

_azuresp_json=$(cat azuresp.json)
export ARM_CLIENT_ID=$(echo "${_azuresp_json}" | jq -r ".clientId")
export ARM_CLIENT_SECRET=$(echo "${_azuresp_json}" | jq -r ".clientSecret")
export ARM_SUBSCRIPTION_ID=$(echo "${_azuresp_json}" | jq -r ".subscriptionId")
export ARM_TENANT_ID=$(echo "${_azuresp_json}" | jq -r ".tenantId")

terraform init
terraform plan -var="location=${LOCATION}" --detailed-exitcode -var="uniquer=${UNIQUER}"
if [ $? -eq 2 ]
then
    terraform apply --auto-approve -var="location=${LOCATION}" -var="uniquer=${UNIQUER}"
fi

rm -rf openhack-devops-proctor

# rm -rf .terraform && rm -rf .terraform.lock.hcl && rm -rf terraform.tfstate && rm -rf terraform.tfstate.backup