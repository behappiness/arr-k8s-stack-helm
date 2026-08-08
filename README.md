# arr-k8s-stack-helm

Helm charts for a media automation stack on Kubernetes.

- **20 application charts** under [`charts/`](charts/), each installable on its own.
- **[`charts/arr-stack`](charts/arr-stack/)** deploys them together, sharing one media volume.

The charts deploy the applications and stop there. Nothing is configured for you: each application
comes up with its own defaults and you set it up in its own web UI.

## Install

```console
helm repo add arr-stack https://behappiness.github.io/arr-k8s-stack-helm
helm install media arr-stack/arr-stack -n media --create-namespace \
  --set media.existingClaim=my-media-pvc
```

Over OCI:

```console
helm install media oci://ghcr.io/behappiness/charts/arr-stack -n media --create-namespace
```

A single application:

```console
helm install sonarr arr-stack/sonarr
```

From a checkout:

```console
helm dependency update charts/arr-stack
helm install media charts/arr-stack -n media --create-namespace
```

## Applications

Toggle with `<name>.enabled`.

**On:** jellyfin, seerr, sonarr, radarr, prowlarr, bazarr, qbittorrent, flaresolverr, cleanuparr,
maintainerr, profilarr, autobrr

**Off:** lidarr, plex, emby, tautulli, suggestarr, samba, and two that need something you have to
supply — tracearr (PostgreSQL and Redis) and scraparr (a config.yaml listing your \*arrs)

`samba` shares the media volume over SMB with a password. NFS is the alternative, but NFSv4 has no
username/password: it trusts whatever UID the client claims, so its only access control is the
client IP.

Values for each are documented in its own README, for example
[charts/sonarr](charts/sonarr/README.md). Anything a chart documents can be set under its name:

```yaml
sonarr:
  config:
    instanceName: TV
  resources:
    limits:
      memory: 2Gi
```

## Storage

```yaml
media:
  existingClaim: my-media-pvc
  mountPath: /data

global:
  storageClass:
    default: ""
    config: ""     # 1Gi per app, 32Gi for Jellyfin
    media: ""      # 2Ti
    cache: ""      # 64Gi, Jellyfin
```

The media claim must be the same claim, at the same path, in every application, with no `subPath`.
Create this layout yourself and point each application at it:

```
/data
├── torrents/{movies,tv,music}
└── media/{movies,tv,music}
```

## Resources

Every chart requests what its application uses at rest and is limited to its realistic peak. No
chart sets a CPU limit — throttling an import or a transcode only makes it slower.

The default stack requests **675m CPU and 3.5Gi memory**. Memory limits are per workload: 4Gi for
the media servers, 2Gi where memory tracks the size of the library (sonarr, radarr, lidarr, bazarr,
qbittorrent) or a headless browser (flaresolverr), 512Mi–1Gi for the rest.

Raise a limit if you run a large library or several transcodes at once:

```yaml
jellyfin:
  resources:
    limits:
      memory: 8Gi
```

## Ingress

```yaml
sonarr:
  ingress:
    enabled: true
    className: traefik
    hosts:
      - host: sonarr.example.com
        paths:
          - path: /
            pathType: Prefix
```

Gateway API is available as `httpRoute` with the same shape.

## Hardware transcoding

Jellyfin, Plex and Emby take a `hardwareAcceleration` block:

```yaml
jellyfin:
  hardwareAcceleration:
    mode: hostDevice      # none | hostDevice | devicePlugin | dra
    hostDevice:
      path: /dev/dri
```

`hostDevice` runs the container privileged. A hostPath supplies the device inode, but opening it is
gated by the runtime's device cgroup, which nothing else opens — without it every `open()` returns
EPERM and ffmpeg reports no usable render device. Use `devicePlugin` if you would rather not run
privileged.

```yaml
plex:
  hardwareAcceleration:
    mode: dra
    dra:
      deviceClassName: gpu.nvidia.com
      selectors:
        - device.attributes["gpu.nvidia.com"].productName == "NVIDIA GeForce RTX 3060"
```

`hostDevice` and the VPN sidecar mount a hostPath or need `NET_ADMIN`, which the Pod Security
Standards `baseline` profile forbids. Label the namespace before installing:

```console
kubectl create namespace media
kubectl label namespace media pod-security.kubernetes.io/enforce=privileged
```

The chart cannot do this for you: Helm needs the release namespace to exist before it can store the
release, so a Namespace it renders itself would always collide. The umbrella checks the real label
at install time and refuses to install without it.

## VPN

```yaml
qbittorrent:
  vpn:
    mode: gluetun         # none | gluetun
    lanNetworks:
      - 10.0.0.0/8
    gluetun:
      env:
        VPN_SERVICE_PROVIDER: mullvad
      envFrom:
        - secretRef:
            name: gluetun-credentials
```

## Metrics

Scraparr needs a `config.yaml` naming your \*arrs and their API keys; supply it with
`extraVolumes`/`extraVolumeMounts`. qBittorrent's exporter needs its web UI credentials.

```yaml
qbittorrent:
  metrics:
    enabled: true
    username: admin
    existingSecret: qbittorrent-credentials
    serviceMonitor:
      enabled: true
```

## Requirements

- Kubernetes 1.25+ (1.34+ for `hardwareAcceleration.mode: dra`)
- Helm 3.8+ or Helm 4
- A `ReadWriteMany` volume for the media library, unless every pod runs on one node

## Development

```console
helm lint charts/<name>
helm template <name> charts/<name> -f charts/<name>/ci/minimal-values.yaml
helm-docs --chart-search-root=charts --document-dependency-values=false
```

Charts are versioned independently. `charts/sonarr` is the reference for new charts.

## Licence

Apache-2.0. See [LICENSE](LICENSE).
