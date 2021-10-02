targetScope = 'subscription'

param uniquer string = uniqueString(newGuid())
param location string = deployment().location
param resourcesPrefix string = ''

var varfile = json(loadTextContent('./variables.json'))
var resourcesPrefixCalculated = empty(resourcesPrefix) ? '${varfile.namePrefix}${uniquer}' : resourcesPrefix
var resourceGroupName = '${resourcesPrefixCalculated}rg'

module openhackResourceGroup './resourceGroup.bicep' = {
  name: 'resourceGroupDeployment'
  params: {
    resourceGroupName: resourceGroupName
    location: location
  }
}

module containerRegistry './containerRegistry.bicep' = {
  name: 'containerRegistryDeployment'
  params: {
    resourcesPrefix: resourcesPrefixCalculated
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    openhackResourceGroup
  ]
}

module sqlServer './sqlServer.bicep' = {
  name: 'sqlServerDeployment'
  params: {
    resourcesPrefix: resourcesPrefixCalculated
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    openhackResourceGroup
  ]
}

module appService './appService.bicep' = {
  name: 'appServiceDeployment'
  params: {
    resourcesPrefix: resourcesPrefixCalculated
    sqlServerFqdn: sqlServer.outputs.sqlServerFqdn
    sqlServerAdminLogin: sqlServer.outputs.sqlServerAdminLogin
    sqlServerAdminPassword: sqlServer.outputs.sqlServerAdminPassword
    sqlDatabaseName: sqlServer.outputs.sqlDatabaseName
    containerRegistryLoginServer: containerRegistry.outputs.containerRegistryLoginServer
    containerRegistryAdminUsername: containerRegistry.outputs.containerRegistryAdminUsername
    containerRegistryAdminPassword: containerRegistry.outputs.containerRegistryAdminPassword
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    containerRegistry
    sqlServer
  ]
}

// module containerGroup './containerGroup.bicep' = {
//   name: 'containerGroupDeployment'
//   params: {
//     resourcesPrefix: resourcesPrefixCalculated
//     sqlServerFqdn: sqlServer.outputs.sqlServerFqdn
//     sqlServerAdminLogin: sqlServer.outputs.sqlServerAdminLogin
//     sqlServerAdminPassword: sqlServer.outputs.sqlServerAdminPassword
//     sqlDatabaseName: sqlServer.outputs.sqlDatabaseName
//     containerRegistryLoginServer: containerRegistry.outputs.containerRegistryLoginServer
//     containerRegistryAdminUsername: containerRegistry.outputs.containerRegistryAdminUsername
//     containerRegistryAdminPassword: containerRegistry.outputs.containerRegistryAdminPassword
//     appServiceApiPoiHostname: appService.outputs.appServiceApiPoiHostname
//     appServiceApiTripsHostname: appService.outputs.appServiceApiTripsHostname
//     appServiceApiUserjavaHostname: appService.outputs.appServiceApiUserjavaHostname
//     appServiceApiUserprofileHostname: appService.outputs.appServiceApiUserprofileHostname
//   }
//   scope: resourceGroup(resourceGroupName)
//   dependsOn: [
//     containerRegistry
//     sqlServer
//     appService
//   ]
// }
