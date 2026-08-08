# jellyfin

![Version: 0.1.2](https://img.shields.io/badge/Version-0.1.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 10.11.11](https://img.shields.io/badge/AppVersion-10.11.11-informational?style=flat-square)

Jellyfin — the free software media system, with hardware transcoding support

**Homepage:** <https://jellyfin.org>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Botond Lovasz | <botilovasz@gmail.com> |  |

## Source Code

* <https://github.com/jellyfin/jellyfin>

## Requirements

Kubernetes: `>=1.25.0-0`

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity rules |
| commonAnnotations | object | `{}` | Additional annotations applied to every resource in the chart |
| commonLabels | object | `{}` | Additional labels applied to every resource in the chart |
| config.configDir | string | `""` | JELLYFIN_CONFIG_DIR. Empty means `<persistence.config.mountPath>/config`. |
| config.logDir | string | `""` | JELLYFIN_LOG_DIR. Empty means `<persistence.config.mountPath>/log`. |
| deploymentAnnotations | object | `{}` | Annotations for the Deployment |
| dnsConfig | object | `{}` | DNS config |
| dnsPolicy | string | `""` | DNS policy |
| env.TZ | string | `"Etc/UTC"` | Timezone. Ignored if a webhook like k8tz injects one. |
| extraArgs | list | `[]` | Additional arguments for the main container |
| extraContainers | list | `[]` | Additional sidecar containers |
| extraEnv | object | `{}` | Additional environment variables, as a map of name to value |
| extraEnvFrom | list | `[]` | Additional envFrom sources |
| extraEnvRaw | list | `[]` | Additional environment variables in raw format, for `valueFrom` |
| extraInitContainers | list | `[]` | Additional init containers |
| extraVolumeMounts | list | `[]` | Additional volume mounts for the main container |
| extraVolumes | list | `[]` | Additional volumes |
| fullnameOverride | string | `""` | Override the fully qualified app name used for resource names |
| hardwareAcceleration.devicePlugin.count | int | `1` | How many devices to request |
| hardwareAcceleration.devicePlugin.resource | string | `""` | Resource name the plugin advertises, e.g. gpu.intel.com/i915, amd.com/gpu or squat.ai/dri |
| hardwareAcceleration.dra.count | int | `1` | How many devices to claim |
| hardwareAcceleration.dra.deviceClassName | string | `""` | DeviceClass to claim from, e.g. gpu.nvidia.com |
| hardwareAcceleration.dra.selectors | list | `[]` | CEL selectors picking a specific device. Without one, any device in the class is eligible. |
| hardwareAcceleration.hostDevice.path | string | `"/dev/dri"` | Device path bind-mounted into the container |
| hardwareAcceleration.hostDevice.privileged | bool | `true` | Run the container privileged, which is what makes the device usable |
| hardwareAcceleration.mode | string | `"none"` | One of `none`, `hostDevice`, `devicePlugin` or `dra` |
| hostAliases | list | `[]` | Host aliases |
| httpRoute.annotations | object | `{}` | HTTPRoute annotations |
| httpRoute.enabled | bool | `false` | Create an HTTPRoute (Gateway API) |
| httpRoute.hostnames | list | `[]` | Hostnames matched by the route |
| httpRoute.parentRefs | list | `[]` | Gateways this route attaches to |
| httpRoute.rules | list | `[]` | Route rules. A sensible default rule is generated when empty. |
| image.digest | string | `""` | Image digest. When set, takes precedence over `image.tag`. |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| image.repository | string | `"docker.io/jellyfin/jellyfin"` | Image repository. This is the image published by the Jellyfin project itself. |
| image.tag | string | `"10.11.11"` | Image tag. Pin this in production. |
| imagePullSecrets | list | `[]` | Image pull secrets |
| ingress.annotations | object | `{}` | Ingress annotations |
| ingress.className | string | `""` | IngressClass name |
| ingress.enabled | bool | `false` | Create an Ingress |
| ingress.hosts | list | `[{"host":"jellyfin.local","paths":[{"path":"/","pathType":"Prefix"}]}]` | Ingress hosts |
| ingress.tls | list | `[]` | Ingress TLS configuration |
| livenessProbe | object | `{"enabled":true,"failureThreshold":3,"httpGet":{"path":"/health","port":"http"},"initialDelaySeconds":0,"periodSeconds":10,"timeoutSeconds":5}` | Liveness probe against `/health` |
| nameOverride | string | `""` | Override the chart name portion of resource names |
| networkPolicy.egress | list | `[]` | Egress rules. When empty, no egress restrictions are applied. |
| networkPolicy.enabled | bool | `false` | Create a NetworkPolicy |
| networkPolicy.ingress | list | `[]` | Ingress rules. When empty, all ingress to the service port is allowed. |
| nodeSelector | object | `{}` | Node selector |
| persistence.cache.accessMode | string | `"ReadWriteOnce"` | Access mode |
| persistence.cache.annotations | object | `{}` | Annotations for the cache PVC |
| persistence.cache.enabled | bool | `true` | Persist Jellyfin's cache directory |
| persistence.cache.existingClaim | string | `""` | Use an existing PVC instead of creating one |
| persistence.cache.mountPath | string | `"/cache"` | Mount path. Becomes JELLYFIN_CACHE_DIR, and transcodes land under it. |
| persistence.cache.size | string | `"64Gi"` | Size of the cache volume |
| persistence.cache.storageClass | string | `""` | StorageClass |
| persistence.config.accessMode | string | `"ReadWriteOnce"` | Access mode |
| persistence.config.annotations | object | `{}` | Annotations for the config PVC |
| persistence.config.enabled | bool | `true` | Persist Jellyfin's data directory |
| persistence.config.existingClaim | string | `""` | Use an existing PVC instead of creating one |
| persistence.config.mountPath | string | `"/config"` | Mount path. Becomes JELLYFIN_DATA_DIR, with the settings in `<mountPath>/config` and logs in `<mountPath>/log`. |
| persistence.config.retain | bool | `false` | Keep the PVC when the release is uninstalled |
| persistence.config.size | string | `"32Gi"` | Size of the config volume |
| persistence.config.storageClass | string | `""` | StorageClass. Falls back to `global.storageClass`, then the cluster default. |
| persistence.media.accessMode | string | `"ReadWriteMany"` | Access mode |
| persistence.media.annotations | object | `{}` | Annotations for the media PVC |
| persistence.media.enabled | bool | `false` | Mount the shared media volume. Read-only by default. |
| persistence.media.existingClaim | string | `""` | Use an existing PVC. Required when `enabled` is true and `size` is unset. |
| persistence.media.mountPath | string | `"/data"` | Mount path for the media volume |
| persistence.media.readOnly | bool | `true` | Mount the media volume read-only |
| persistence.media.retain | bool | `true` | Keep the PVC when the release is uninstalled. On by default: it holds the library. |
| persistence.media.size | string | `""` | Size, when the chart creates the volume |
| persistence.media.storageClass | string | `""` | StorageClass |
| podAnnotations | object | `{}` | Annotations for the pod |
| podDisruptionBudget.enabled | bool | `false` | Create a PodDisruptionBudget |
| podDisruptionBudget.maxUnavailable | int | `1` | Maximum unavailable pods |
| podDisruptionBudget.minAvailable | string | `""` | Minimum available pods |
| podLabels | object | `{}` | Labels for the pod |
| podSecurityContext | object | `{"fsGroup":1000,"fsGroupChangePolicy":"OnRootMismatch","runAsGroup":1000,"runAsUser":1000,"seccompProfile":{"type":"RuntimeDefault"},"supplementalGroups":[]}` | Pod-level security context |
| priorityClassName | string | `""` | Priority class name |
| readinessProbe | object | `{"enabled":true,"failureThreshold":3,"httpGet":{"path":"/health","port":"http"},"initialDelaySeconds":0,"periodSeconds":10,"timeoutSeconds":5}` | Readiness probe |
| replicaCount | int | `1` | Number of replicas. Must be 1. |
| resources | object | `{"limits":{"memory":"4Gi"},"requests":{"cpu":"100m","memory":"512Mi"}}` | Resource requests and limits |
| runtimeClassName | string | `""` | Runtime class name. Set to `nvidia` if your cluster needs the NVIDIA container runtime selected explicitly. |
| securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":false,"runAsNonRoot":true}` | Container-level security context |
| service.annotations | object | `{}` | Service annotations |
| service.clusterIP | string | `""` | Static cluster IP |
| service.labels | object | `{}` | Service labels |
| service.loadBalancerIP | string | `""` | Load balancer IP, when `service.type` is LoadBalancer |
| service.nodePort | string | `""` | Node port, when `service.type` is NodePort |
| service.port | int | `8096` | Service port. The container always listens on 8096. |
| service.sessionAffinity | string | `""` | Session affinity |
| service.type | string | `"ClusterIP"` | Service type |
| serviceAccount.annotations | object | `{}` | Annotations for the ServiceAccount |
| serviceAccount.automount | bool | `false` | Mount the ServiceAccount API token. Not needed; nothing here uses the Kubernetes API. |
| serviceAccount.create | bool | `true` | Create a ServiceAccount |
| serviceAccount.name | string | `""` | Name of the ServiceAccount to use. Generated from the fullname when empty. |
| startupProbe | object | `{"enabled":true,"failureThreshold":60,"httpGet":{"path":"/health","port":"http"},"initialDelaySeconds":10,"periodSeconds":10,"timeoutSeconds":5}` | Startup probe. Generous; a first scan of a large library takes a while. |
| terminationGracePeriodSeconds | int | `30` | Termination grace period in seconds |
| tolerations | list | `[]` | Tolerations |
| topologySpreadConstraints | list | `[]` | Topology spread constraints |
| updateStrategy | object | `{"type":"Recreate"}` | Deployment strategy |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
