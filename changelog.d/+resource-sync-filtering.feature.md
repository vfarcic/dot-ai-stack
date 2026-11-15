**ResourceSyncConfig and CapabilityScanConfig: proxy-friendly endpoints and resource filtering values**

The `ResourceSyncConfig` and `CapabilityScanConfig` templates now reach the dot-ai service at `<name>.<namespace>.svc` instead of the short `dot-ai` hostname, which fails when controller traffic is routed through an HTTP proxy. The name follows the dot-ai subchart's own naming rules and resolves under any cluster DNS domain. Set `clusterDomain` to use the fully qualified `<name>.<namespace>.svc.<clusterDomain>`, or `resourceSync.mcpEndpoint` to override the resource sync endpoint entirely.

New optional values `resourceSync.includeResources`, `resourceSync.excludeResources`, `resourceSync.watchNamespaces` and `resourceSync.watchNamespaceLabelSelector` are passed through to the controller to limit which resources and namespaces are synced on large clusters. Omitting them keeps current behavior.
