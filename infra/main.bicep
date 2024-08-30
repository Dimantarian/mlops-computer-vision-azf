@description('Name of the Function App')
param functionAppName string

@description('Name of the Resource Group')
param resourceGroupName string

@description('Location of the resources')
param location string = resourceGroup().location

@description('Application Insights Instrumentation Key')
var applicationInsightsKey = 'your-instrumentation-key'

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: '${functionAppName}storage'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: '${functionAppName}-plan'
  kind: 'functionapp'
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
}

resource functionApp 'Microsoft.Web/sites@2021-02-01' = {
  name: functionAppName
  kind: 'functionapp'
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
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsightsKey
        }
      ]
    }
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${functionAppName}-ai'
  kind: 'web'
  location: location
  properties: {
    Application_Type: 'web'
  }
}

output functionAppEndpoint string = functionApp.properties.defaultHostName
