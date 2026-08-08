{{/*
Expand the name of the chart.
*/}}
{{- define "qbittorrent.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Fully qualified app name.
*/}}
{{- define "qbittorrent.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Chart name and version, as used by the helm.sh/chart label.
*/}}
{{- define "qbittorrent.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "qbittorrent.labels" -}}
helm.sh/chart: {{ include "qbittorrent.chart" . }}
{{ include "qbittorrent.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: arr-stack
{{- with .Values.commonLabels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels.
*/}}
{{- define "qbittorrent.selectorLabels" -}}
app.kubernetes.io/name: {{ include "qbittorrent.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
ServiceAccount name.
*/}}
{{- define "qbittorrent.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "qbittorrent.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Container image reference. A digest, when set, wins over the tag.
*/}}
{{- define "qbittorrent.image" -}}
{{- if .Values.image.digest }}
{{- printf "%s@%s" .Values.image.repository .Values.image.digest }}
{{- else }}
{{- printf "%s:%s" .Values.image.repository (default .Chart.AppVersion .Values.image.tag) }}
{{- end }}
{{- end }}

{{/*
Whether this chart needs to create a Secret of its own. qBittorrent keeps its
own credentials in qBittorrent.conf, so the only secret this chart may own is
the password the metrics exporter authenticates with.
*/}}
{{- define "qbittorrent.createSecret" -}}
{{- if and .Values.metrics.enabled (not .Values.metrics.existingSecret) .Values.metrics.password }}true{{- end }}
{{- end }}

{{/*
StorageClass for a persistence block.

Order: the volume's own `storageClass`, then `global.storageClass.<purpose>`,
then `global.storageClass.default`. `global.storageClass` may also be a plain
string, which applies to every purpose.
*/}}
{{- define "qbittorrent.storageClass" -}}
{{- $global := (.global | default dict).storageClass -}}
{{- $fromGlobal := "" -}}
{{- if kindIs "string" $global -}}
{{- $fromGlobal = $global -}}
{{- else if kindIs "map" $global -}}
{{- $fromGlobal = dig .purpose "" $global -}}
{{- if not $fromGlobal }}{{- $fromGlobal = dig "default" "" $global -}}{{- end }}
{{- end -}}
{{- $storageClass := .persistence.storageClass | default $fromGlobal -}}
{{- if $storageClass }}
{{- if eq "-" $storageClass }}
storageClassName: ""
{{- else }}
storageClassName: {{ $storageClass | quote }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Name of the config PVC.
*/}}
{{- define "qbittorrent.configClaimName" -}}
{{- if .Values.persistence.config.existingClaim }}
{{- .Values.persistence.config.existingClaim }}
{{- else }}
{{- printf "%s-config" (include "qbittorrent.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Name of the media PVC.
*/}}
{{- define "qbittorrent.mediaClaimName" -}}
{{- if .Values.persistence.media.existingClaim }}
{{- .Values.persistence.media.existingClaim }}
{{- else }}
{{- printf "%s-media" (include "qbittorrent.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Value validation.
*/}}
{{- define "qbittorrent.validateValues" -}}
{{- if not .Values.config.acceptLegalNotice }}
{{- fail "qbittorrent: config.acceptLegalNotice is false. The official qBittorrent image refuses to start without it, so the pod would never become ready." }}
{{- end }}
{{- if gt (int .Values.replicaCount) 1 }}
{{- fail "qbittorrent: replicaCount must be 1. qBittorrent is a single-instance application backed by an RWO volume; running multiple replicas corrupts its database." }}
{{- end }}
{{- if and .Values.persistence.media.enabled (not .Values.persistence.media.existingClaim) (not .Values.persistence.media.size) }}
{{- fail "qbittorrent: persistence.media.enabled is true but neither persistence.media.existingClaim nor persistence.media.size is set. Set one of them." }}
{{- end }}
{{- if and (ne .Values.vpn.mode "none") (not .Values.vpn.lanNetworks) }}
{{- fail "qbittorrent: a VPN mode is enabled but vpn.lanNetworks is empty. The killswitch would block access to the web UI as well. Set vpn.lanNetworks to the networks that must stay reachable, e.g. [10.0.0.0/8]." }}
{{- end }}
{{- if not (has .Values.vpn.mode (list "none" "gluetun")) }}
{{- fail "qbittorrent: vpn.mode must be either none or gluetun." }}
{{- end }}
{{- end }}
