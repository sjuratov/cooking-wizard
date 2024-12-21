# Deploy Azure AI Foundry without a managed virtual network

## Azure Resources

The Bicep modules deploy the following Azure resources:

![Architecture](./images/no-managed-virtual-network.png)

| Resource                    | Type                                                                                                                                                                    | Description                                                                                                                 |
| --------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| Azure Application Insights  | [Microsoft.Insights/components](https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/components?pivots=deployment-language-bicep)                       | An Azure Application Insights instance associated with the Azure AI Foundry workspace                                       |
| Azure Monitor Log Analytics | [Microsoft.OperationalInsights/workspaces](https://learn.microsoft.com/en-us/azure/templates/microsoft.operationalinsights/workspaces?pivots=deployment-language-bicep) | An Azure Log Analytics workspace used to collect diagnostics logs and metrics from Azure resources                          |
| Azure Key Vault             | [Microsoft.KeyVault/vaults](https://learn.microsoft.com/en-us/azure/templates/microsoft.keyvault/vaults?pivots=deployment-language-bicep)                               | An Azure Key Vault instance associated with the Azure AI Foundry workspace                                                  |
| Azure Storage Account       | [Microsoft.Storage/storageAccounts](https://learn.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts)                                                | An Azure Storage instance associated with the Azure AI Foundry workspace                                                    |
| Azure Container Registry    | [Microsoft.ContainerRegistry/registries](https://learn.microsoft.com/en-us/azure/templates/microsoft.containerregistry/registries)                                      | An Azure Container Registry instance associated with the Azure AI Foundry workspace                                         |
| Azure AI Hub / Project      | [Microsoft.MachineLearningServices/workspaces](https://learn.microsoft.com/en-us/azure/templates/microsoft.machinelearningservices/workspaces)                          | An Azure AI Foundry Hub and Project (Azure ML Workspace of kind 'hub' and 'project')                                        |
| Azure AI Services           | [Microsoft.CognitiveServices/accounts](https://learn.microsoft.com/en-us/azure/templates/microsoft.cognitiveservices/accounts)                                          | An Azure AI Services as the model-as-a-service endpoint provider including GPT-4o and ADA Text Embeddings model deployments |

> [!NOTE]
> You can change some provisioning parameters in the [main.bicepparam](./main.bicepparam) parameters file.

## Bicep Parameters

Before deploying the environment using the Bicep templates, ensure you provide values for the required parameters in the [main.bicepparam](./main.bicepparam) parameters file.

| Name                                      | Type   | Allowed Values                                             | Description                                                                                                                                             |
| ----------------------------------------- | ------ | ---------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| prefix                                    | string | N/A                                                        | Specifies the name prefix for all the Azure resources.                                                                                                  |
| suffix                                    | string | N/A                                                        | Specifies the name suffix for all the Azure resources.                                                                                                  |
| location                                  | string | N/A                                                        | Specifies the location for all the Azure resources.                                                                                                     |
| userObjectId                              | string | N/A                                                        | Specifies the object id of a Microsoft Entra ID user to assign necessary RBAC to.                                                                       |
| hubName                                   | string | N/A                                                        | Specifies the name Azure AI Hub workspace.                                                                                                              |
| hubFriendlyName                           | string | N/A                                                        | Specifies the friendly name of the Azure AI Hub workspace.                                                                                              |
| hubDescription                            | string | N/A                                                        | Specifies the description for the Azure AI Hub workspace displayed in Azure AI Foundry.                                                                 |
| hubIsolationMode                          | string | AllowInternetOutbound, AllowOnlyApprovedOutbound, Disabled | Specifies the isolation mode for the managed network of the Azure AI Hub workspace.                                                                     |
| hubPublicNetworkAccess                    | string | N/A                                                        | Specifies the public network access for the Azure AI Hub workspace.                                                                                     |
| connectionAuthType                        | string | ApiKey, AAD, ManagedIdentity, None                         | Specifies the authentication method for the OpenAI Service connection.                                                                                  |
| customConnectionName                      | string | N/A                                                        | Specifies the name for the custom connection.                                                                                                           |
| projectName                               | string | N/A                                                        | Specifies the name Azure AI Project workspace.                                                                                                          |
| projectFriendlyName                       | string | N/A                                                        | Specifies the friendly name of the Azure AI Project workspace.                                                                                          |
| projectPublicNetworkAccess                | string | N/A                                                        | Specifies the public network access for the Azure AI Project workspace.                                                                                 |
| logAnalyticsName                          | string | N/A                                                        | Specifies the name of the Azure Log Analytics resource.                                                                                                 |
| logAnalyticsSku                           | string | Free, Standalone, PerNode, PerGB2018                       | Specifies the service tier of the workspace.                                                                                                            |
| logAnalyticsRetentionInDays               | int    | N/A                                                        | Specifies the workspace data retention in days. -1 means Unlimited retention for the Unlimited Sku. 730 days is the maximum allowed for all other Skus. |
| applicationInsightsName                   | string | N/A                                                        | Specifies the name of the Azure Application Insights resource.                                                                                          |
| aiServicesName                            | string | N/A                                                        | Specifies the name of the Azure AI Services resource.                                                                                                   |
| aiServicesSku                             | object | N/A                                                        | Specifies the resource model definition representing SKU.                                                                                               |
| aiServicesIdentity                        | object | N/A                                                        | Specifies the identity of the Azure AI Services resource.                                                                                               |
| aiServicesCustomSubDomainName             | string | N/A                                                        | Specifies an optional subdomain name used for token-based authentication.                                                                               |
| aiServicesDisableLocalAuth                | bool   | N/A                                                        | Specifies whether to disable local authentication via API key.                                                                                          |
| aiServicesPublicNetworkAccess             | string | Enabled, Disabled                                          | Specifies whether public endpoint access is allowed for this account.                                                                                   |
| openAiDeployments                         | array  | N/A                                                        | Specifies the OpenAI deployments to create.                                                                                                             |
| keyVaultName                              | string | N/A                                                        | Specifies the name of the Azure Key Vault resource.                                                                                                     |
| keyVaultNetworkAclsDefaultAction          | string | Allow, Deny                                                | Specifies the default action of allow or deny when no other rules match for the Azure Key Vault resource.                                               |
| keyVaultEnabledForDeployment              | bool   | N/A                                                        | Specifies whether the Azure Key Vault resource is enabled for deployments.                                                                              |
| keyVaultEnabledForDiskEncryption          | bool   | N/A                                                        | Specifies whether the Azure Key Vault resource is enabled for disk encryption.                                                                          |
| keyVaultEnabledForTemplateDeployment      | bool   | N/A                                                        | Specifies whether the Azure Key Vault resource is enabled for template deployment.                                                                      |
| keyVaultEnableSoftDelete                  | bool   | N/A                                                        | Specifies whether soft delete is enabled for the Azure Key Vault resource.                                                                              |
| keyVaultEnablePurgeProtection             | bool   | N/A                                                        | Specifies whether purge protection is enabled for the Azure Key Vault resource.                                                                         |
| keyVaultEnableRbacAuthorization           | bool   | N/A                                                        | Specifies whether to enable RBAC authorization for the Azure Key Vault resource.                                                                        |
| keyVaultSoftDeleteRetentionInDays         | int    | N/A                                                        | Specifies the soft delete retention in days.                                                                                                            |
| acrName                                   | string | N/A                                                        | Specifies the name of the Azure Container Registry resource.                                                                                            |
| acrAdminUserEnabled                       | bool   | N/A                                                        | Enable admin user that have push/pull permission to the registry.                                                                                       |
| acrSku                                    | string | Basic, Standard, Premium                                   | Tier of your Azure Container Registry.                                                                                                                  |
| storageAccountName                        | string | N/A                                                        | Specifies the name of the Azure Storage Account resource.                                                                                               |
| storageAccountAccessTier                  | string | N/A                                                        | Specifies the access tier of the Azure Storage Account resource (default: Hot).                                                                         |
| storageAccountAllowBlobPublicAccess       | bool   | N/A                                                        | Specifies whether the Azure Storage Account resource allows public access to blobs (default: false).                                                    |
| storageAccountAllowSharedKeyAccess        | bool   | N/A                                                        | Specifies whether the Azure Storage Account resource allows shared key access (default: true).                                                          |
| storageAccountAllowCrossTenantReplication | bool   | N/A                                                        | Specifies whether the Azure Storage Account resource allows cross-tenant replication (default: false).                                                  |
| storageAccountMinimumTlsVersion           | string | N/A                                                        | Specifies the minimum TLS version to be permitted on requests to the Azure Storage Account resource (default: TLS1_2).                                  |
| storageAccountANetworkAclsDefaultAction   | string | Allow, Deny                                                | Default action of allow or deny when no other rules match.                                                                                              |
| storageAccountSupportsHttpsTrafficOnly    | bool   | N/A                                                        | Specifies whether the Azure Storage Account resource should only support HTTPS traffic.                                                                 |
| tags                                      | object | N/A                                                        | Specifies the resource tags for all the resources.                                                                                                      |


## Getting Started

To deploy the infrastructure for the secure Azure AI Foundry, you need to:

### Prerequisites

Before you begin, ensure you have the following:

- An active [Azure subscription](https://azure.microsoft.com/en-us/free/)
- Azure CLI installed on your local machine. Follow the [installation guide](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) if needed.
- Azure Developed CLI installed on your local machine. Follow the [installation guide](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd?tabs=winget-windows%2Cbrew-mac%2Cscript-linux&pivots=os-windows) if needed.
- Appropriate permissions to create resources in your Azure account
- Basic knowledge of using the command line interface

### Step 1: Clone the Repository

Start by cloning the repository to your local machine:

```bash
git clone <repository_url>
cd bicep
```

### Step 2: Configure Parameters

Edit the [main.bicepparam](./main.bicepparam) parameters file to configure values for the parameters required by the [Bicep](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/file) templates.

### Step 3: Deploy Resources

Run the following commands to deploy the resources:

```bash
az login
azd login
azd up
```

## Learn More

For more information, see:

- [Azure AI Foundry Documentation](https://aka.ms/aistudio/docs)