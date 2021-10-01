param uniquer string

param sqlServerAdminLogin string
@secure()
param sqlServerAdminPassword string
param sqlServerFqdn string
param sqlDatabaseName string
param containerRegistryLoginServer string
param containerRegistryAdminUsername string
@secure()
param containerRegistryAdminPassword string

var location = resourceGroup().location
var varfile = json(loadTextContent('./variables.json'))
var resourcesPrefix = '${varfile.namePrefix}${uniquer}'

// https://docs.microsoft.com/en-us/azure/templates/microsoft.web/serverfarms?tabs=bicep
resource appServicePlan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: '${resourcesPrefix}plan'
  kind: 'linux'
  location: location
  properties: {
    reserved: true
  }
  sku: {
    name: 'S1'
    tier: 'Standard'
  }
}

// https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites?tabs=bicep
resource appServiceTripviewer 'Microsoft.Web/sites@2020-12-01' = {
  name: '${resourcesPrefix}tripviewer'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'DOCKER|todo.azurecr.io/devopsoh/tripviewer:latest'
      appSettings: [
        {
          name: 'BING_MAPS_KEY'
          value: varfile.bingMapsKey
        }
        {
          name: 'USER_ROOT_URL'
          value: 'https://${appServiceApiUserprofile.properties.defaultHostName}'
        }
        {
          name: 'USER_JAVA_ROOT_URL'
          value: 'https://${appServiceApiUserjava.properties.defaultHostName}'
        }
        {
          name: 'TRIPS_ROOT_URL'
          value: 'https://${appServiceApiTrips.properties.defaultHostName}'
        }
        {
          name: 'POI_ROOT_URL'
          value: 'https://${appServiceApiPoi.properties.defaultHostName}'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${containerRegistryLoginServer}'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: containerRegistryAdminUsername
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: containerRegistryAdminPassword
        }
      ]
      alwaysOn: true
    }
    httpsOnly: true
  }
}

resource appServiceApiPoi 'Microsoft.Web/sites@2020-12-01' = {
  name: '${resourcesPrefix}poi'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistryLoginServer}/devopsoh/api-poi:${varfile.baseImageTag}'
      appSettings: [
        {
          name: 'WEBSITES_PORT'
          value: '8080'
        }
        {
          name: 'SQL_USER'
          value: sqlServerAdminLogin
        }
        {
          name: 'SQL_PASSWORD'
          value: sqlServerAdminPassword
        }
        {
          name: 'SQL_SERVER'
          value: sqlServerFqdn
        }
        {
          name: 'SQL_DBNAME'
          value: sqlDatabaseName
        }
      ]
      alwaysOn: true
    }
    httpsOnly: true
  }
}

resource appServiceApiTrips 'Microsoft.Web/sites@2020-12-01' = {
  name: '${resourcesPrefix}trips'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistryLoginServer}/devopsoh/api-trips:${varfile.baseImageTag}'
      appSettings: [
        {
          name: 'SQL_USER'
          value: sqlServerAdminLogin
        }
        {
          name: 'SQL_PASSWORD'
          value: sqlServerAdminPassword
        }
        {
          name: 'SQL_SERVER'
          value: sqlServerFqdn
        }
        {
          name: 'SQL_DBNAME'
          value: sqlDatabaseName
        }
      ]
      alwaysOn: true
    }
    httpsOnly: true
  }
}

resource appServiceApiUserjava 'Microsoft.Web/sites@2020-12-01' = {
  name: '${resourcesPrefix}userjava'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistryLoginServer}/devopsoh/api-user-java:${varfile.baseImageTag}'
      appSettings: [
        {
          name: 'SQL_USER'
          value: sqlServerAdminLogin
        }
        {
          name: 'SQL_PASSWORD'
          value: sqlServerAdminPassword
        }
        {
          name: 'SQL_SERVER'
          value: sqlServerFqdn
        }
        {
          name: 'SQL_DBNAME'
          value: sqlDatabaseName
        }
      ]
      alwaysOn: true
    }
    httpsOnly: true
  }
}

resource appServiceApiUserprofile 'Microsoft.Web/sites@2020-12-01' = {
  name: '${resourcesPrefix}userprofile'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistryLoginServer}/devopsoh/api-userprofile:${varfile.baseImageTag}'
      appSettings: [
        {
          name: 'SQL_USER'
          value: sqlServerAdminLogin
        }
        {
          name: 'SQL_PASSWORD'
          value: sqlServerAdminPassword
        }
        {
          name: 'SQL_SERVER'
          value: sqlServerFqdn
        }
        {
          name: 'SQL_DBNAME'
          value: sqlDatabaseName
        }
      ]
      alwaysOn: true
    }
    httpsOnly: true
  }
}

output appServiceApiPoiHostname string = appServiceApiPoi.properties.defaultHostName
output appServiceApiTripsHostname string = appServiceApiTrips.properties.defaultHostName
output appServiceApiUserjavaHostname string = appServiceApiUserjava.properties.defaultHostName
output appServiceApiUserprofileHostname string = appServiceApiUserprofile.properties.defaultHostName
