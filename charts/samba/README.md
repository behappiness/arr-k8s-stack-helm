# samba

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 4.23.8](https://img.shields.io/badge/AppVersion-4.23.8-informational?style=flat-square)

SMB file server sharing the media volume, with per-user authentication

**Homepage:** <https://www.samba.org>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Botond Lovasz | <botilovasz@gmail.com> |  |

## Source Code

* <https://github.com/ServerContainers/samba>
* <https://gitlab.com/samba-team/samba>

## Requirements

Kubernetes: `>=1.25.0-0`

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity rules |
| auth.existingSecret | string | `""` | Name of a Secret holding the accounts. Keys: `ACCOUNT_<user>` with the password, and optionally `UID_<user>` with the id that user's files are written as. When empty, the chart creates one from the values below. |
| auth.password | string | `""` | Password for the chart-created Secret. A value here ends up in the release manifest; prefer `existingSecret`. |
| auth.uid | int | `1000` | UID and GID the user maps to |
| auth.username | string | `"media"` | Username for the chart-created Secret |
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
| extraEnvRaw | list | `[]` | Additional environment variables in raw format, for `valueFrom` |
| extraGlobalConfig | object | `{}` | Extra global smb.conf settings, as a map of setting name to value. Rendered as `SAMBA_GLOBAL_CONFIG_*`. |
| extraInitContainers | list | `[]` | Additional init containers |
| extraVolumeMounts | list | `[]` | Additional volume mounts for the main container |
| extraVolumes | list | `[]` | Additional volumes |
| fullnameOverride | string | `""` | Override the fully qualified app name used for resource names |
| hostAliases | list | `[]` | Host aliases |
| image.digest | string | `""` | Image digest. When set, takes precedence over `image.tag`. |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| image.repository | string | `"ghcr.io/servercontainers/samba"` | Image repository |
| image.tag | string | `"smbd-only-a3.24.1-s4.23.8-r0"` | Image tag. Pin this in production. |
| imagePullSecrets | list | `[]` | Image pull secrets |
| livenessProbe | object | `{"enabled":true,"failureThreshold":3,"initialDelaySeconds":10,"periodSeconds":20,"tcpSocket":{"port":"smb"},"timeoutSeconds":5}` | Liveness probe. Samba answers a TCP connect on 445 once smbd is up. |
| nameOverride | string | `""` | Override the chart name portion of resource names |
| networkPolicy.egress | list | `[]` | Egress rules. When empty, no egress restrictions are applied. |
| networkPolicy.enabled | bool | `false` | Create a NetworkPolicy |
| networkPolicy.ingress | list | `[]` | Ingress rules. When empty, all ingress to the service port is allowed. |
| nodeSelector | object | `{}` | Node selector |
| persistence.media.accessMode | string | `"ReadWriteMany"` | Access mode for the media volume |
| persistence.media.annotations | object | `{}` | Annotations for the media PVC |
| persistence.media.enabled | bool | `false` | Mount the shared media volume. This is what gets shared. |
| persistence.media.existingClaim | string | `""` | Use an existing PVC. Required when `enabled` is true and `size` is unset. |
| persistence.media.mountPath | string | `"/shares/media"` | Mount path inside the container, and the share's path |
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
| readinessProbe | object | `{"enabled":true,"failureThreshold":3,"initialDelaySeconds":5,"periodSeconds":10,"tcpSocket":{"port":"smb"},"timeoutSeconds":5}` | Readiness probe |
| replicaCount | int | `1` | Number of replicas. Must be 1. |
| resources | object | `{"limits":{"memory":"1Gi"},"requests":{"cpu":"50m","memory":"128Mi"}}` | Resource requests and limits |
| runtimeClassName | string | `""` | Runtime class name |
| securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"add":["CHOWN","DAC_OVERRIDE","FOWNER","SETUID","SETGID","NET_BIND_SERVICE"],"drop":["ALL"]},"readOnlyRootFilesystem":false,"runAsUser":0}` | Container-level security context |
| service.annotations | object | `{}` | Service annotations |
| service.clusterIP | string | `""` | Static cluster IP |
| service.labels | object | `{}` | Service labels |
| service.loadBalancerIP | string | `""` | Load balancer IP, when `service.type` is LoadBalancer |
| service.nodePort | string | `""` | Node port, when `service.type` is NodePort |
| service.port | int | `445` | Service port. The container always listens on 445. |
| service.sessionAffinity | string | `""` | Session affinity |
| service.type | string | `"ClusterIP"` | Service type. LoadBalancer is the useful one: SMB clients live outside the cluster. |
| serviceAccount.annotations | object | `{}` | Annotations for the ServiceAccount |
| serviceAccount.automount | bool | `false` | Mount the ServiceAccount API token. Not needed; nothing here uses the Kubernetes API. |
| serviceAccount.create | bool | `true` | Create a ServiceAccount |
| serviceAccount.name | string | `""` | Name of the ServiceAccount to use. Generated from the fullname when empty. |
| share.browseable | bool | `true` | Show the share when browsing the server |
| share.name | string | `"media"` | Share name, the last part of `\\host\<name>` |
| share.readOnly | bool | `true` | Export the share read-only. On by default: a client that can delete files the *arrs believe they own causes confusing failures. |
| startupProbe | object | `{"enabled":true,"failureThreshold":30,"initialDelaySeconds":5,"periodSeconds":5,"tcpSocket":{"port":"smb"},"timeoutSeconds":5}` | Startup probe |
| terminationGracePeriodSeconds | int | `30` | Termination grace period in seconds |
| tolerations | list | `[]` | Tolerations |
| topologySpreadConstraints | list | `[]` | Topology spread constraints |
| updateStrategy | object | `{"type":"Recreate"}` | Deployment strategy. `Recreate` because one smbd owns the tdb databases. |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
