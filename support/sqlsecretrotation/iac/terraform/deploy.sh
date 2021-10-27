#!/bin/bash

declare LOCATION=$1
declare RESOURCES_PREFIX=$2
declare SECRET_NAME=$3
declare KEY_VAULT_RESOURCE_GROUP_NAME=$4
declare KEY_VAULT_NAME=$5

declare -r USAGE_HELP="Usage: ./deploy.sh <LOCATION> <RESOURCES_PREFIX> <SECRET_NAME> <KEY_VAULT_RESOURCE_GROUP_NAME> <KEY_VAULT_NAME>"

if [ $# -ne 5 ]; then
    echo "${USAGE_HELP}"
    exit 1
fi

# Check for programs
if ! [ -x "$(command -v az)" ]; then
    echo "az is not installed!"
    exit 1
    elif ! [ -x "$(command -v terraform)" ]; then
    echo "terraform is not installed!"
    exit 1
fi

if [ -f "devvars.sh" ]; then
    . devvars.sh
fi

export ARM_THREEPOINTZERO_BETA_RESOURCES=true

azure_login() {
    _azuresp_json=$(cat azuresp.json)
    export ARM_CLIENT_ID=$(echo "${_azuresp_json}" | jq -r ".clientId")
    export ARM_CLIENT_SECRET=$(echo "${_azuresp_json}" | jq -r ".clientSecret")
    export ARM_SUBSCRIPTION_ID=$(echo "${_azuresp_json}" | jq -r ".subscriptionId")
    export ARM_TENANT_ID=$(echo "${_azuresp_json}" | jq -r ".tenantId")
    az login --service-principal --username "${ARM_CLIENT_ID}" --password "${ARM_CLIENT_SECRET}" --tenant "${ARM_TENANT_ID}"
    az account set --subscription "${ARM_SUBSCRIPTION_ID}"
}

prepare_tfvars() {
    echo "Generating tfvars..."
    echo 'location = "'${LOCATION}'"' > terraform.tfvars
    echo 'resources_prefix = "'${RESOURCES_PREFIX}'"' >> terraform.tfvars
    echo 'secret_name = "'${SECRET_NAME}'"' >> terraform.tfvars
    echo 'key_vault_resource_group_name = "'${KEY_VAULT_RESOURCE_GROUP_NAME}'"' >> terraform.tfvars
    echo 'key_vault_name = "'${KEY_VAULT_NAME}'"' >> terraform.tfvars
    terraform fmt
}

lint_terraform(){
    terraform fmt -check
    if [ $? -ne 0 ]; then
        echo "Terraform files are not properly formatted!"
        exit 1
    fi
}

init_terrafrom() {
    terraform init -backend-config=storage_account_name="${TFSTATE_STORAGE_ACCOUNT_NAME}" -backend-config=container_name="${TFSTATE_STORAGE_CONTAINER_NAME}" -backend-config=key="${TFSTATE_KEY_SECROT}" -backend-config=resource_group_name="${TFSTATE_RESOURCES_GROUP_NAME}"
}

init_terrafrom_local() {
    terraform init -backend=false
}

validate_terraform(){
    terraform validate
}

preview_terraform(){
    terraform plan --detailed-exitcode
    return $?
}

deploy_terraform(){
    local _tfplan_exit_code=${1}

    terraform apply --auto-approve
}

destroy_terraform(){
    terraform destroy --auto-approve
}

prepare_tfvars
azure_login
lint_terraform
init_terrafrom
# init_terrafrom_local
validate_terraform
preview_terraform
deploy_terraform $?
# destroy_terraform
