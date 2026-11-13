**ResourceSyncConfig: FQDN endpoint and resource filtering values**

The `ResourceSyncConfig` template now defaults `mcpEndpoint` to the in-cluster FQDN of the dot-ai service (`http://<name>.<namespace>.svc.cluster.local:3456/...`) instead of the short `dot-ai` hostname, which fails when controller traffic is routed through an HTTP proxy. Set `resourceSync.clusterDomain` for clusters whose DNS domain is not `cluster.local`, or `resourceSync.mcpEndpoint` to override the endpoint entirely.

New optional values `resourceSync.includeResources`, `resourceSync.excludeResources`, `resourceSync.watchNamespaces` and `resourceSync.watchNamespaceLabelSelector` are passed through to the controller to limit which resources and namespaces are synced on large clusters. Omitting them keeps current behavior.
