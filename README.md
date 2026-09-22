# arr-k8s-stack-helm

Helm charts for a media automation stack on Kubernetes.

- **21 application charts** under [`charts/`](charts/), each installable on its own.
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

**Off:** lidarr, plex, emby, tautulli, suggestarr, samba, metube, and two that need something you
have to supply — tracearr (PostgreSQL and Redis) and scraparr (a config.yaml listing your \*arrs)

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
    cache: ""      # 64Gi, media servers
```

The media claim must be the same claim, at the same path, in every application, with no `subPath`.
Hardlinks only work within one filesystem and mount point, so a split claim, a differing
`mountPath` or a `subPath` turns every import into a full copy at twice the disk cost. That failure
is silent — imports keep working, they just stop being hardlinks — so the umbrella refuses to
render instead.

A post-install Job creates the layout (`media.createLayout`, on by default), making only the
directories the enabled applications need:

```
/data
├── media/
│   ├── movies/              radarr
│   ├── tv/                  sonarr
│   ├── music/               lidarr
│   └── youtube/             metube
├── torrents/
│   ├── {movies,tv,music}/   qbittorrent, one per *arr category
│   └── unlinked/            cleanuparr parks a torrent here when its import
│                            is deleted, so the seed outlives the library file
└── downloads/               anything grabbed outside an *arr category
```

Add to it with `media.extraDirectories`. Setting the root folders and qBittorrent's save path is
still yours to do — the charts deploy the applications and do not configure them.

## Resources

Every chart requests what its application uses at rest and is limited to its realistic peak. No
chart sets a CPU limit — throttling an import or a transcode only makes it slower.

The default stack requests **1050m CPU and 4.5Gi memory** across 12 containers. Memory limits are
per workload: 4Gi for the media servers and qBittorrent, 2Gi where memory tracks the size of the
library (sonarr, radarr, lidarr, bazarr), a headless browser (flaresolverr) or an ffmpeg remux
(metube), 512Mi–1Gi for the rest.

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

Gateway API is the alternative, as `httpRoute`. Both can be enabled at once. It takes Gateway's own
shape rather than Ingress's — `parentRefs` for the gateways to attach to, `hostnames` to match, and
`rules` only if the generated default does not suit:

```yaml
sonarr:
  httpRoute:
    enabled: true
    parentRefs:
      - name: gateway
        namespace: gateway-system
    hostnames:
      - sonarr.example.com
```

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

## Downloading from the web

MeTube is a web UI for yt-dlp. It is the one download path here that no \*arr manages, so nothing
else in the stack depends on it and it is off by default.

Its output is not imported the way a torrent is — it is written where it stays — so the files land
in the library rather than a scratch directory. `media/youtube` sits beside `media/tv` and
`media/movies` on the same claim, which means a media server already mounting it indexes the
downloads as another library with no extra configuration.

```yaml
metube:                                 # the subchart
  enabled: true
  metube:                               # its own settings block
    downloadDir: /data/media/youtube    # the umbrella's default
    ytdlOptions:
      format: bestvideo[height<=1080]+bestaudio/best
```

Two things the chart refuses to render rather than let you find out later. A `downloadDir` on no
mounted volume: MeTube writes to the container's writable layer, reports every download complete,
and loses them all on the next restart. And a `tempDir` on a different filesystem from
`downloadDir`, which turns the finishing move from a rename into a full copy of the finished file —
twice the space, and as long again as the download took. Leaving `tempDir` empty keeps partial files
beside the finished ones, which is always safe.

To serve it under a sub-path, set `metube.urlPrefix` (`/metube/`, slashes included) and leave the
prefix in place at your proxy. MeTube serves the UI only at the prefix and 404s at the root, so the
probes follow it automatically.

## Metrics

Scraparr scrapes every \*arr from one pod, reading a `config.yaml` that names them. Put it in a
Secret rather than your values: it holds an API key per application.

```yaml
scraparr:
  enabled: true
  config:
    existingSecret: scraparr-config   # a Secret with a config.yaml key
  serviceMonitor:
    enabled: true
```

qBittorrent's exporter runs as a sidecar and logs in over the loopback address, so it needs an
account. One Secret carries both halves, under the keys `username` and `password`.

```yaml
qbittorrent:
  metrics:
    enabled: true
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
