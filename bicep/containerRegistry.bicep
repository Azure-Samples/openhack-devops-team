param uniquer string

var varfile = json(loadTextContent('./variables.json'))
var resourcesPrefix = '${varfile.namePrefix}${uniquer}'

// https://docs.microsoft.com/en-us/azure/templates/microsoft.containerregistry/registries?tabs=bicep
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
  name: '${resourcesPrefix}cr'
  location: resourceGroup().location
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

// https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
// Contributor
// var role_definition_id_contributor = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')

// AcrPush
// var role_definition_id_acrpush = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8311e382-0749-4cb8-b61a-304f252e45ec')

// // AcrPull
// var role_definition_id_acrpull = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')

// // https://docs.microsoft.com/en-us/azure/templates/microsoft.managedidentity/userassignedidentities?tabs=bicep
// resource user_assigned_identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
//   name: '${uniquer}uami'
//   location: location
// }

// // https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?tabs=bicep
// resource role_assignment_contributor 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
//   name: guid(resourceGroup().id, role_definition_id_contributor)
//   properties: {
//     roleDefinitionId: role_definition_id_contributor
//     principalId: user_assigned_identity.properties.principalId
//   }
//   scope: containerRegistry
//   dependsOn: [
//     user_assigned_identity
//   ]
// }

// resource role_assignment_acrpush 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
//   name: guid(resourceGroup().id, role_definition_id_acrpush)
//   properties: {
//     roleDefinitionId: role_definition_id_acrpush
//     principalId: user_assigned_identity.properties.principalId
//   }
//   scope: containerRegistry
// }

// resource role_assignment_acrpull 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
//   name: guid(resourceGroup().id, role_definition_id_acrpull)
//   properties: {
//     roleDefinitionId: role_definition_id_acrpull
//     principalId: user_assigned_identity.properties.principalId
//   }
//   scope: containerRegistry
// }

// https://docs.microsoft.com/en-us/azure/templates/microsoft.resources/deploymentscripts?tabs=bicep
// resource deployment_simulator 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
//   name: '${uniquer}simulator4'
//   location: location
//   kind: 'AzureCLI'
//   identity: {
//     type: 'UserAssigned'
//     userAssignedIdentities: {
//       '${user_assigned_identity.id}': {}
//     }
//   }
//   properties: {
//     azCliVersion: '2.28.0'
//     cleanupPreference: 'Always'
//     scriptContent: '''
//       cd $HOME
//       git clone https://github.com/Azure-Samples/openhack-devops-proctor --branch main
//       cd openhack-devops-proctor//simulator
//       az acr build --image devopsoh/simulator:latest --registry ${containerRegistry} --file Dockerfile . > $AZ_SCRIPTS_OUTPUT_PATH
//     '''
//     environmentVariables: [
//       {
//         name: 'containerRegistry'
//         value: containerRegistry.properties.loginServer
//       }
//     ]
//     retentionInterval: 'P1D'
//   }
//   dependsOn: [
//     containerRegistry
//     user_assigned_identity
//   ]
// }

