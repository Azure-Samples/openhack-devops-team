#!/bin/bash

# Set AZURE_DEVOPS_EXT_PAT with your PAT befor running this script
# export export AZURE_DEVOPS_EXT_PAT="YourPat"

# ./generic_endpoint.sh AdoOrganization AdoProject SvcEndpointName SvcEndpointUrl

AZURE_DEVOPS_ORGANIZATION=$1 # $(System.CollectionUri)
AZURE_DEVOPS_PROJECT=$2 # $(System.TeamProject)
SVC_ENDPOINT_NAME=$3
SVC_ENDPOINT_URL=$4

az devops configure --defaults organization="${AZURE_DEVOPS_ORGANIZATION}" project="${AZURE_DEVOPS_PROJECT}"

id=$(az devops service-endpoint list --query "[?name == '${SVC_ENDPOINT_NAME}'].id | join(', ', @)" --output tsv)
if [[ ${#id} == 0 ]]; then
    payload=$(cat generic_endpoint_template.json)
    echo $payload | jq -c -r '.name = "'${SVC_ENDPOINT_NAME}'" | .url = "'${SVC_ENDPOINT_URL}'"' > _endpoint.temp.json
    id=$(az devops service-endpoint create --service-endpoint-configuration _endpoint.temp.json --output tsv --query id)
    rm -f _endpoint.temp.json
    az devops service-endpoint update --id ${id} --enable-for-all true > /dev/null
    echo "${SVC_ENDPOINT_NAME} service endpoint creadted! id: ${id}"
else
    echo "${SVC_ENDPOINT_NAME} service endpoint already exists!"
fi