param uniquer string

var location = resourceGroup().location

var varfile = json(loadTextContent('./variables.json'))

// https://docs.microsoft.com/en-us/azure/templates/microsoft.sql/servers?tabs=bicep
resource sqlServer 'Microsoft.Sql/servers@2021-02-01-preview' = {
  name: '${uniquer}sql'
  location: location
  properties: {
    administratorLogin: varfile.sqlServerAdminLogin
    administratorLoginPassword: varfile.sqlServerAdminPassword
    minimalTlsVersion: '1.2'
    version: '12.0'
  }
}

resource sqlFirewallRuleAzure 'Microsoft.Sql/servers/firewallRules@2021-02-01-preview' = {
  parent: sqlServer.name
  name: 'AzureAccess'
  properties: {
    endIpAddress: '0.0.0.0'
    startIpAddress: '0.0.0.0'
  }
}

// https://docs.microsoft.com/en-us/azure/templates/microsoft.sql/servers/databases?tabs=bicep
resource sqlDatabase 'Microsoft.Sql/servers/databases@2021-02-01-preview' = {
  parent: sqlServer.name
  name: 'mydrivingDB'
  location: location
  sku: {
    name: 'S0'
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
  }
}

output sqlServerAdminLogin string = varfile.sqlServerAdminLogin
output sqlServerAdminPassword string = varfile.sqlServerAdminPassword
output sqlServerFqdn string = sqlServer.properties.fullyQualifiedDomainName
output sqlDatabaseName string = sqlDatabase.name

// https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
// Contributor
var contributorRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')

// https://docs.microsoft.com/en-us/azure/templates/microsoft.managedidentity/userassignedidentities?tabs=bicep
resource userAssignedManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: '${uniquer}sqluami'
  location: location
}

// https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?tabs=bicep
resource sqlContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid(resourceGroup().id, contributorRoleDefinitionId)
  properties: {
    roleDefinitionId: contributorRoleDefinitionId
    principalId: userAssignedManagedIdentity.properties.principalId
  }
  scope: sqlServer
  dependsOn: [
    userAssignedManagedIdentity
    sqlServer
  ]
}

// https://docs.microsoft.com/en-us/azure/templates/microsoft.resources/deploymentscripts?tabs=bicep
resource dataInit 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: '${uniquer}dataInit'
  location: location
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedManagedIdentity.id}': {}
    }
  }
  properties: {
    azCliVersion: '2.28.0'
    cleanupPreference: 'OnSuccess'
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

      git clone https://github.com/Azure-Samples/openhack-devops-proctor --branch main
      cd openhack-devops-proctor/provision-team

      sqlcmd -U ${SQL_ADMIN_LOGIN} -P ${SQL_ADMIN_PASSWORD} -S ${SQL_SERVER_FQDN} -d ${SQL_DB_NAME} -i ./MYDrivingDB.sql -e > "${AZ_SCRIPTS_PATH_OUTPUT_DIRECTORY}/sqlCmd.txt"
      bash ./sql_data_init.sh -s ${SQL_SERVER_FQDN} -u ${SQL_ADMIN_LOGIN} -p ${SQL_ADMIN_PASSWORD} -d ${SQL_DB_NAME} > "${AZ_SCRIPTS_PATH_OUTPUT_DIRECTORY}/dataInit.txt"

      az sql server firewall-rule delete --resource-group ${RESOURCE_GROUP} --server ${SQL_SERVER_NAME} --name dataInit > "${AZ_SCRIPTS_PATH_OUTPUT_DIRECTORY}/sqlFwDelete.txt"
    '''
    environmentVariables: [
      {
        name: 'SQL_ADMIN_LOGIN'
        value: varfile.sqlServerAdminLogin
      }
      {
        name: 'SQL_ADMIN_PASSWORD'
        secureValue: varfile.sqlServerAdminPassword
      }
      {
        name: 'SQL_SERVER_FQDN'
        value: sqlServer.properties.fullyQualifiedDomainName
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
        name: 'SQL_SERVER_NAME'
        value: sqlServer.name
      }
    ]
    retentionInterval: 'PT1H'
  }
  dependsOn: [
    sqlContributorRoleAssignment
    sqlDatabase
  ]
}
