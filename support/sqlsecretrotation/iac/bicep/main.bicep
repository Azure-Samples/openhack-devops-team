param keyVaultRgName string = resourceGroup().name
param keyVaultName string
param resourcesPrefix string
param resourcesSuffix string = 'sqlsecrot'
param secretName string = 'SQL-PASSWORD'
param repoUrl string = 'https://github.com/Azure-Samples/KeyVault-Rotation-SQLPassword-Csharp.git'

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: '${resourcesPrefix}${resourcesSuffix}st'
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    accessTier: 'Hot'
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: '${resourcesPrefix}${resourcesSuffix}plan'
  location: resourceGroup().location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
}

resource functionApp 'Microsoft.Web/sites@2021-02-01' = {
  name: '${resourcesPrefix}${resourcesSuffix}func'
  location: resourceGroup().location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enabled: true
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower('${resourcesPrefix}${resourcesSuffix}func')
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsights.properties.ConnectionString
        }
      ]
    }
  }
}

resource functionAppSourceControl 'Microsoft.Web/sites/sourcecontrols@2021-02-01' = {
  name: 'web'
  parent: functionApp
  properties: {
    repoUrl: repoUrl
    branch: 'main'
    isManualIntegration: true
  }
}

resource applicationInsights 'microsoft.insights/components@2020-02-02' = {
  name: '${resourcesPrefix}${resourcesSuffix}appi'
  location: resourceGroup().location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

module keyVault './keyVault.bicep' = {
  name: 'keyVaultDeployment'
  params: {
    keyVaultName: keyVaultName
    functionAppId: functionApp.id
    functionAppTenantId: functionApp.identity.tenantId
    functionAppPrincipalId: functionApp.identity.principalId
    eventSubscriptionName: '${keyVaultName}-${secretName}-${functionApp.name}'
    secretName: secretName
  }
  scope: resourceGroup(keyVaultRgName)
  dependsOn: [
    functionApp
    functionAppSourceControl
  ]
}
