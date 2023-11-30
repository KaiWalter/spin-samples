param name string
param location string
param principalId string = ''
param resourceToken string
param tags object

module serviceBusResources './servicebus.bicep' = {
  name: 'sb-resources'
  params: {
    location: location
    tags: tags
    resourceToken: resourceToken
    skuName: 'Premium'
  }
}

module storageResources 'storage.bicep' = {
  name: 'st-resources'
  params: {
    location: location
    tags: tags
    resourceToken: resourceToken
  }
}
