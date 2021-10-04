param resourcesPrefix string
param userAssignedManagedIdentityPrincipalId string

var location = resourceGroup().location

// https://docs.microsoft.com/en-us/azure/templates/microsoft.containerregistry/registries?tabs=bicep
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
  name: '${resourcesPrefix}cr'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    adminUserEnabled: true
    anonymousPullEnabled: false
  }
}

output containerRegistryLoginServer string = containerRegistry.properties.loginServer
output containerRegistryAdminUsername string = containerRegistry.listCredentials().username
output containerRegistryAdminPassword string = containerRegistry.listCredentials().passwords[0].value

// https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
// Contributor
var contributorRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')

// https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?tabs=bicep
resource acrContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid(containerRegistry.id, contributorRoleDefinitionId)
  scope: containerRegistry
  properties: {
    roleDefinitionId: contributorRoleDefinitionId
    principalId: userAssignedManagedIdentityPrincipalId
  }
  dependsOn: [
    containerRegistry
  ]
}
