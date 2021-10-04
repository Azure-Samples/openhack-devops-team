param resourcesPrefix string
param userAssignedManagedIdentityPrincipalId string

var location = resourceGroup().location
var varfile = json(loadTextContent('./variables.json'))

// https://docs.microsoft.com/en-us/azure/templates/microsoft.sql/servers?tabs=bicep
resource sqlServer 'Microsoft.Sql/servers@2021-02-01-preview' = {
  name: '${resourcesPrefix}sql'
  location: location
  properties: {
    administratorLogin: varfile.sqlServerAdminLogin
    administratorLoginPassword: varfile.sqlServerAdminPassword
    minimalTlsVersion: '1.2'
    version: '12.0'
  }
}

resource sqlFirewallRuleAzure 'Microsoft.Sql/servers/firewallRules@2021-02-01-preview' = {
  parent: sqlServer
  name: 'AzureAccess'
  properties: {
    endIpAddress: '0.0.0.0'
    startIpAddress: '0.0.0.0'
  }
}

// https://docs.microsoft.com/en-us/azure/templates/microsoft.sql/servers/databases?tabs=bicep
resource sqlDatabase 'Microsoft.Sql/servers/databases@2021-02-01-preview' = {
  parent: sqlServer
  name: 'mydrivingDB'
  location: location
  sku: {
    name: 'S0'
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
  }
}

// https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
// Contributor
var contributorRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')

// https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?tabs=bicep
resource sqlContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid(sqlServer.id, contributorRoleDefinitionId)
  scope: sqlServer
  properties: {
    roleDefinitionId: contributorRoleDefinitionId
    principalId: userAssignedManagedIdentityPrincipalId
  }
  dependsOn: [
    sqlServer
  ]
}

output sqlServerAdminLogin string = varfile.sqlServerAdminLogin
output sqlServerAdminPassword string = varfile.sqlServerAdminPassword
output sqlServerFqdn string = sqlServer.properties.fullyQualifiedDomainName
output sqlDatabaseName string = sqlDatabase.name
output sqlServerName string = sqlServer.name
