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
if ! [ -x "$(command -v terraform)" ]; then
    _error "terraform is not installed!"
    exit 1
elif ! [ -x "$(command -v jq)" ]; then
    _error "jq is not installed!"
    exit 1
fi

_azure_login_for_terraform() {
    _azuresp_json=$(cat azuresp.json)
    export ARM_CLIENT_ID=$(echo "${_azuresp_json}" | jq -r ".clientId")
    export ARM_CLIENT_SECRET=$(echo "${_azuresp_json}" | jq -r ".clientSecret")
    export ARM_SUBSCRIPTION_ID=$(echo "${_azuresp_json}" | jq -r ".subscriptionId")
    export ARM_TENANT_ID=$(echo "${_azuresp_json}" | jq -r ".tenantId")
}

lint_terraform(){
    terraform fmt
    terraform init
    terraform validate
}

deploy_terraform(){
    _azure_login_for_terraform
    terraform init
    if [ ${#RESOURCES_PREFIX} -gt 0 ]; then
        echo "If RESOURCES_PREFIX is set, then UNIQUER is ignored."
        terraform plan --detailed-exitcode -var="location=${LOCATION}" -var="resources_prefix=${RESOURCES_PREFIX}"
        if [ $? -eq 2 ]; then
            terraform apply --auto-approve -var="location=${LOCATION}" -var="resources_prefix=${RESOURCES_PREFIX}"
        fi
    elif [ ${#RESOURCES_PREFIX} -eq 0 && ${#UNIQUER} -gt 0 ]; then
        terraform plan --detailed-exitcode -var="location=${LOCATION}" -var="uniquer=${UNIQUER}"
        if [ $? -eq 2 ]; then
            terraform apply --auto-approve -var="location=${LOCATION}" -var="uniquer=${UNIQUER}"
        fi
    else
        terraform plan --detailed-exitcode -var="location=${LOCATION}"
        if [ $? -eq 2 ]; then
            terraform apply --auto-approve -var="location=${LOCATION}"
        fi
    fi
    rm -rf openhack-devops-proctor
    # rm -rf .terraform && rm -rf .terraform.lock.hcl && rm -rf terraform.tfstate && rm -rf terraform.tfstate.backup
}

lint_terraform
# deploy_terraform