@description('Name of the storage account')
param storageAccountName string

@description('Name of the search service')
param searchServiceName string

@description('Name of the key vault')
param keyVaultName string

@description('Name of the virtual network')
param virtualNetworkName string

@description('Name of the virtual machine')
param virtualMachineName string

@description('Name of the bastion host')
param bastionHostName string

@description('Name of the public IP address for the bastion host')
param publicIPAddressName string

@description('Name of the AI Foundry hub workspace')
param aiHubWorkspaceName string

@description('Name of the AI Foundry project workspace')
param aiProjectWorkspaceName string

@description('Administrator password for the virtual machine')
@secure()
param adminPassword string

@description('Administrator username for the virtual machine')
param adminUsername string

@description('Name of the network interface')
param networkInterfaceName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2024-01-01' = {
  name: storageAccountName
  location: 'eastus2'
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    publicNetworkAccess: 'Enabled'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }
    supportsHttpsTrafficOnly: true
  }
}

resource searchService 'Microsoft.Search/searchServices@2025-02-01-preview' = {
  name: searchServiceName
  location: 'East US 2'
  sku: {
    name: 'standard2'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    replicaCount: 1
    partitionCount: 1
    publicNetworkAccess: 'Enabled'
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2024-12-01-preview' = {
  name: keyVaultName
  location: 'eastus2'
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: 'af5aa053-13bd-491e-adf8-e1f7c8a7cb01'
    accessPolicies: [
      {
        tenantId: 'af5aa053-13bd-491e-adf8-e1f7c8a7cb01'
        objectId: '7121affe-6f5c-4e61-baa8-280ee2dff9d1'
        permissions: {
          keys: [ 'all' ]
          secrets: [ 'all' ]
          certificates: [ 'all' ]
        }
      }
    ]
    publicNetworkAccess: 'Enabled'
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: virtualNetworkName
  location: 'eastus2'
  properties: {
    addressSpace: {
      addressPrefixes: [ '10.0.0.0/16' ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefixes: [ '10.0.0.0/24' ]
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefixes: [ '10.0.1.0/26' ]
        }
      }
    ]
  }
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2024-05-01' = {
  name: networkInterfaceName
  location: 'eastus2'
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, 'default')
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: virtualMachineName
  location: 'eastus2'
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2s'
    }
    osProfile: {
      computerName: virtualMachineName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsDesktop'
        offer: 'Windows-11'
        sku: 'win11-21h2-ent'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
        }
      ]
    }
  }
}

resource aiFoundryHub 'Microsoft.MachineLearningServices/workspaces@2025-01-01-preview' = {
  name: aiHubWorkspaceName
  location: 'eastus2'
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  kind: 'Hub'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: 'AI Foundry Hub'
    publicNetworkAccess: 'Disabled'
    enableDataIsolation: true
    systemDatastoresAuthMode: 'identity'
  }
}

resource aiFoundryProject 'Microsoft.MachineLearningServices/workspaces@2025-01-01-preview' = {
  name: aiProjectWorkspaceName
  location: 'eastus2'
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  kind: 'Project'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: 'AI Foundry Project'
    publicNetworkAccess: 'Disabled'
    enableDataIsolation: true
    systemDatastoresAuthMode: 'identity'
    hubResourceId: aiFoundryHub.id
  }
}

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2024-05-01' = {
  name: publicIPAddressName
  location: 'eastus2'
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

resource bastionHost 'Microsoft.Network/bastionHosts@2024-05-01' = {
  name: bastionHostName
  location: 'eastus2'
  dependsOn: [virtualNetwork]
  sku: {
    name: 'Basic'
  }
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, 'AzureBastionSubnet')
          }
          publicIPAddress: {
            id: publicIPAddress.id
          }
        }
      }
    ]
  }
}
