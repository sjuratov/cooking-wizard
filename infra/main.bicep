// Inspired by https://github.com/Azure-Samples/azure-ai-studio-secure-bicep/tree/main/bicep/novnet

// Parameters
@description('Specifies the name prefix for all the Azure resources.')
@minLength(4)
@maxLength(10)
param prefix string = substring(uniqueString(resourceGroup().id), 0, 4)

@description('Specifies the name suffix or all the Azure resources.')
@minLength(4)
@maxLength(10)
param suffix string = substring(uniqueString(resourceGroup().id), 0, 4)

@description('Specifies the location for all the Azure resources.')
param location string = resourceGroup().location

@description('Specifies the name of the Network Security Perimeter.')
param nspName string = ''

@description('Specifies the name Azure AI Hub workspace.')
param hubName string = ''

@description('Specifies the friendly name of the Azure AI Hub workspace.')
param hubFriendlyName string = 'Azure AI Foundry Hub'

@description('Specifies the description for the Azure AI Hub workspace displayed in Azure AI Foundry.')
param hubDescription string = 'This is a hub for use in Azure AI Foundry.'

@description('Specifies the Isolation mode for the managed network of the Azure AI Hub workspace.')
@allowed([
  'AllowInternetOutbound'
  'AllowOnlyApprovedOutbound'
  'Disabled'
])
param hubIsolationMode string = 'Disabled'

@description('Specifies the public network access for the Azure AI Hub workspace.')
param hubPublicNetworkAccess string = 'Enabled'

@description('Specifies the authentication method for the OpenAI Service connection.')
@allowed([
  'ApiKey'
  'AAD'
  'ManagedIdentity'
  'None'
])
param connectionAuthType string = 'AAD'

@description('Determines whether or not to use credentials for the system datastores of the workspace workspaceblobstore and workspacefilestore. The default value is accessKey, in which case, the workspace will create the system datastores with credentials. If set to identity, the workspace will create the system datastores with no credentials.')
@allowed([
  'identity'
  'accessKey'
])
param systemDatastoresAuthMode string = 'identity'

@description('Specifies the name for the Azure AI Foundry Hub Project workspace.')
param projectName string = ''

@description('Specifies the friendly name for the Azure AI Foundry Project.')
param projectFriendlyName string = 'Azure AI Foundry Project'

@description('Specifies the public network access for the Azure AI Foundry Project.')
param projectPublicNetworkAccess string = 'Enabled'

@description('Specifies the name of the Azure Log Analytics resource.')
param logAnalyticsName string = ''

@description('Specifies the service tier of the workspace: Free, Standalone, PerNode, Per-GB.')
@allowed([
  'Free'
  'Standalone'
  'PerNode'
  'PerGB2018'
])
param logAnalyticsSku string = 'PerNode'

@description('Specifies the workspace data retention in days. -1 means Unlimited retention for the Unlimited Sku. 730 days is the maximum allowed for all other Skus.')
param logAnalyticsRetentionInDays int = 60

@description('Specifies the name of the Azure Application Insights resource.')
param applicationInsightsName string = ''

@description('Specifies the name of the Azure AI Services resource.')
param aiServicesName string = ''

@description('Specifies the resource model definition representing SKU.')
param aiServicesSku object = {
  name: 'S0'
}

@description('Specifies the identity of the Azure AI Services resource.')
param aiServicesIdentity object = {
  type: 'SystemAssigned'
}

@description('Specifies an optional subdomain name used for token-based authentication.')
param aiServicesCustomSubDomainName string = ''

@description('Specifies whether disable the local authentication via API key.')
param aiServicesDisableLocalAuth bool = false

@description('Specifies whether or not public endpoint access is allowed for this account..')
@allowed([
  'Enabled'
  'Disabled'
])
param aiServicesPublicNetworkAccess string = 'Enabled'

@description('Specifies the OpenAI deployments to create.')
param openAiDeployments array = [
  {
    model: {
      name: 'text-embedding-ada-002'
      version: '2'
    }
    sku: {
      name: 'Standard'
      capacity: 10
    }
  }
  {
    model: {
      name: 'gpt-4o'
      version: '2024-05-13'
    }
    sku: {
      name: 'Standard'
      capacity: 10
    }
  }
  {
    model: {
      name: 'gpt-4o-mini'
      version: '2024-07-18'
    }
    sku: {
      name: 'GlobalStandard'
      capacity: 10
    }
  }
]

@description('Specifies the name of the Azure Key Vault resource.')
param keyVaultName string = ''

@description('Specifies the default action of allow or deny when no other rules match for the Azure Key Vault resource. Allowed values: Allow or Deny')
@allowed([
  'Allow'
  'Deny'
])
param keyVaultNetworkAclsDefaultAction string = 'Allow'

@description('Specifies whether the Azure Key Vault resource is enabled for deployments.')
param keyVaultEnabledForDeployment bool = true

@description('Specifies whether the Azure Key Vault resource is enabled for disk encryption.')
param keyVaultEnabledForDiskEncryption bool = true

@description('Specifies whether the Azure Key Vault resource is enabled for template deployment.')
param keyVaultEnabledForTemplateDeployment bool = true

@description('Specifies whether the soft delete is enabled for this Azure Key Vault resource.')
param keyVaultEnableSoftDelete bool = true

@description('Specifies whether purge protection is enabled for this Azure Key Vault resource.')
param keyVaultEnablePurgeProtection bool = true

@description('Specifies whether enable the RBAC authorization for the Azure Key Vault resource.')
param keyVaultEnableRbacAuthorization bool = true

@description('Specifies the soft delete retention in days.')
param keyVaultSoftDeleteRetentionInDays int = 7

@description('Specifies whether creating the Azure Container Registry.')
param acrEnabled bool = true

@description('Specifies the name of the Azure Container Registry resource.')
param acrName string = ''

@description('Enable admin user that have push / pull permission to the registry.')
param acrAdminUserEnabled bool = false

@description('Tier of your Azure Container Registry.')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param acrSku string = 'Basic'

@description('Specifies the name of the Azure Azure Storage Account resource resource.')
param storageAccountName string = ''

@description('Specifies the access tier of the Azure Storage Account resource. The default value is Hot.')
param storageAccountAccessTier string = 'Hot'

@description('Specifies whether the Azure Storage Account resource allows public access. The default value is enabled.')
param storageAccountAllowPublicAccess string = 'Enabled'

@description('Specifies whether the Azure Storage Account resource allows public access to blobs. The default value is false.')
param storageAccountAllowBlobPublicAccess bool = false

@description('Specifies whether the Azure Storage Account resource allows shared key access. The default value is true.')
param storageAccountAllowSharedKeyAccess bool = false

@description('Specifies whether the Azure Storage Account resource allows cross-tenant replication. The default value is false.')
param storageAccountAllowCrossTenantReplication bool = false

@description('Specifies the minimum TLS version to be permitted on requests to the Azure Storage Account resource. The default value is TLS1_2.')
param storageAccountMinimumTlsVersion string = 'TLS1_2'

@description('The default action of allow or deny when no other rules match. Allowed values: Allow or Deny')
@allowed([
  'Allow'
  'Deny'
])
param storageAccountANetworkAclsDefaultAction string = 'Allow'

@description('Specifies whether the Azure Storage Account resource should only support HTTPS traffic.')
param storageAccountSupportsHttpsTrafficOnly bool = true

@description('Specifies whether creating the Network Security Perimeter.')
param nspEnabled bool = false

@description('Specifies the resource tags for all the resoources.')
param tags object = {}

@description('Specifies the object id of a Microsoft Entra ID user. In general, this the object id of the system administrator who deploys the Azure resources.')
param userObjectId string = ''

// Resources
module keyVault 'modules/keyVault.bicep' = {
  name: 'keyVault'
  params: {
    // properties
    name: empty(keyVaultName) ? ('${prefix}-key-vault-${suffix}') : keyVaultName
    location: location
    tags: tags
    networkAclsDefaultAction: keyVaultNetworkAclsDefaultAction
    enabledForDeployment: keyVaultEnabledForDeployment
    enabledForDiskEncryption: keyVaultEnabledForDiskEncryption
    enabledForTemplateDeployment: keyVaultEnabledForTemplateDeployment
    enablePurgeProtection: keyVaultEnablePurgeProtection
    enableRbacAuthorization: keyVaultEnableRbacAuthorization
    enableSoftDelete: keyVaultEnableSoftDelete
    softDeleteRetentionInDays: keyVaultSoftDeleteRetentionInDays
    workspaceId: workspace.outputs.id
  }
}

module workspace 'modules/logAnalytics.bicep' = {
  name: 'workspace'
  params: {
    // properties
    name: empty(logAnalyticsName) ? toLower('${prefix}-log-analytics-${suffix}') : logAnalyticsName
    location: location
    tags: tags
    sku: logAnalyticsSku
    retentionInDays: logAnalyticsRetentionInDays
  }
}

module applicationInsights 'modules/applicationInsights.bicep' = {
  name: 'applicationInsights'
  params: {
    // properties
    name: empty(applicationInsightsName) ? toLower('${prefix}-app-insights-${suffix}') : applicationInsightsName
    location: location
    tags: tags
    workspaceId: workspace.outputs.id
  }
}

module containerRegistry 'modules/containerRegistry.bicep' = if (acrEnabled) {
  name: 'containerRegistry'
  params: {
    // properties
    name: empty(acrName) ? toLower('${prefix}sjacrjs${suffix}') : acrName
    location: location
    tags: tags
    sku: acrSku
    adminUserEnabled: acrAdminUserEnabled
    workspaceId: workspace.outputs.id
  }
}

module storageAccount 'modules/storageAccount.bicep' = {
  name: 'storageAccount'
  params: {
    // properties
    name: empty(storageAccountName) ? toLower('${prefix}datastore${suffix}') : storageAccountName
    location: location
    tags: tags
    accessTier: storageAccountAccessTier
    allowBlobPublicAccess: storageAccountAllowBlobPublicAccess
    allowSharedKeyAccess: storageAccountAllowSharedKeyAccess
    allowCrossTenantReplication: storageAccountAllowCrossTenantReplication
    allowStorageAccountPublicAccess: storageAccountAllowPublicAccess
    minimumTlsVersion: storageAccountMinimumTlsVersion
    networkAclsDefaultAction: storageAccountANetworkAclsDefaultAction
    supportsHttpsTrafficOnly: storageAccountSupportsHttpsTrafficOnly
    workspaceId: workspace.outputs.id
  }
}

module aiServices 'modules/aiServices.bicep' = {
  name: 'aiServices'
  params: {
    // properties
    name: empty(aiServicesName) ? toLower('${prefix}-ai-services-${suffix}') : aiServicesName
    location: location
    tags: tags
    sku: aiServicesSku
    identity: aiServicesIdentity
    customSubDomainName: empty(aiServicesCustomSubDomainName)
      ? toLower('${prefix}-sj-ai-services-js-${suffix}')
      : aiServicesCustomSubDomainName
    disableLocalAuth: aiServicesDisableLocalAuth
    publicNetworkAccess: aiServicesPublicNetworkAccess
    deployments: openAiDeployments
    workspaceId: workspace.outputs.id
  }
}

module hub 'modules/hub.bicep' = {
  name: 'hub'
  params: {
    // workspace organization
    name: empty(hubName) ? toLower('${prefix}-hub-${suffix}') : hubName
    friendlyName: hubFriendlyName
    description_: hubDescription
    location: location
    tags: tags

    // dependent resources
    aiServicesName: aiServices.outputs.name
    applicationInsightsId: applicationInsights.outputs.id
    containerRegistryId: acrEnabled ? containerRegistry.outputs.id : ''
    keyVaultId: keyVault.outputs.id
    storageAccountId: storageAccount.outputs.id
    connectionAuthType: connectionAuthType
    systemDatastoresAuthMode: systemDatastoresAuthMode

    // workspace configuration
    publicNetworkAccess: hubPublicNetworkAccess
    isolationMode: hubIsolationMode
    workspaceId: workspace.outputs.id
  }
}

module project 'modules/project.bicep' = {
  name: 'project'
  params: {
    // workspace organization
    name: empty(projectName) ? toLower('${prefix}-project-${suffix}') : projectName
    friendlyName: projectFriendlyName
    location: location
    tags: tags

    // workspace configuration
    publicNetworkAccess: projectPublicNetworkAccess
    hubId: hub.outputs.id
    workspaceId: workspace.outputs.id
  }
}

module networkSecurityPerimeter 'modules/networkSecurityPerimeter.bicep' = if (nspEnabled) {
  name: 'networkSecurityPerimeter'
  params: {
    name: empty(nspName) ? toLower('${prefix}-nsp-${suffix}') : nspName
    location: location
    keyVaultId: keyVault.outputs.id
    storageAccountId: storageAccount.outputs.id
  }
}

////////////////////////////////////////////////////////////////////////////////////////
// Roles definitions and assignments
////////////////////////////////////////////////////////////////////////////////////////

/////////////////
// Azure AI Services
/////////////////

// Cognitive Services Contributor
resource cognitiveServicesContributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '25fbc0a9-bd7c-42a3-aa1a-3b75d497ee68'
  scope: subscription()
}

resource cognitiveServicesContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(userObjectId)) {
  name: guid(aiServices.name, cognitiveServicesContributorRoleDefinition.id, userObjectId, 'User')
  scope: resourceGroup()
  properties: {
    roleDefinitionId: cognitiveServicesContributorRoleDefinition.id
    principalType: 'User'
    principalId: userObjectId
  }
}

resource cognitiveServicesContributorServicePrincipalRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(aiServices.name, cognitiveServicesContributorRoleDefinition.id, userObjectId, 'ServicePrincipal')
  scope: resourceGroup()
  properties: {
    roleDefinitionId: cognitiveServicesContributorRoleDefinition.id
    principalType: 'ServicePrincipal'
    principalId: project.outputs.principalId
  }
}

// Cognitive Services OpenAI Contributor
resource cognitiveServicesOpenAIContributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: 'a001fd3d-188f-4b5d-821b-7da978bf7442'
  scope: subscription()
}

resource cognitiveServicesOpenAIContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(userObjectId)) {
  name: guid(aiServices.name, cognitiveServicesOpenAIContributorRoleDefinition.id, userObjectId)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: cognitiveServicesOpenAIContributorRoleDefinition.id
    principalType: 'User'
    principalId: userObjectId
  }
}

// Cognitive Services OpenAI User
resource cognitiveServicesOpenAIUserRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd'
  scope: subscription()
}

resource cognitiveServicesOpenAIUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(aiServices.name, cognitiveServicesOpenAIUserRoleDefinition.id, userObjectId)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: cognitiveServicesOpenAIUserRoleDefinition.id
    principalType: 'ServicePrincipal'
    principalId: project.outputs.principalId
  }
}

// Cognitive Services User
resource cognitiveServicesUserRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: 'a97b65f3-24c7-4388-baec-2e87135dc908'
  scope: subscription()
}

resource cognitiveServicesUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(aiServices.name, cognitiveServicesUserRoleDefinition.id, userObjectId)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: cognitiveServicesUserRoleDefinition.id
    principalType: 'ServicePrincipal'
    principalId: project.outputs.principalId
  }
}

/////////////////
// Azure AI Foundry Hub
/////////////////

// AzureML Data Scientist
resource azureMLDataScientistRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: 'f6c7c914-8db3-469d-8ca1-694a8f32e121'
  scope: subscription()
}

resource azureMLDataScientistUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(userObjectId)) {
  name: guid(hub.name, azureMLDataScientistRole.id, userObjectId)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: azureMLDataScientistRole.id
    principalType: 'User'
    principalId: userObjectId
  }
}

/////////////////
// Azure AI Foundry Project
/////////////////

resource azureMLDataScientistManagedIdentityProjectRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' =  {
  name: guid(project.name, azureMLDataScientistRole.id, aiServices.name)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: azureMLDataScientistRole.id
    principalType: 'ServicePrincipal'
    principalId: aiServices.outputs.principalId
  }
}

/////////////////
// Azure Key Vault
/////////////////

// Key Vault Administrator
resource keyVaultAdministratorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '00482a5a-887f-4fb3-b363-3b7fe8e74483'
  scope: subscription()
}

resource keyVaultAdministratorUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(userObjectId)) {
  name: guid(keyVault.name, keyVaultAdministratorRoleDefinition.id, userObjectId)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: keyVaultAdministratorRoleDefinition.id
    principalType: 'User'
    principalId: userObjectId
  }
}

/////////////////
// Azure Storage Account
/////////////////

// Storage Account Contributor
resource storageAccountContributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '17d1049b-9a84-46fb-8f53-869881c3d3ab'
  scope: subscription()
}

// Storage Blob Data Contributor
resource storageBlobDataContributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
  scope: subscription()
}

// Storage File Data Privileged Contributor
resource storageFileDataPrivilegedContributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '69566ab7-960f-475b-8e7c-b3118f30c6bd'
  scope: subscription()
}

// Storage Table Data Contributor
resource storageTableDataContributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3'
  scope: subscription()
}

resource storageAccountContributorUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(userObjectId)) {
  name: guid(storageAccount.name, storageAccountContributorRoleDefinition.id, userObjectId)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: storageAccountContributorRoleDefinition.id
    principalType: 'User'
    principalId: userObjectId
  }
}

resource storageBlobDataContributorUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(userObjectId)) {
  name: guid(storageAccount.name, storageBlobDataContributorRoleDefinition.id, userObjectId)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: storageBlobDataContributorRoleDefinition.id
    principalType: 'User'
    principalId: userObjectId
  }
}

resource storageFileDataPrivilegedContributorUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(userObjectId)) {
  name: guid(storageAccount.name, storageFileDataPrivilegedContributorRoleDefinition.id, userObjectId)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: storageFileDataPrivilegedContributorRoleDefinition.id
    principalType: 'User'
    principalId: userObjectId
  }
}

resource storageTableDataContributorUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(userObjectId)) {
  name: guid(storageAccount.name, storageTableDataContributorRoleDefinition.id, userObjectId)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: storageTableDataContributorRoleDefinition.id
    principalType: 'User'
    principalId: userObjectId
  }
}

resource storageBlobDataContributorManagedIdentityRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.name, storageBlobDataContributorRoleDefinition.id, aiServices.name)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: storageBlobDataContributorRoleDefinition.id
    principalType: 'ServicePrincipal'
    principalId: aiServices.outputs.principalId
  }
}

output AZURE_SUBSCRIPTION_ID string = subscription().subscriptionId
output AZURE_AI_FOUNDRY_PROJECT_NAME string = project.outputs.name
output AZURE_AI_FOUNDRY_DISCOVERY_URL string = project.outputs.projectDiscoveryUrl
output AZURE_AI_DEPLOYMENT_MODEL string = openAiDeployments[1].model.name
