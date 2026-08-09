# arr-stack

![Version: 0.1.14](https://img.shields.io/badge/Version-0.1.14-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.1.0](https://img.shields.io/badge/AppVersion-0.1.0-informational?style=flat-square)

Complete media automation stack — media server, *arrs, download client, requests and maintenance, wired together

**Homepage:** <https://github.com/behappiness/arr-k8s-stack-helm>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Botond Lovasz | <botilovasz@gmail.com> |  |

## Source Code

* <https://github.com/behappiness/arr-k8s-stack-helm>

## Requirements

Kubernetes: `>=1.25.0-0`

| Repository | Name | Version |
|------------|------|---------|
| file://../autobrr | autobrr | >=0.1.0 |
| file://../bazarr | bazarr | >=0.1.0 |
| file://../cleanuparr | cleanuparr | >=0.1.0 |
| file://../emby | emby | >=0.1.0 |
| file://../flaresolverr | flaresolverr | >=0.1.0 |
| file://../jellyfin | jellyfin | >=0.1.0 |
| file://../lidarr | lidarr | >=0.1.0 |
| file://../maintainerr | maintainerr | >=0.1.0 |
| file://../plex | plex | >=0.1.0 |
| file://../profilarr | profilarr | >=0.1.0 |
| file://../prowlarr | prowlarr | >=0.1.0 |
| file://../qbittorrent | qbittorrent | >=0.1.0 |
| file://../radarr | radarr | >=0.1.0 |
| file://../samba | samba | >=0.1.0 |
| file://../scraparr | scraparr | >=0.1.0 |
| file://../seerr | seerr | >=0.1.0 |
| file://../sonarr | sonarr | >=0.1.0 |
| file://../suggestarr | suggestarr | >=0.1.0 |
| file://../tautulli | tautulli | >=0.1.0 |
| file://../tracearr | tracearr | >=0.1.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| autobrr.enabled | bool | `true` |  |
| bazarr.enabled | bool | `true` |  |
| bazarr.persistence.media.enabled | bool | `true` |  |
| bazarr.persistence.media.existingClaim | string | `"arr-stack-media"` |  |
| bazarr.persistence.media.mountPath | string | `"/data"` |  |
| cleanuparr.enabled | bool | `true` |  |
| cleanuparr.persistence.media.enabled | bool | `true` |  |
| cleanuparr.persistence.media.existingClaim | string | `"arr-stack-media"` |  |
| cleanuparr.persistence.media.mountPath | string | `"/data"` |  |
| emby.enabled | bool | `false` |  |
| emby.persistence.media.enabled | bool | `true` |  |
| emby.persistence.media.existingClaim | string | `"arr-stack-media"` |  |
| emby.persistence.media.mountPath | string | `"/data"` |  |
| emby.persistence.media.readOnly | bool | `true` |  |
| flaresolverr.enabled | bool | `true` |  |
| fullnameOverride | string | `""` | Override the fully qualified app name used for resource names |
| global.storageClass.cache | string | `""` | Transcode scratch and image cache for the media servers |
| global.storageClass.config | string | `""` | Application config and databases |
| global.storageClass.default | string | `""` | Fallback for any purpose left empty below |
| global.storageClass.media | string | `""` | The shared media library |
| jellyfin | object | `{"enabled":true,"persistence":{"media":{"enabled":true,"existingClaim":"arr-stack-media","mountPath":"/data","readOnly":true}}}` | ------------------------------------------------------------------------- Media servers. |
| lidarr.enabled | bool | `false` |  |
| lidarr.persistence.media.enabled | bool | `true` |  |
| lidarr.persistence.media.existingClaim | string | `"arr-stack-media"` |  |
| lidarr.persistence.media.mountPath | string | `"/data"` |  |
| maintainerr.enabled | bool | `true` |  |
| media.accessMode | string | `"ReadWriteMany"` | Access mode. ReadWriteMany unless every pod lands on the same node. |
| media.claimName | string | `"arr-stack-media"` | Name of the shared claim. The per-application blocks below reference it literally, so change both together. |
| media.createLayout | bool | `true` | Create the directory layout |
| media.enabled | bool | `true` | Provision the shared media volume. Disable only if you set `media.existingClaim`. |
| media.existingClaim | string | `""` | Use an existing PVC |
| media.extraDirectories | list | `[]` | Extra directories to create, relative to `mountPath` |
| media.layoutImage.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| media.layoutImage.repository | string | `"docker.io/library/busybox"` | Image for the layout Job. Only needs a shell. |
| media.layoutImage.tag | string | `"1.38"` | Image tag |
| media.layoutSecurityContext | object | `{"fsGroup":1000,"fsGroupChangePolicy":"OnRootMismatch","runAsGroup":1000,"runAsNonRoot":true,"runAsUser":1000,"seccompProfile":{"type":"RuntimeDefault"}}` | Pod security context for the layout Job |
| media.mountPath | string | `"/data"` | Mount path, identical in every application |
| media.retain | bool | `true` | Keep the PVC when the release is uninstalled. Strongly recommended. |
| media.size | string | `"2Ti"` | Size of the volume, when this chart creates it |
| media.storageClass | string | `""` | StorageClass. Falls back to `global.storageClass`. |
| nameOverride | string | `""` | Override the chart name portion of resource names |
| plex.enabled | bool | `false` |  |
| plex.persistence.media.enabled | bool | `true` |  |
| plex.persistence.media.existingClaim | string | `"arr-stack-media"` |  |
| plex.persistence.media.mountPath | string | `"/data"` |  |
| plex.persistence.media.readOnly | bool | `true` |  |
| profilarr.enabled | bool | `true` |  |
| prowlarr.enabled | bool | `true` |  |
| qbittorrent.enabled | bool | `true` |  |
| qbittorrent.persistence.media.enabled | bool | `true` |  |
| qbittorrent.persistence.media.existingClaim | string | `"arr-stack-media"` |  |
| qbittorrent.persistence.media.mountPath | string | `"/data"` |  |
| qbittorrent.vpn.mode | string | `"none"` |  |
| radarr.enabled | bool | `true` |  |
| radarr.persistence.media.enabled | bool | `true` |  |
| radarr.persistence.media.existingClaim | string | `"arr-stack-media"` |  |
| radarr.persistence.media.mountPath | string | `"/data"` |  |
| samba.auth.existingSecret | string | `""` |  |
| samba.auth.password | string | `""` |  |
| samba.auth.username | string | `"media"` |  |
| samba.enabled | bool | `false` |  |
| samba.persistence.media.enabled | bool | `true` |  |
| samba.persistence.media.existingClaim | string | `"arr-stack-media"` |  |
| samba.persistence.media.mountPath | string | `"/shares/media"` |  |
| samba.service.type | string | `"LoadBalancer"` |  |
| samba.share.name | string | `"media"` |  |
| samba.share.readOnly | bool | `true` |  |
| scraparr.config.instances | object | `{}` |  |
| scraparr.enabled | bool | `false` |  |
| seerr.enabled | bool | `true` |  |
| sonarr.enabled | bool | `true` |  |
| sonarr.persistence.media.enabled | bool | `true` |  |
| sonarr.persistence.media.existingClaim | string | `"arr-stack-media"` |  |
| sonarr.persistence.media.mountPath | string | `"/data"` |  |
| suggestarr.enabled | bool | `false` |  |
| tautulli.enabled | bool | `false` |  |
| tracearr.config.databaseUrl | string | `""` |  |
| tracearr.config.redisUrl | string | `""` |  |
| tracearr.enabled | bool | `false` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
