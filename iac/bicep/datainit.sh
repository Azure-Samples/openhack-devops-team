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

echo "MSSQL_VERSION: ${MSSQL_VERSION}"
echo "RESOURCE_GROUP: ${RESOURCE_GROUP}"
echo "SQL_SERVER_NAME: ${SQL_SERVER_NAME}"
echo "TEAM_REPO: ${TEAM_REPO}"
echo "TEAM_REPO_BRANCH: ${TEAM_REPO_BRANCH}"
echo "SQL_ADMIN_LOGIN: ${SQL_ADMIN_LOGIN}"
echo "SQL_SERVER_FQDN: ${SQL_SERVER_FQDN}"
echo "SQL_DB_NAME: ${SQL_DB_NAME}"

echo 1
MYIP="$(dig +short myip.opendns.com @resolver1.opendns.com -4)"
az sql server firewall-rule create --resource-group ${RESOURCE_GROUP} --server ${SQL_SERVER_NAME} --name dataInit --start-ip-address ${MYIP} --end-ip-address ${MYIP} > "${AZ_SCRIPTS_PATH_OUTPUT_DIRECTORY}/sqlFwCreate.txt"
echo 2
git clone "${TEAM_REPO}" --branch "${TEAM_REPO_BRANCH}" ~/openhack
echo 3
cd ~/openhack/support/datainit
echo 4
sqlcmd -U ${SQL_ADMIN_LOGIN} -P ${SQL_ADMIN_PASSWORD} -S ${SQL_SERVER_FQDN} -d ${SQL_DB_NAME} -i ./MYDrivingDB.sql -e > "${AZ_SCRIPTS_PATH_OUTPUT_DIRECTORY}/sqlCmd.txt"
echo 5
bash ./sql_data_init.sh -s ${SQL_SERVER_FQDN} -u ${SQL_ADMIN_LOGIN} -p ${SQL_ADMIN_PASSWORD} -d ${SQL_DB_NAME} > "${AZ_SCRIPTS_PATH_OUTPUT_DIRECTORY}/dataInit.txt"
echo 6
az sql server firewall-rule delete --resource-group ${RESOURCE_GROUP} --server ${SQL_SERVER_NAME} --name dataInit > "${AZ_SCRIPTS_PATH_OUTPUT_DIRECTORY}/sqlFwDelete.txt"
echo 7