// Parameters
@description('Specifies the name of the Key Vault resource.')
param name string

@description('Specifies the location.')
param location string = resourceGroup().location

@description('Specifies the sku name of the Key Vault resource.')
@allowed([
  'premium'
  'standard'
])
param skuName string = 'standard'

@description('Specifies the Azure Active Directory tenant ID that should be used for authenticating requests to the key vault.')
param tenantId string = subscription().tenantId

@description('The default action of allow or deny when no other rules match. Allowed values: Allow or Deny')
@allowed([
  'Allow'
  'Deny'
])
param networkAclsDefaultAction string = 'Allow'

@description('Specifies whether the Azure Key Vault resource is enabled for deployments.')
param enabledForDeployment bool = true

@description('Specifies whether the Azure Key Vault resource is enabled for disk encryption.')
param enabledForDiskEncryption bool = true

@description('Specifies whether the Azure Key Vault resource is enabled for template deployment.')
param enabledForTemplateDeployment bool = true

@description('Specifies whether purge protection is enabled for this Azure Key Vault resource.')
param enablePurgeProtection bool = true

@description('Specifies whether enable the RBAC authorization for the Azure Key Vault resource.')
param enableRbacAuthorization bool = true

@description('Specifies whether the soft deelete is enabled for this Azure Key Vault resource.')
param enableSoftDelete bool = true

@description('Specifies the soft delete retention in days.')
param softDeleteRetentionInDays int = 7

@description('Specifies the resource id of the Log Analytics workspace.')
param workspaceId string

@description('Specifies the resource tags.')
param tags object

// Variables
var diagnosticSettingsName = 'diagnosticSettings'
var logCategories = [
  'AuditEvent'
  'AzurePolicyEvaluationDetails'
]
var metricCategories = [
  'AllMetrics'
]
var logs = [
  for category in logCategories: {
    category: category
    enabled: true
    retentionPolicy: {
      enabled: true
      days: 0
    }
  }
]
var metrics = [
  for category in metricCategories: {
    category: category
    enabled: true
    retentionPolicy: {
      enabled: true
      days: 0
    }
  }
]

// Resources
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    createMode: 'default'
    sku: {
      family: 'A'
      name: skuName
    }
    tenantId: tenantId
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: networkAclsDefaultAction
    }
    enabledForDeployment: enabledForDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enabledForTemplateDeployment: enabledForTemplateDeployment
    enablePurgeProtection: enablePurgeProtection ? enablePurgeProtection : null
    enableRbacAuthorization: enableRbacAuthorization
    enableSoftDelete: enableSoftDelete
    softDeleteRetentionInDays: softDeleteRetentionInDays
  }
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: diagnosticSettingsName
  scope: keyVault
  properties: {
    workspaceId: workspaceId
    logs: logs
    metrics: metrics
  }
}

// Outputs
output id string = keyVault.id
output name string = keyVault.name
