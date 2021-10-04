param resourcesPrefix string
param sqlServerAdminLogin string
@secure()
param sqlServerAdminPassword string
param sqlServerFqdn string
param sqlDatabaseName string
// param containerRegistryLoginServer string
// param containerRegistryAdminUsername string
// @secure()
// param containerRegistryAdminPassword string

var location = resourceGroup().location
var varfile = json(loadTextContent('./variables.json'))

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
      // linuxFxVersion: 'DOCKER|${containerRegistryLoginServer}/devopsoh/tripviewer:latest'
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
        // {
        //   name: 'DOCKER_REGISTRY_SERVER_URL'
        //   value: 'https://${containerRegistryLoginServer}'
        // }
        // {
        //   name: 'DOCKER_REGISTRY_SERVER_USERNAME'
        //   value: containerRegistryAdminUsername
        // }
        // {
        //   name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
        //   value: containerRegistryAdminPassword
        // }
      ]
      alwaysOn: true
    }
    httpsOnly: true
  }
}

// https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites?tabs=bicep
resource appServiceApiPoi 'Microsoft.Web/sites@2020-12-01' = {
  name: '${resourcesPrefix}poi'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      // linuxFxVersion: 'DOCKER|${containerRegistryLoginServer}/devopsoh/api-poi:${varfile.baseImageTag}'
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
        // {
        //   name: 'WEBSITES_PORT'
        //   value: '8080'
        // }
        // {
        //   name: 'DOCKER_REGISTRY_SERVER_URL'
        //   value: 'https://${containerRegistryLoginServer}'
        // }
        // {
        //   name: 'DOCKER_REGISTRY_SERVER_USERNAME'
        //   value: containerRegistryAdminUsername
        // }
        // {
        //   name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
        //   value: containerRegistryAdminPassword
        // }
      ]
      alwaysOn: true
    }
    httpsOnly: true
  }
}

// https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites/slots?tabs=bicep
resource appServiceApiPoiStaging 'Microsoft.Web/sites/slots@2020-12-01' = {
  parent: appServiceApiPoi
  name: 'staging'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    cloningInfo: {
      sourceWebAppId: appServiceApiPoi.id
    }	
  }
}

// https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites?tabs=bicep
resource appServiceApiTrips 'Microsoft.Web/sites@2020-12-01' = {
  name: '${resourcesPrefix}trips'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      // linuxFxVersion: 'DOCKER|${containerRegistryLoginServer}/devopsoh/api-trips:${varfile.baseImageTag}'
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
        // {
        //   name: 'DOCKER_REGISTRY_SERVER_URL'
        //   value: 'https://${containerRegistryLoginServer}'
        // }
        // {
        //   name: 'DOCKER_REGISTRY_SERVER_USERNAME'
        //   value: containerRegistryAdminUsername
        // }
        // {
        //   name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
        //   value: containerRegistryAdminPassword
        // }
      ]
      alwaysOn: true
    }
    httpsOnly: true
  }
}

// https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites/slots?tabs=bicep
resource appServiceApiTripsStaging 'Microsoft.Web/sites/slots@2020-12-01' = {
  parent: appServiceApiTrips
  name: 'staging'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    cloningInfo: {
      sourceWebAppId: appServiceApiTrips.id
    }	
  }
}

// https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites?tabs=bicep
resource appServiceApiUserjava 'Microsoft.Web/sites@2020-12-01' = {
  name: '${resourcesPrefix}userjava'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      // linuxFxVersion: 'DOCKER|${containerRegistryLoginServer}/devopsoh/api-user-java:${varfile.baseImageTag}'
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
        // {
        //   name: 'DOCKER_REGISTRY_SERVER_URL'
        //   value: 'https://${containerRegistryLoginServer}'
        // }
        // {
        //   name: 'DOCKER_REGISTRY_SERVER_USERNAME'
        //   value: containerRegistryAdminUsername
        // }
        // {
        //   name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
        //   value: containerRegistryAdminPassword
        // }
      ]
      alwaysOn: true
    }
    httpsOnly: true
  }
}

// https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites/slots?tabs=bicep
resource appServiceApiUserjavaStaging 'Microsoft.Web/sites/slots@2020-12-01' = {
  parent: appServiceApiUserjava
  name: 'staging'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    cloningInfo: {
      sourceWebAppId: appServiceApiUserjava.id
    }	
  }
}

// https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites?tabs=bicep
resource appServiceApiUserprofile 'Microsoft.Web/sites@2020-12-01' = {
  name: '${resourcesPrefix}userprofile'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      // linuxFxVersion: 'DOCKER|${containerRegistryLoginServer}/devopsoh/api-userprofile:${varfile.baseImageTag}'
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
        // {
        //   name: 'DOCKER_REGISTRY_SERVER_URL'
        //   value: 'https://${containerRegistryLoginServer}'
        // }
        // {
        //   name: 'DOCKER_REGISTRY_SERVER_USERNAME'
        //   value: containerRegistryAdminUsername
        // }
        // {
        //   name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
        //   value: containerRegistryAdminPassword
        // }
      ]
      alwaysOn: true
    }
    httpsOnly: true
  }
}

// https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites/slots?tabs=bicep
resource appServiceApiUserprofileStaging 'Microsoft.Web/sites/slots@2020-12-01' = {
  parent: appServiceApiUserprofile
  name: 'staging'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    cloningInfo: {
      sourceWebAppId: appServiceApiUserprofile.id
    }	
  }
}

output appServiceTripviewerHostname string = appServiceTripviewer.properties.defaultHostName
output appServiceApiPoiHostname string = appServiceApiPoi.properties.defaultHostName
output appServiceApiTripsHostname string = appServiceApiTrips.properties.defaultHostName
output appServiceApiUserjavaHostname string = appServiceApiUserjava.properties.defaultHostName
output appServiceApiUserprofileHostname string = appServiceApiUserprofile.properties.defaultHostName
