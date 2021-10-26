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
elif ! [ -x "$(command -v terraform)" ]; then
    _error "terraform is not installed!"
    exit 1
fi

if [ -f "devvars.sh" ]; then
    . devvars.sh
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

lint_terraform(){
    terraform fmt -check
    if [ $? -ne 0 ]; then
        _error "Terraform files are not properly formatted!"
        exit 1
    fi
}

init_terrafrom() {
    terraform init -backend-config=storage_account_name="${TFSTATE_STORAGE_ACCOUNT_NAME}" -backend-config=container_name="${TFSTATE_STORAGE_CONTAINER_NAME}" -backend-config=key="${TFSTATE_KEY}" -backend-config=resource_group_name="${TFSTATE_RESOURCES_GROUP_NAME}"
}

init_terrafrom_local() {
    terraform init -backend=false
}

validate_terraform(){
    terraform validate
}

preview_terraform(){
    if [ ${#RESOURCES_PREFIX} -gt 0 ]; then
        terraform plan --detailed-exitcode -var="location=${LOCATION}" -var="resources_prefix=${RESOURCES_PREFIX}"
    elif [[ ${#RESOURCES_PREFIX} -eq 0 && ${#UNIQUER} -gt 0 ]]; then
        terraform plan --detailed-exitcode -var="location=${LOCATION}" -var="uniquer=${UNIQUER}"
    else
        terraform plan --detailed-exitcode -var="location=${LOCATION}"
    fi

    return $?
}

deploy_terraform(){
    local _tfplan_exit_code=${1}

    if [ "${_tfplan_exit_code}" -eq 2 ]; then
        if [ ${#RESOURCES_PREFIX} -gt 0 ]; then
            terraform apply --auto-approve -var="location=${LOCATION}" -var="resources_prefix=${RESOURCES_PREFIX}"
        elif [[ ${#RESOURCES_PREFIX} -eq 0 && ${#UNIQUER} -gt 0 ]]; then
            terraform apply --auto-approve -var="location=${LOCATION}" -var="uniquer=${UNIQUER}"
        else
            terraform apply --auto-approve -var="location=${LOCATION}"
        fi
    fi
    # rm -rf .terraform && rm -rf .terraform.lock.hcl && rm -rf terraform.tfstate && rm -rf terraform.tfstate.backup
}

destroy_terraform(){
    if [ ${#RESOURCES_PREFIX} -gt 0 ]; then
        terraform destroy --auto-approve -var="location=${LOCATION}" -var="resources_prefix=${RESOURCES_PREFIX}"
    elif [[ ${#RESOURCES_PREFIX} -eq 0 && ${#UNIQUER} -gt 0 ]]; then
        terraform destroy --auto-approve -var="location=${LOCATION}" -var="uniquer=${UNIQUER}"
    else
        terraform destroy --auto-approve -var="location=${LOCATION}"
    fi
}

test_deploy(){
    local _hostnames="${1}"
    
    sleep 30
    pwsh -Command ./smokeTest.ps1 -HostNames "${_hostnames}"
}

azure_login

lint_terraform
init_terrafrom
# init_terrafrom_local
validate_terraform
preview_terraform
deploy_terraform $?
# destroy_terraform
# deployment_output=$(terraform output -json)
# hostnames=$(echo "${deployment_output}" | jq -r -c 'map(.value) | join(",")')
# test_deploy "${hostnames}"
