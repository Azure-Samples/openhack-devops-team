#!/bin/bash

cd ~/
export ACCEPT_EULA="Y"
MSSQL_VERSION="17.8.1.1-1"

curl -O "https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/msodbcsql17_${MSSQL_VERSION}_amd64.apk"
curl -O "https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/mssql-tools_${MSSQL_VERSION}_amd64.apk"

apk add --allow-untrusted msodbcsql17_${MSSQL_VERSION}_amd64.apk
apk add --allow-untrusted mssql-tools_${MSSQL_VERSION}_amd64.apk
apk update && apk add bind-tools

export PATH="$PATH:/opt/mssql-tools/bin"

echo "MSSQL_VERSION: ${MSSQL_VERSION}" 2>&1 | tee "${AZ_SCRIPTS_PATH_OUTPUT_DIRECTORY}/vars.txt"
echo "RESOURCE_GROUP: ${RESOURCE_GROUP}" 2>&1 | tee -a "${AZ_SCRIPTS_PATH_OUTPUT_DIRECTORY}/vars.txt"
echo "TEAM_REPO: ${TEAM_REPO}" 2>&1 | tee -a "${AZ_SCRIPTS_PATH_OUTPUT_DIRECTORY}/vars.txt"
echo "TEAM_REPO_BRANCH: ${TEAM_REPO_BRANCH}" 2>&1 | tee -a "${AZ_SCRIPTS_PATH_OUTPUT_DIRECTORY}/vars.txt"
echo "SQL_SERVER_NAME: ${SQL_SERVER_NAME}" 2>&1 | tee -a "${AZ_SCRIPTS_PATH_OUTPUT_DIRECTORY}/vars.txt"
echo "SQL_ADMIN_LOGIN: ${SQL_ADMIN_LOGIN}" 2>&1 | tee -a "${AZ_SCRIPTS_PATH_OUTPUT_DIRECTORY}/vars.txt"
echo "SQL_SERVER_FQDN: ${SQL_SERVER_FQDN}" 2>&1 | tee -a "${AZ_SCRIPTS_PATH_OUTPUT_DIRECTORY}/vars.txt"
echo "SQL_DB_NAME: ${SQL_DB_NAME}" 2>&1 | tee -a "${AZ_SCRIPTS_PATH_OUTPUT_DIRECTORY}/vars.txt"

MYIP="$(dig +short myip.opendns.com @resolver1.opendns.com -4)"
az sql server firewall-rule create --resource-group ${RESOURCE_GROUP} --server ${SQL_SERVER_NAME} --name dataInit --start-ip-address ${MYIP} --end-ip-address ${MYIP} 2>&1 | tee "${AZ_SCRIPTS_PATH_OUTPUT_DIRECTORY}/sqlFwCreate.txt"

git clone "${TEAM_REPO}" --branch "${TEAM_REPO_BRANCH}" ~/openhack
cd ~/openhack/support/datainit

sqlcmd -U ${SQL_ADMIN_LOGIN} -P ${SQL_ADMIN_PASSWORD} -S ${SQL_SERVER_FQDN} -d ${SQL_DB_NAME} -i ./MYDrivingDB.sql -e 2>&1 | tee "${AZ_SCRIPTS_PATH_OUTPUT_DIRECTORY}/sqlCmd.txt"
bash ./sql_data_init.sh -s ${SQL_SERVER_FQDN} -u ${SQL_ADMIN_LOGIN} -p ${SQL_ADMIN_PASSWORD} -d ${SQL_DB_NAME} 2>&1 | tee "${AZ_SCRIPTS_PATH_OUTPUT_DIRECTORY}/dataInit.txt"

az sql server firewall-rule delete --resource-group ${RESOURCE_GROUP} --server ${SQL_SERVER_NAME} --name dataInit 2>&1 | tee "${AZ_SCRIPTS_PATH_OUTPUT_DIRECTORY}/sqlFwDelete.txt"