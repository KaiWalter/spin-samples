param resourceToken string
param location string
param skuName string = 'Standard'
param tags object

var queues = [
  'q-order-ingress'
]

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2021-11-01' = {
  name: 'sb-${resourceToken}'
  location: location
  tags: tags
  sku: {
    name: skuName
    tier: skuName
  }

  resource queueResources 'queues' = [for q in queues: {
    name: q
    properties: {
      maxSizeInMegabytes: 4096
    }
  }]

}
