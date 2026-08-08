# cleanuparr

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 2.10.3](https://img.shields.io/badge/AppVersion-2.10.3-informational?style=flat-square)

Removes stalled, blocked and orphaned downloads from the *arr ecosystem and triggers replacement searches

**Homepage:** <https://cleanuparr.github.io/Cleanuparr>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Botond Lovasz | <botilovasz@gmail.com> |  |

## Source Code

* <https://github.com/Cleanuparr/Cleanuparr>

## Requirements

Kubernetes: `>=1.25.0-0`

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity rules |
| commonAnnotations | object | `{}` | Additional annotations applied to every resource in the chart |
| commonLabels | object | `{}` | Additional labels applied to every resource in the chart |
| deploymentAnnotations | object | `{}` | Annotations for the Deployment |
| dnsConfig | object | `{}` | DNS config |
| dnsPolicy | string | `""` | DNS policy |
| env.TZ | string | `"Etc/UTC"` | Timezone. Ignored if a webhook like k8tz injects one. |
| extraArgs | list | `[]` | Additional arguments for the main container |
| extraContainers | list | `[]` | Additional sidecar containers |
| extraEnv | object | `{}` | Additional environment variables, as a map of name to value |
| extraEnvFrom | list | `[]` | Additional envFrom sources |
| extraEnvRaw | list | `[]` | Additional environment variables in raw format, for `valueFrom`. |
| extraInitContainers | list | `[]` | Additional init containers |
| extraVolumeMounts | list | `[]` | Additional volume mounts for the main container |
| extraVolumes | list | `[]` | Additional volumes |
| fullnameOverride | string | `""` | Override the fully qualified app name used for resource names |
| hostAliases | list | `[]` | Host aliases |
| httpRoute.annotations | object | `{}` | HTTPRoute annotations |
| httpRoute.enabled | bool | `false` | Create an HTTPRoute (Gateway API) |
| httpRoute.hostnames | list | `[]` | Hostnames matched by the route |
| httpRoute.parentRefs | list | `[]` | Gateways this route attaches to |
| httpRoute.rules | list | `[]` | Route rules. A sensible default rule is generated when empty. |
| image.digest | string | `""` | Image digest. When set, takes precedence over `image.tag`. |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| image.repository | string | `"ghcr.io/cleanuparr/cleanuparr"` | Image repository. This is the image published by the Cleanuparr project itself. |
| image.tag | string | `"2.10.3"` | Image tag. Pin this in production. |
| imagePullSecrets | list | `[]` | Image pull secrets |
| ingress.annotations | object | `{}` | Ingress annotations |
| ingress.className | string | `""` | IngressClass name |
| ingress.enabled | bool | `false` | Create an Ingress |
| ingress.hosts | list | `[{"host":"cleanuparr.local","paths":[{"path":"/","pathType":"Prefix"}]}]` | Ingress hosts |
| ingress.tls | list | `[]` | Ingress TLS configuration |
| livenessProbe | object | `{"enabled":true,"failureThreshold":3,"httpGet":{"path":"/","port":"http"},"initialDelaySeconds":0,"periodSeconds":10,"timeoutSeconds":5}` | Liveness probe against `/`. |
| nameOverride | string | `""` | Override the chart name portion of resource names |
| networkPolicy.egress | list | `[]` | Egress rules. When empty, no egress restrictions are applied. |
| networkPolicy.enabled | bool | `false` | Create a NetworkPolicy |
| networkPolicy.ingress | list | `[]` | Ingress rules. When empty, all ingress to the service port is allowed. |
| nodeSelector | object | `{}` | Node selector |
| persistence.config.accessMode | string | `"ReadWriteOnce"` | Access mode for the config volume |
| persistence.config.annotations | object | `{}` | Annotations for the config PVC |
| persistence.config.enabled | bool | `true` | Persist the application's data directory (`/config`) |
| persistence.config.existingClaim | string | `""` | Use an existing PVC instead of creating one |
| persistence.config.retain | bool | `false` | Keep the PVC when the release is uninstalled |
| persistence.config.size | string | `"1Gi"` | Size of the config volume |
| persistence.config.storageClass | string | `""` | StorageClass. Falls back to `global.storageClass`, then the cluster default. |
| persistence.media.accessMode | string | `"ReadWriteMany"` | Access mode for the media volume |
| persistence.media.annotations | object | `{}` | Annotations for the media PVC |
| persistence.media.enabled | bool | `false` | Mount the shared media volume. Cleanuparr compares what the download client reports against what is on disk, so this must be the same claim, at the same path, as the *arrs and the download client use. |
| persistence.media.existingClaim | string | `""` | Use an existing PVC. Required when `enabled` is true and `size` is unset. |
| persistence.media.mountPath | string | `"/data"` | Mount path for the media volume |
| persistence.media.retain | bool | `true` | Keep the PVC when the release is uninstalled. On by default: it holds the library. |
| persistence.media.size | string | `""` | Size of the media volume, when the chart creates it |
| persistence.media.storageClass | string | `""` | StorageClass for the media volume |
| podAnnotations | object | `{}` | Annotations for the pod |
| podDisruptionBudget.enabled | bool | `false` | Create a PodDisruptionBudget |
| podDisruptionBudget.maxUnavailable | int | `1` | Maximum unavailable pods |
| podDisruptionBudget.minAvailable | string | `""` | Minimum available pods |
| podLabels | object | `{}` | Labels for the pod |
| podSecurityContext | object | `{"fsGroup":1000,"fsGroupChangePolicy":"OnRootMismatch","seccompProfile":{"type":"RuntimeDefault"},"supplementalGroups":[]}` | Pod-level security context |
| priorityClassName | string | `""` | Priority class name |
| readinessProbe | object | `{"enabled":true,"failureThreshold":3,"httpGet":{"path":"/","port":"http"},"initialDelaySeconds":0,"periodSeconds":10,"timeoutSeconds":5}` | Readiness probe |
| replicaCount | int | `1` | Number of replicas. Must be 1. |
| resources | object | `{"limits":{"memory":"1Gi"},"requests":{"cpu":"25m","memory":"320Mi"}}` | Resource requests and limits |
| runtimeClassName | string | `""` | Runtime class name |
| securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":false,"runAsGroup":1000,"runAsNonRoot":true,"runAsUser":1000}` | Container-level security context. This image runs as root by default. It is given a non-root UID here; if the application fails to write to its data directory, align `podSecurityContext.fsGroup` with `runAsUser` or set `runAsUser: 0`. |
| service.annotations | object | `{}` | Service annotations |
| service.clusterIP | string | `""` | Static cluster IP |
| service.labels | object | `{}` | Service labels |
| service.loadBalancerIP | string | `""` | Load balancer IP, when `service.type` is LoadBalancer |
| service.nodePort | string | `""` | Node port, when `service.type` is NodePort |
| service.port | int | `11011` | Service port. The container always listens on 11011. |
| service.sessionAffinity | string | `""` | Session affinity |
| service.type | string | `"ClusterIP"` | Service type |
| serviceAccount.annotations | object | `{}` | Annotations for the ServiceAccount |
| serviceAccount.automount | bool | `false` | Mount the ServiceAccount API token. Not needed; nothing here uses the Kubernetes API. |
| serviceAccount.create | bool | `true` | Create a ServiceAccount |
| serviceAccount.name | string | `""` | Name of the ServiceAccount to use. Generated from the fullname when empty. |
| startupProbe | object | `{"enabled":true,"failureThreshold":60,"httpGet":{"path":"/","port":"http"},"initialDelaySeconds":5,"periodSeconds":5,"timeoutSeconds":5}` | Startup probe. Generous by default: first start migrates the database and large libraries take a while. |
| terminationGracePeriodSeconds | int | `30` | Termination grace period in seconds |
| tolerations | list | `[]` | Tolerations |
| topologySpreadConstraints | list | `[]` | Topology spread constraints |
| updateStrategy | object | `{"type":"Recreate"}` | Deployment strategy |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
