#!/bin/bash

declare UNIQUER=""
declare LOCATION=""
declare RESOURCES_PREFIX=""
declare -r USAGE_HELP="Usage: ./deploy.sh -l <LOCATION> [-u <UNIQUER> -r <RESOURCES_PREFIX>]"

declare -r BUILD_ID="${RANDOM:0:5}"

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

if [ ${#LOCATION} -eq 0 ]; then
    _error "Required LOCATION parameter is not set!"
    _error "${USAGE_HELP}" 2>&1
    exit 1
fi

# Check for programs
if ! [ -x "$(command -v az)" ]; then
    _error "az is not installed!"
    exit 1
elif ! [ -x "$(command -v jq)" ]; then
    _error "jq is not installed!"
    exit 1
elif ! [ -x "$(command -v pwsh)" ]; then
    _error "pwsh is not installed!"
    exit 1
fi

azure_login() {
    _azuresp_json=$(cat azuresp.json)
    export ARM_CLIENT_ID=$(echo "${_azuresp_json}" | jq -r ".clientId")
    export ARM_CLIENT_SECRET=$(echo "${_azuresp_json}" | jq -r ".clientSecret")
    export ARM_SUBSCRIPTION_ID=$(echo "${_azuresp_json}" | jq -r ".subscriptionId")
    export ARM_TENANT_ID=$(echo "${_azuresp_json}" | jq -r ".tenantId")
    az login --service-principal --username "${ARM_CLIENT_ID}" --password "${ARM_CLIENT_SECRET}" --tenant "${ARM_TENANT_ID}"
    az account set --subscription "${ARM_SUBSCRIPTION_ID}"
}

azure_logout() {
    az logout
    az cache purge
    az account clear
}

lint_bicep(){
    az bicep build --file main.bicep
    rm main.json
}

validate_bicep(){
    if [ ${#RESOURCES_PREFIX} -gt 0 ]; then
        az deployment sub validate --name "${RESOURCES_PREFIX}-${BUILD_ID}" --template-file main.bicep --location "${LOCATION}" --parameters resourcesPrefix="${RESOURCES_PREFIX}"
    elif [[ ${#RESOURCES_PREFIX} -eq 0 && ${#UNIQUER} -gt 0 ]]; then
        az deployment sub validate --name "${UNIQUER}-${BUILD_ID}" --template-file main.bicep --location "${LOCATION}" --parameters uniquer="${UNIQUER}"
    else
        az deployment sub validate --name "${BUILD_ID}" --template-file main.bicep --location "${LOCATION}"
    fi
}

preview_bicep(){
    if [ ${#RESOURCES_PREFIX} -gt 0 ]; then
        az deployment sub what-if --name "${RESOURCES_PREFIX}-${BUILD_ID}" --template-file main.bicep --location "${LOCATION}" --parameters resourcesPrefix="${RESOURCES_PREFIX}"
    elif [[ ${#RESOURCES_PREFIX} -eq 0 && ${#UNIQUER} -gt 0 ]]; then
        az deployment sub what-if --name "${UNIQUER}-${BUILD_ID}" --template-file main.bicep --location "${LOCATION}" --parameters uniquer="${UNIQUER}"
    else
        az deployment sub what-if --name "${BUILD_ID}" --template-file main.bicep --location "${LOCATION}"
    fi
}

deploy_bicep(){
    if [ ${#RESOURCES_PREFIX} -gt 0 ]; then
        _deployment_output=$(az deployment sub create --name "${RESOURCES_PREFIX}-${BUILD_ID}" --template-file main.bicep --location "${LOCATION}" --parameters resourcesPrefix="${RESOURCES_PREFIX}")
    elif [[ ${#RESOURCES_PREFIX} -eq 0 && ${#UNIQUER} -gt 0 ]]; then
        _deployment_output=$(az deployment sub create --name "${UNIQUER}-${BUILD_ID}" --template-file main.bicep --location "${LOCATION}" --parameters uniquer=${UNIQUER})
    else
        _deployment_output=$(az deployment sub create --name "${BUILD_ID}" --template-file main.bicep --location "${LOCATION}")
    fi
    
    echo "${_deployment_output}"
}

test_deploy(){
    local _hostnames="${1}"
    
    sleep 30
    pwsh -Command ./smokeTest.ps1 -HostNames "${_hostnames}"
}

azure_login

lint_bicep
validate_bicep
preview_bicep
deployment_output=$(deploy_bicep)
echo "${deployment_output}"
hostnames=$(echo "${deployment_output}" | jq -r -c '.properties.outputs | map(.value) | join(",")')
test_deploy "${hostnames}"

azure_logout

echo "Build ID: ${BUILD_ID}"