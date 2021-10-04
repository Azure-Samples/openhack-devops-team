param resourcesPrefix string
param sqlServerFqdn string
param sqlServerName string
param containerRegistryLoginServer string
param userAssignedManagedIdentityId string

var location = resourceGroup().location
var varfile = json(loadTextContent('./variables.json'))

// https://docs.microsoft.com/en-us/azure/templates/microsoft.resources/deploymentscripts?tabs=bicep
resource dataInit 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: '${resourcesPrefix}dataInit'
  location: location
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedManagedIdentityId}': {}
    }
  }
  properties: {
    azCliVersion: '2.28.0'
    cleanupPreference: 'OnSuccess'
    containerSettings: {
      containerGroupName: '${resourcesPrefix}datainit'
    }
    scriptContent: '''
      cd ~/

      ACCEPT_EULA=Y
      MSSQL_VERSION="17.8.1.1-1"
      set -x \
        && tempDir="$(mktemp -d)" \
        && chown nobody:nobody $tempDir \
        && cd $tempDir \
        && wget "https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/msodbcsql17_${MSSQL_VERSION}_amd64.apk" \
        && wget "https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/mssql-tools_${MSSQL_VERSION}_amd64.apk" \
        && apk add --allow-untrusted msodbcsql17_${MSSQL_VERSION}_amd64.apk \
        && apk add --allow-untrusted mssql-tools_${MSSQL_VERSION}_amd64.apk \
        && apk update \
        && apk add bind-tools \
        && rm -rf $tempDir \
        && rm -rf /var/cache/apk/*
      export PATH="$PATH:/opt/mssql-tools/bin"

      cd ~/
      
      MYIP="$(dig +short myip.opendns.com @resolver1.opendns.com -4)"
      az sql server firewall-rule create --resource-group ${RESOURCE_GROUP} --server ${SQL_SERVER_NAME} --name dataInit --start-ip-address ${MYIP} --end-ip-address ${MYIP} > "${AZ_SCRIPTS_PATH_OUTPUT_DIRECTORY}/sqlFwCreate.txt"

      git clone "${TEAM_REPO}" --branch "${TEAM_REPO_BRANCH}"
      cd openhack-devops-team/support/datainit

      sqlcmd -U ${SQL_ADMIN_LOGIN} -P ${SQL_ADMIN_PASSWORD} -S ${SQL_SERVER_FQDN} -d ${SQL_DB_NAME} -i ./MYDrivingDB.sql -e > "${AZ_SCRIPTS_PATH_OUTPUT_DIRECTORY}/sqlCmd.txt"
      bash ./sql_data_init.sh -s ${SQL_SERVER_FQDN} -u ${SQL_ADMIN_LOGIN} -p ${SQL_ADMIN_PASSWORD} -d ${SQL_DB_NAME} > "${AZ_SCRIPTS_PATH_OUTPUT_DIRECTORY}/dataInit.txt"

      az sql server firewall-rule delete --resource-group ${RESOURCE_GROUP} --server ${SQL_SERVER_NAME} --name dataInit > "${AZ_SCRIPTS_PATH_OUTPUT_DIRECTORY}/sqlFwDelete.txt"
    '''
    environmentVariables: [
      {
        name: 'SQL_SERVER_NAME'
        value: sqlServerName
      }
      {
        name: 'SQL_SERVER_FQDN'
        value: sqlServerFqdn
      }
      {
        name: 'SQL_ADMIN_LOGIN'
        value: varfile.sqlServerAdminLogin
      }
      {
        name: 'SQL_ADMIN_PASSWORD'
        secureValue: varfile.sqlServerAdminPassword
      }
      {
        name: 'SQL_DB_NAME'
        value: 'mydrivingDB'
      }
      {
        name: 'RESOURCE_GROUP'
        value: resourceGroup().name
      }
      {
        name: 'TEAM_REPO'
        value: varfile.publicTeamRepo
      }
      {
        name: 'TEAM_REPO_BRANCH'
        value: varfile.publicTeamRepoBranch
      }
    ]
    retentionInterval: 'PT1H'
    timeout: 'PT15M'
  }
}

//https://docs.microsoft.com/en-us/azure/templates/microsoft.resources/deploymentscripts?tabs=bicep
resource dockerSimulator 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: '${resourcesPrefix}dockerSimulator'
  location: location
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedManagedIdentityId}': {}
    }
  }
  properties: {
    azCliVersion: '2.28.0'
    cleanupPreference: 'Always'
    containerSettings: {
      containerGroupName: '${resourcesPrefix}dockersimulator'
    }
    scriptContent: '''
      cd ~/
      git clone "${TEAM_REPO}" --branch "${TEAM_REPO_BRANCH}"
      cd openhack-devops-team/support/simulator
      az acr build --image devopsoh/simulator:latest --registry "${CONTAINER_REGISTRY}" --file Dockerfile .  > "${AZ_SCRIPTS_PATH_OUTPUT_DIRECTORY}/azacrbuild.txt"
    '''
    environmentVariables: [
      {
        name: 'CONTAINER_REGISTRY'
        value: containerRegistryLoginServer
      }
      {
        name: 'TEAM_REPO'
        value: varfile.publicTeamRepo
      }
      {
        name: 'TEAM_REPO_BRANCH'
        value: varfile.publicTeamRepoBranch
      }
    ]
    retentionInterval: 'P1D'
  }
}
