param location string = resourceGroup().location

param adminUsername string = 'wragby'

@secure()

param adminPassword string

param vmCount int = 10

 

 

var numberOfVMs = 10

 

param OSVersion string = '2016-datacenter-smalldisk-g2'

 

 

 

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {

  name: 'VNet'

  location: location

  properties: {

    addressSpace: {

      addressPrefixes: [

        '10.0.0.0/16'

      ]

    }

  }

}

 

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {

  name: 'Subnet'

  parent: vnet

  properties: {

    addressPrefix: '10.0.0.0/24'

  }

}

 

resource publicIP 'Microsoft.Network/publicIPAddresses@2021-05-01' = [for i in range(0, numberOfVMs) : {

  name: format('ip-{0}', i)

  location: location

  properties: {

    publicIPAllocationMethod: 'Dynamic'

  }

}]

 

resource nic 'Microsoft.Network/networkInterfaces@2021-05-01' = [for i in range(0, numberOfVMs) : {

  name: format('nic-{0}', i)

  location: location

  properties: {

    ipConfigurations: [

      {

        name: 'ipconfig'

        properties: {

          subnet: {

            id: subnet.id

          }

          publicIPAddress: {

            id: publicIP[i].id

          }

        }

      }

    ]

  }

}]

 

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {

  name: 'stmorre364778bhugydtxf'

  location: location

  sku: {

    name: 'Standard_LRS'

  }

  kind: 'Storage'

}

 

 

 

resource vm 'Microsoft.Compute/virtualMachines@2021-07-01' = [for i in range(0, numberOfVMs) : {

  name: format('wragby-{0}', i)

  location: location

  properties: {

    hardwareProfile: {

      vmSize: 'Standard_D2s_v3'

    }

    osProfile: {

      computerName: format('vm-{0}', i)
      adminUsername: adminUsername
      adminPassword: adminPassword

    }

    networkProfile: {

      networkInterfaces: [

        {

          id: nic[i].id

        }

      ]

    }

    storageProfile: {

      imageReference: {

        publisher: 'MicrosoftWindowsServer'

        offer: 'windowsServer'

        sku: OSVersion

        version: 'latest'

      }

      osDisk: {

        createOption: 'FromImage'

       

        name: format('osdisk-{0}', i)

      }

    }

  }

}]

 

 

 

 

output vmNames array = [for i in range(0, vmCount) : vm[i].name]
