param resourcesPrefix string
param sqlServerFqdn string
param sqlServerName string
param containerRegistryLoginServer string
param containerRegistryName string
param userAssignedManagedIdentityId string
param userAssignedManagedIdentityPrincipalId string
param utcValue string = utcNow()

var location = resourceGroup().location
var varfile = json(loadTextContent('./variables.json'))

// https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
// Contributor
var contributorRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')



resource sqlServer 'Microsoft.Sql/servers@2021-02-01-preview' existing = {
  name: sqlServerName
}

// https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?tabs=bicep
resource sqlContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid(resourceGroup().id, sqlServer.id, userAssignedManagedIdentityId, contributorRoleDefinitionId)
  scope: sqlServer
  properties: {
    roleDefinitionId: contributorRoleDefinitionId
    principalId: userAssignedManagedIdentityPrincipalId
  }
}

// https://docs.microsoft.com/en-us/azure/templates/microsoft.resources/deploymentscripts?tabs=bicep
resource dataInit 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: '${resourcesPrefix}dataInit'
  location: location
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedManagedIdentityId}': {}
    }
  }
  properties: {
    azCliVersion: '2.28.0'
    cleanupPreference: 'OnExpiration'
    containerSettings: {
      containerGroupName: '${resourcesPrefix}datainit'
    }
    primaryScriptUri: 'https://raw.githubusercontent.com/Azure-Samples/openhack-devops-team/bicepfixes/iac/bicep/datainit.sh'
    environmentVariables: [
      {
        name: 'SQL_SERVER_NAME'
        value: sqlServerName
      }
      {
        name: 'SQL_SERVER_FQDN'
        value: sqlServerFqdn
      }
      {
        name: 'SQL_ADMIN_LOGIN'
        value: varfile.sqlServerAdminLogin
      }
      {
        name: 'SQL_ADMIN_PASSWORD'
        secureValue: varfile.sqlServerAdminPassword
      }
      {
        name: 'SQL_DB_NAME'
        value: 'mydrivingDB'
      }
      {
        name: 'RESOURCE_GROUP'
        value: resourceGroup().name
      }
      {
        name: 'TEAM_REPO'
        value: varfile.publicTeamRepo
      }
      {
        name: 'TEAM_REPO_BRANCH'
        value: varfile.publicTeamRepoBranch
      }
    ]
    retentionInterval: 'PT1H'
    timeout: 'PT15M'
    forceUpdateTag: guid(utcValue)
  }
  dependsOn: [
    sqlContributorRoleAssignment
  ]
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' existing = {
  name: containerRegistryName
}

// https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?tabs=bicep
resource acrContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid(resourceGroup().id, containerRegistry.id, userAssignedManagedIdentityId, contributorRoleDefinitionId)
  scope: containerRegistry
  properties: {
    roleDefinitionId: contributorRoleDefinitionId
    principalId: userAssignedManagedIdentityPrincipalId
  }
}

//https://docs.microsoft.com/en-us/azure/templates/microsoft.resources/deploymentscripts?tabs=bicep
resource dockerBuild 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: '${resourcesPrefix}dockerBuild'
  location: location
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedManagedIdentityId}': {}
    }
  }
  properties: {
    azCliVersion: '2.28.0'
    cleanupPreference: 'Always'
    containerSettings: {
      containerGroupName: '${resourcesPrefix}dockerdbuild'
    }
    scriptContent: '''
      git clone "${TEAM_REPO}" --branch "${TEAM_REPO_BRANCH}" ~/openhack
      
      cd ~/openhack/support/simulator
      az acr build --image devopsoh/simulator:latest --registry "${CONTAINER_REGISTRY}" --file Dockerfile . > "${AZ_SCRIPTS_PATH_OUTPUT_DIRECTORY}/simulator.txt"
      
      cd ~/openhack/support/tripviewer
      az acr build --image devopsoh/tripviewer:latest --registry ${CONTAINER_REGISTRY} --file Dockerfile . > "${AZ_SCRIPTS_PATH_OUTPUT_DIRECTORY}/tripviewer.txt"

      cd ~/openhack/apis/poi/web
      az acr build --image devopsoh/api-poi:${BASE_IMAGE_TAG} --registry ${CONTAINER_REGISTRY} --build-arg build_version=${BASE_IMAGE_TAG} --file Dockerfile . > "${AZ_SCRIPTS_PATH_OUTPUT_DIRECTORY}/poi.txt"

      cd ~/openhack/apis/trips
      az acr build --image devopsoh/api-trips:${BASE_IMAGE_TAG} --registry ${CONTAINER_REGISTRY} --build-arg build_version=${BASE_IMAGE_TAG} --file Dockerfile . > "${AZ_SCRIPTS_PATH_OUTPUT_DIRECTORY}/trips.txt"

      cd ~/openhack/apis/user-java
      az acr build --image devopsoh/api-user-java:${BASE_IMAGE_TAG} --registry ${CONTAINER_REGISTRY} --build-arg build_version=${BASE_IMAGE_TAG} --file Dockerfile . > "${AZ_SCRIPTS_PATH_OUTPUT_DIRECTORY}/userjava.txt"
      
      cd ~/openhack/apis/userprofile
      az acr build --image devopsoh/api-userprofile:${BASE_IMAGE_TAG} --registry ${CONTAINER_REGISTRY} --build-arg build_version=${BASE_IMAGE_TAG} --file Dockerfile . > "${AZ_SCRIPTS_PATH_OUTPUT_DIRECTORY}/userprofile.txt"
      '''
    environmentVariables: [
      {
        name: 'CONTAINER_REGISTRY'
        value: containerRegistryLoginServer
      }
      {
        name: 'BASE_IMAGE_TAG'
        value: varfile.baseImageTag
      }
      {
        name: 'TEAM_REPO'
        value: varfile.publicTeamRepo
      }
      {
        name: 'TEAM_REPO_BRANCH'
        value: varfile.publicTeamRepoBranch
      }
    ]
    retentionInterval: 'P1D'
  }
  dependsOn: [
    acrContributorRoleAssignment
  ]
}
