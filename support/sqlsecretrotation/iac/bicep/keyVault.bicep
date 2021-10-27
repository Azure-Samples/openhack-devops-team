param keyVaultName string
param functionAppId string
param functionAppPrincipalId string
param functionAppTenantId string
param eventSubscriptionName string
param secretName string

resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
  name: keyVaultName
}

resource keyVaultAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2021-06-01-preview' = {
  name: 'add'
  parent: keyVault
  properties: {
    accessPolicies: [
      {
        tenantId: functionAppTenantId
        objectId: functionAppPrincipalId
        permissions: {
          secrets: [
            'get'
            'list'
            'set'
          ]
        }
      }
    ]
  }
}

resource keyVaultEventSubscription 'Microsoft.EventGrid/eventSubscriptions@2021-06-01-preview' = {
  name: eventSubscriptionName
  scope: keyVault
  properties: {
    destination: {
      endpointType: 'AzureFunction'
      properties: {
        maxEventsPerBatch: 1
        preferredBatchSizeInKilobytes: 64
        resourceId: '${functionAppId}/functions/AKVSQLRotation'
      }
    }
    filter: {
      subjectBeginsWith: secretName
      subjectEndsWith: secretName
      includedEventTypes: [
        'Microsoft.KeyVault.SecretNearExpiry'
      ]
    }
    eventDeliverySchema: 'EventGridSchema'
    retryPolicy: {
      eventTimeToLiveInMinutes: 60
      maxDeliveryAttempts: 30
    }
  }
}
