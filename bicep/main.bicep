targetScope = 'subscription'

param uniquer string = 'devopsoh1999'
param location string = deployment().location

var resourceGroupName = '${uniquer}rg'

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
    uniquer: uniquer
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    openhackResourceGroup
  ]
}

module sqlServer './sqlServer.bicep' = {
  name: 'sqlServerDeployment'
  params: {
    uniquer: uniquer
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    openhackResourceGroup
  ]
}

module appService './appService.bicep' = {
  name: 'appServiceDeployment'
  params: {
    uniquer: uniquer
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
//     uniquer: uniquer
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
