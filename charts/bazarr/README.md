# bazarr

![Version: 0.1.4](https://img.shields.io/badge/Version-0.1.4-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v1.6.0-ls359](https://img.shields.io/badge/AppVersion-v1.6.0--ls359-informational?style=flat-square)

Subtitle manager for Sonarr and Radarr — finds and downloads subtitles for your library

**Homepage:** <https://www.bazarr.media>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Botond Lovasz | <botilovasz@gmail.com> |  |

## Source Code

* <https://github.com/Bazarr/Bazarr>
* <https://github.com/linuxserver/docker-bazarr>

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
| env.PGID | int | `1000` | GID the application drops to |
| env.PUID | int | `1000` | UID the application drops to |
| env.TZ | string | `"Etc/UTC"` | Timezone. Ignored if a webhook like k8tz injects one. |
| env.UMASK | string | `"002"` | Umask. `002` keeps files group-writable so the other apps can use them. |
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
| image.repository | string | `"lscr.io/linuxserver/bazarr"` | Image repository |
| image.tag | string | `"v1.6.0-ls359"` | Image tag. Pin this in production. |
| imagePullSecrets | list | `[]` | Image pull secrets |
| ingress.annotations | object | `{}` | Ingress annotations |
| ingress.className | string | `""` | IngressClass name |
| ingress.enabled | bool | `false` | Create an Ingress |
| ingress.hosts | list | `[{"host":"bazarr.local","paths":[{"path":"/","pathType":"Prefix"}]}]` | Ingress hosts |
| ingress.tls | list | `[]` | Ingress TLS configuration |
| livenessProbe | object | `{"enabled":true,"failureThreshold":3,"httpGet":{"path":"/","port":"http"},"initialDelaySeconds":0,"periodSeconds":10,"timeoutSeconds":5}` | Liveness probe. Bazarr has no dedicated health endpoint; the root path serves the UI and answers without authentication. |
| nameOverride | string | `""` | Override the chart name portion of resource names |
| networkPolicy.egress | list | `[]` | Egress rules. When empty, no egress restrictions are applied. |
| networkPolicy.enabled | bool | `false` | Create a NetworkPolicy |
| networkPolicy.ingress | list | `[]` | Ingress rules. When empty, all ingress to the service port is allowed. |
| nodeSelector | object | `{}` | Node selector |
| persistence.config.accessMode | string | `"ReadWriteOnce"` | Access mode for the config volume |
| persistence.config.annotations | object | `{}` | Annotations for the config PVC |
| persistence.config.enabled | bool | `true` | Persist Bazarr's configuration directory (`/config`) |
| persistence.config.existingClaim | string | `""` | Use an existing PVC instead of creating one |
| persistence.config.retain | bool | `false` | Keep the PVC when the release is uninstalled |
| persistence.config.size | string | `"1Gi"` | Size of the config volume |
| persistence.config.storageClass | string | `""` | StorageClass. Falls back to `global.storageClass`, then the cluster default. |
| persistence.media.accessMode | string | `"ReadWriteMany"` | Access mode for the media volume |
| persistence.media.annotations | object | `{}` | Annotations for the media PVC |
| persistence.media.enabled | bool | `false` | Mount the shared media volume.  Bazarr writes subtitle files next to the media files, so this must be the same volume, mounted at the same path, as Sonarr and Radarr use. A mismatched path means Bazarr cannot find the files the *arrs report. |
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
| resources | object | `{"limits":{"memory":"2Gi"},"requests":{"cpu":"50m","memory":"256Mi"}}` | Resource requests and limits |
| runtimeClassName | string | `""` | Runtime class name |
| securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"add":["CHOWN","SETUID","SETGID","DAC_OVERRIDE","FOWNER"],"drop":["ALL"]},"readOnlyRootFilesystem":false,"runAsUser":0}` | Container-level security context |
| service.annotations | object | `{}` | Service annotations |
| service.clusterIP | string | `""` | Static cluster IP |
| service.labels | object | `{}` | Service labels |
| service.loadBalancerIP | string | `""` | Load balancer IP, when `service.type` is LoadBalancer |
| service.nodePort | string | `""` | Node port, when `service.type` is NodePort |
| service.port | int | `6767` | Service port. The container always listens on 6767. |
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
