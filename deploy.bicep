param clusterName string
param agentPublicKeyCertificate string
param location string = resourceGroup().location

resource cluster 'Microsoft.Kubernetes/connectedClusters@2022-10-01-preview' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    agentPublicKeyCertificate: agentPublicKeyCertificate
  }
}

resource fluxExtension 'Microsoft.KubernetesConfiguration/extensions@2022-11-01' = {
  name: 'flux'
  properties: {
    extensionType: 'microsoft.flux'
  }
  scope: cluster
}

resource fluxConfig 'Microsoft.KubernetesConfiguration/fluxConfigurations@2022-07-01' = {
  name: 'cluster-config'
  properties: {
    scope: 'cluster'
    namespace: 'cluster-config'
    sourceKind: 'GitRepository'
    gitRepository: {
      url: 'https://github.com/jagpreetstamber/flux-test-project'
      repositoryRef: {
        branch: 'main'
      }
      syncIntervalInSeconds: 120
    }
    kustomizations: {
      cluster: {
        path: './clusters/staging'
        syncIntervalInSeconds: 120
      }
      ngnix: {
        path: './ngnix'
        syncIntervalInSeconds: 120
      }
    }
  }
  dependsOn: [
    fluxExtension
  ]
  scope: cluster
}
