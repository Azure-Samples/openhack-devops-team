param resourcesPrefix string
param sqlServerAdminLogin string
@secure()
param sqlServerAdminPassword string
param sqlServerFqdn string
param sqlDatabaseName string
param containerRegistryLoginServer string
param containerRegistryAdminUsername string
@secure()
param containerRegistryAdminPassword string
param appServiceApiPoiHostname string
param appServiceApiTripsHostname string
param appServiceApiUserjavaHostname string
param appServiceApiUserprofileHostname string
// param containerRegistryName string
// param userAssignedManagedIdentityId string
// param userAssignedManagedIdentityPrincipalId string

// https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
// AcrPull
// var acrPullRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')

// resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' existing = {
//   name: containerRegistryName
// }

// https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?tabs=bicep
// resource acrPullRoleAssignmentSimulator 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
//   name: guid(resourceGroup().id, containerRegistry.id, 'simulator', acrPullRoleDefinitionId)
//   scope: containerRegistry
//   properties: {
//     roleDefinitionId: acrPullRoleDefinitionId
//     principalId: userAssignedManagedIdentityPrincipalId
//   }
// }

// https://docs.microsoft.com/en-us/azure/templates/microsoft.containerinstance/containergroups?tabs=bicep
resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2021-03-01' = {
  name: '${resourcesPrefix}simulator'
  location: resourceGroup().location
  // identity: {
  //   type: 'UserAssigned'
  //   userAssignedIdentities: {
  //     '${userAssignedManagedIdentityId}': {}
  //   }
  // }
  properties: {
    containers: [
      {
        name: 'simulator'
        properties: {
          environmentVariables: [
            {
              name: 'SQL_SERVER'
              value: sqlServerFqdn
            }
            {
              name: 'SQL_USER'
              value: sqlServerAdminLogin
            }
            {
              name: 'SQL_PASSWORD'
              secureValue: sqlServerAdminPassword
            }
            {
              name: 'SQL_DBNAME'
              value: sqlDatabaseName
            }
            {
              name: 'TEAM_NAME'
              value: resourcesPrefix
            }
            {
              name: 'USER_ROOT_URL'
              value: 'https://${appServiceApiUserprofileHostname}'
            }
            {
              name: 'USER_JAVA_ROOT_URL'
              value: 'https://${appServiceApiUserjavaHostname}'
            }
            {
              name: 'TRIPS_ROOT_URL'
              value: 'https://${appServiceApiTripsHostname}'
            }
            {
              name: 'POI_ROOT_URL'
              value: 'https://${appServiceApiPoiHostname}'
            }
          ]
          image: '${containerRegistryLoginServer}/devopsoh/simulator:latest'
          ports: [
            {
              port: 8080
              protocol: 'TCP'
            }
          ]
          resources: {
            requests: {
              cpu: 1
              memoryInGB: 2
            }
          }
        }
      }
    ]
    imageRegistryCredentials: [
      {
        password: containerRegistryAdminPassword
        server: containerRegistryLoginServer
        username: containerRegistryAdminUsername
      }
    ]
    ipAddress: {
      dnsNameLabel: '${resourcesPrefix}simulator'
      ports: [
        {
          port: 8080
          protocol: 'TCP'
        }
      ]
      type: 'Public'
    }
    osType: 'Linux'
  }
  // dependsOn: [
  //   acrPullRoleAssignmentSimulator
  // ]
}
