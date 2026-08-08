# qbittorrent

![Version: 0.1.1](https://img.shields.io/badge/Version-0.1.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 5.2.3-1](https://img.shields.io/badge/AppVersion-5.2.3--1-informational?style=flat-square)

BitTorrent client with a web UI, with optional VPN confinement and Prometheus metrics

**Homepage:** <https://www.qbittorrent.org>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Botond Lovasz | <botilovasz@gmail.com> |  |

## Source Code

* <https://github.com/qbittorrent/qBittorrent>
* <https://github.com/qbittorrent/docker-qbittorrent-nox>

## Requirements

Kubernetes: `>=1.25.0-0`

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity rules |
| commonAnnotations | object | `{}` | Additional annotations applied to every resource in the chart |
| commonLabels | object | `{}` | Additional labels applied to every resource in the chart |
| config.acceptLegalNotice | bool | `true` | Confirm you have read qBittorrent's legal notice |
| config.torrentingPort | int | `6881` | Peer listen port, published on the Service (TCP and UDP) |
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
| image.repository | string | `"docker.io/qbittorrentofficial/qbittorrent-nox"` | Image repository. This is qBittorrent's own official image, published by the qBittorrent project itself. |
| image.tag | string | `"5.2.3-1"` | Image tag. Pin this in production. |
| imagePullSecrets | list | `[]` | Image pull secrets |
| ingress.annotations | object | `{}` | Ingress annotations |
| ingress.className | string | `""` | IngressClass name |
| ingress.enabled | bool | `false` | Create an Ingress |
| ingress.hosts | list | `[{"host":"qbittorrent.local","paths":[{"path":"/","pathType":"Prefix"}]}]` | Ingress hosts |
| ingress.tls | list | `[]` | Ingress TLS configuration |
| livenessProbe | object | `{"enabled":true,"failureThreshold":3,"httpGet":{"path":"/","port":"http"},"initialDelaySeconds":0,"periodSeconds":10,"timeoutSeconds":5}` | Liveness probe. qBittorrent has no health endpoint; the root path serves the web UI and answers before authentication. |
| metrics.enabled | bool | `false` | Run the metrics exporter sidecar |
| metrics.existingSecret | string | `""` | Name of an existing Secret holding the exporter's qBittorrent password |
| metrics.existingSecretKey | string | `"password"` | Key within `existingSecret` |
| metrics.image.pullPolicy | string | `"IfNotPresent"` | Exporter image pull policy |
| metrics.image.repository | string | `"ghcr.io/esanchezm/prometheus-qbittorrent-exporter"` | Exporter image repository |
| metrics.image.tag | string | `"v1.7.0"` | Exporter image tag |
| metrics.password | string | `""` | qBittorrent password. Prefer `existingSecret`. |
| metrics.port | int | `8090` | Port the exporter listens on. Not 8000: with `vpn.mode: gluetun` the sidecars share a network namespace and gluetun's control server has that. |
| metrics.resources | object | `{"limits":{"memory":"256Mi"},"requests":{"cpu":"10m","memory":"64Mi"}}` | Resources for the exporter container |
| metrics.serviceMonitor.enabled | bool | `false` | Create a ServiceMonitor for the exporter. Requires the Prometheus Operator CRDs. |
| metrics.serviceMonitor.interval | string | `"60s"` | Scrape interval |
| metrics.serviceMonitor.labels | object | `{}` | Additional labels for the ServiceMonitor, for Prometheus selectors |
| metrics.serviceMonitor.metricRelabelings | list | `[]` | Metric relabel configurations |
| metrics.serviceMonitor.relabelings | list | `[]` | Relabel configurations |
| metrics.serviceMonitor.scrapeTimeout | string | `"30s"` | Scrape timeout |
| metrics.username | string | `""` | qBittorrent username the exporter authenticates with |
| nameOverride | string | `""` | Override the chart name portion of resource names |
| networkPolicy.egress | list | `[]` | Egress rules. When empty, no egress restrictions are applied. |
| networkPolicy.enabled | bool | `false` | Create a NetworkPolicy |
| networkPolicy.ingress | list | `[]` | Ingress rules. When empty, all ingress to the service port is allowed. |
| nodeSelector | object | `{}` | Node selector |
| persistence.config.accessMode | string | `"ReadWriteOnce"` | Access mode for the config volume |
| persistence.config.annotations | object | `{}` | Annotations for the config PVC |
| persistence.config.enabled | bool | `true` | Persist qBittorrent's configuration directory (`/config`) |
| persistence.config.existingClaim | string | `""` | Use an existing PVC instead of creating one |
| persistence.config.retain | bool | `false` | Keep the PVC when the release is uninstalled |
| persistence.config.size | string | `"1Gi"` | Size of the config volume |
| persistence.config.storageClass | string | `""` | StorageClass. Falls back to `global.storageClass`, then the cluster default. |
| persistence.media.accessMode | string | `"ReadWriteMany"` | Access mode for the media volume |
| persistence.media.annotations | object | `{}` | Annotations for the media PVC |
| persistence.media.enabled | bool | `false` | Mount the shared media volume. Must be the same claim and path as the other applications use. |
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
| securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":false,"runAsGroup":1000,"runAsNonRoot":true,"runAsUser":1000}` | Container-level security context |
| service.annotations | object | `{}` | Service annotations |
| service.clusterIP | string | `""` | Static cluster IP |
| service.labels | object | `{}` | Service labels |
| service.loadBalancerIP | string | `""` | Load balancer IP, when `service.type` is LoadBalancer |
| service.nodePort | string | `""` | Node port, when `service.type` is NodePort |
| service.port | int | `8080` | Service port |
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
| vpn.gluetun.env | object | `{"VPN_SERVICE_PROVIDER":"custom","VPN_TYPE":"wireguard"}` | Environment for gluetun. Never put credentials here; use `envFrom`. |
| vpn.gluetun.envFrom | list | `[]` | envFrom sources for gluetun. This is where credentials belong. |
| vpn.gluetun.image.pullPolicy | string | `"IfNotPresent"` | gluetun image pull policy |
| vpn.gluetun.image.repository | string | `"ghcr.io/qdm12/gluetun"` | gluetun image repository |
| vpn.gluetun.image.tag | string | `"v3.41.3"` | gluetun image tag |
| vpn.gluetun.resources | object | `{"limits":{"memory":"256Mi"},"requests":{"cpu":"25m","memory":"64Mi"}}` | Resources for the gluetun container |
| vpn.lanNetworks | list | `[]` | Networks kept reachable outside the tunnel |
| vpn.mode | string | `"none"` | VPN mode: `none` or `gluetun` |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
