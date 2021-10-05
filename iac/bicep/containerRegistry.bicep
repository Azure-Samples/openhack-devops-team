param resourcesPrefix string

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
output containerRegistryName string = containerRegistry.name
