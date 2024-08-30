param location string = resourceGroup().location
param resourceGroupName string = resourceGroup().name

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: uniqueString(resourceGroup().id)
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: 'plan-${resourceGroupName}'
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
}

resource functionApp 'Microsoft.Web/sites@2021-02-01' = {
  name: 'func-${resourceGroupName}'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: storageAccount.properties.primaryEndpoints.blob
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'python'
        }
      ]
    }
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'ai-${resourceGroupName}'
  kind: 'web'
  location: location
  properties: {
    Application_Type: 'web'
  }
}

output storageAccountName string = storageAccount.name
output functionAppName string = functionApp.name
output appInsightsName string = appInsights.name
output resourceGroup string = resourceGroupName
