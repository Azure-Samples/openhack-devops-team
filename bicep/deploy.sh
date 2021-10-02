#!/bin/bash

declare UNIQUER=""
declare LOCATION=""
declare RESOURCES_PREFIX=""
declare -r USAGE_HELP="Usage: ./deploy.sh -l <LOCATION> [-u <UNIQUER> -r <RESOURCES_PREFIX>]"

_error() {
    echo "##[error] $@" 2>&1
}

if [ $# -eq 0 ]; then
    _error "${USAGE_HELP}"
    exit 1
fi

# Initialize parameters specified from command line
while getopts ":l:u:r:" arg; do
    case "${arg}" in
        l) # Process -l (LOCATION)
            LOCATION="${OPTARG}"
        ;;
        u) # Process -u (UNIQUER)
            UNIQUER="${OPTARG}"
        ;;
        r) # Process -r (RESOURCES_PREFIX)
            RESOURCES_PREFIX="${OPTARG}"
        ;;
        \?)
            _error "Invalid options found: -${OPTARG}."
            _error "${USAGE_HELP}" 2>&1
            exit 1
        ;;
    esac
done
shift $((OPTIND - 1))

# Check for programs
if ! [ -x "$(command -v az)" ]; then
    _error "az is not installed!"
    exit 1
elif ! [ -x "$(command -v jq)" ]; then
    _error "jq is not installed!"
    exit 1
fi

_parse_azuresp_json() {
    _azuresp_json=$(cat azuresp.json)
    export ARM_CLIENT_ID=$(echo "${_azuresp_json}" | jq -r ".clientId")
    export ARM_CLIENT_SECRET=$(echo "${_azuresp_json}" | jq -r ".clientSecret")
    export ARM_SUBSCRIPTION_ID=$(echo "${_azuresp_json}" | jq -r ".subscriptionId")
    export ARM_TENANT_ID=$(echo "${_azuresp_json}" | jq -r ".tenantId")
}

_azure_login() {
    _parse_azuresp_json
    az login --service-principal --username "${ARM_CLIENT_ID}" --password "${ARM_CLIENT_SECRET}" --tenant "${ARM_TENANT_ID}"
    az account set --subscription "${ARM_SUBSCRIPTION_ID}"
}

_azure_logout() {
    az logout
    az cache purge
    az account clear
}

deploy_bicep(){
    _azure_login
    az account set --subscription "${ARM_SUBSCRIPTION_ID}"
    
    if [ ${#RESOURCES_PREFIX} -gt 0 ]; then
        echo "If RESOURCES_PREFIX is set, then UNIQUER is ignored."
        az deployment sub what-if --location "${LOCATION}" resources_prefix=${RESOURCES_PREFIX} --template-file main.bicep
        az deployment sub create --location "${LOCATION}" resources_prefix=${RESOURCES_PREFIX} --template-file main.bicep
    elif [ ${#RESOURCES_PREFIX} -eq 0 && ${#UNIQUER} -gt 0 ]; then
        az deployment sub what-if --location "${LOCATION}" uniquer=${UNIQUER} --template-file main.bicep
        az deployment sub create --location "${LOCATION}" uniquer=${UNIQUER} --template-file main.bicep
    else
        az deployment sub what-if --location "${LOCATION}" --template-file main.bicep
        az deployment sub create --location "${LOCATION}" --template-file main.bicep
    fi
    
    _azure_logout
}

deploy_bicep