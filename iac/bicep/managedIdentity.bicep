param resourcesPrefix string

var location = resourceGroup().location

// https://docs.microsoft.com/en-us/azure/templates/microsoft.managedidentity/userassignedidentities?tabs=bicep
resource userAssignedManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: '${resourcesPrefix}uami'
  location: location
}

output userAssignedManagedIdentityId string = userAssignedManagedIdentity.id
output userAssignedManagedIdentityPrincipalId string = userAssignedManagedIdentity.properties.principalId
