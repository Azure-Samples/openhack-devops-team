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

module managedIdentity './managedIdentity.bicep' = {
  name: 'managedIdentityDeployment'
  params: {
    resourcesPrefix: resourcesPrefixCalculated
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    openhackResourceGroup
  ]
}

module containerRegistry './containerRegistry.bicep' = {
  name: 'containerRegistryDeployment'
  params: {
    resourcesPrefix: resourcesPrefixCalculated
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    openhackResourceGroup
    managedIdentity
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
    managedIdentity
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
    containerRegistryName: containerRegistry.outputs.containerRegistryName
    // userAssignedManagedIdentityId: managedIdentity.outputs.userAssignedManagedIdentityId
    // userAssignedManagedIdentityPrincipalId: managedIdentity.outputs.userAssignedManagedIdentityPrincipalId
    containerRegistryAdminUsername: containerRegistry.outputs.containerRegistryAdminUsername
    containerRegistryAdminPassword: containerRegistry.outputs.containerRegistryAdminPassword
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    containerRegistry
    sqlServer
    apps
  ]
}

module apps './apps.bicep' = {
  name: 'appsDeployment'
  params: {
    resourcesPrefix: resourcesPrefixCalculated
    sqlServerFqdn: sqlServer.outputs.sqlServerFqdn
    sqlServerName: sqlServer.outputs.sqlServerName
    containerRegistryLoginServer: containerRegistry.outputs.containerRegistryLoginServer
    containerRegistryName: containerRegistry.outputs.containerRegistryName
    userAssignedManagedIdentityId: managedIdentity.outputs.userAssignedManagedIdentityId
    userAssignedManagedIdentityPrincipalId: managedIdentity.outputs.userAssignedManagedIdentityPrincipalId
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    sqlServer
    containerRegistry
    managedIdentity
  ]
}

module containerGroup './containerGroup.bicep' = {
  name: 'containerGroupDeployment'
  params: {
    resourcesPrefix: resourcesPrefixCalculated
    sqlServerFqdn: sqlServer.outputs.sqlServerFqdn
    sqlServerAdminLogin: sqlServer.outputs.sqlServerAdminLogin
    sqlServerAdminPassword: sqlServer.outputs.sqlServerAdminPassword
    sqlDatabaseName: sqlServer.outputs.sqlDatabaseName
    containerRegistryLoginServer: containerRegistry.outputs.containerRegistryLoginServer
    // containerRegistryName: containerRegistry.outputs.containerRegistryName
    containerRegistryAdminUsername: containerRegistry.outputs.containerRegistryAdminUsername
    containerRegistryAdminPassword: containerRegistry.outputs.containerRegistryAdminPassword
    appServiceApiPoiHostname: appService.outputs.appServiceApiPoiHostname
    appServiceApiTripsHostname: appService.outputs.appServiceApiTripsHostname
    appServiceApiUserjavaHostname: appService.outputs.appServiceApiUserjavaHostname
    appServiceApiUserprofileHostname: appService.outputs.appServiceApiUserprofileHostname
    // userAssignedManagedIdentityId: managedIdentity.outputs.userAssignedManagedIdentityId
    // userAssignedManagedIdentityPrincipalId: managedIdentity.outputs.userAssignedManagedIdentityPrincipalId
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    containerRegistry
    sqlServer
    appService
    apps
  ]
}

output appServiceApiPoiHostname string = appService.outputs.appServiceApiPoiHostname
output appServiceApiTripsHostname string = appService.outputs.appServiceApiTripsHostname
output appServiceApiUserjavaHostname string = appService.outputs.appServiceApiUserjavaHostname
output appServiceApiUserprofileHostname string = appService.outputs.appServiceApiUserprofileHostname
