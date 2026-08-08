{{/*
Expand the name of the chart.
*/}}
{{- define "cleanuparr.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Fully qualified app name.
*/}}
{{- define "cleanuparr.fullname" -}}
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
{{- define "cleanuparr.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "cleanuparr.labels" -}}
helm.sh/chart: {{ include "cleanuparr.chart" . }}
{{ include "cleanuparr.selectorLabels" . }}
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
{{- define "cleanuparr.selectorLabels" -}}
app.kubernetes.io/name: {{ include "cleanuparr.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
ServiceAccount name.
*/}}
{{- define "cleanuparr.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "cleanuparr.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Container image reference. A digest, when set, wins over the tag.
*/}}
{{- define "cleanuparr.image" -}}
{{- if .Values.image.digest }}
{{- printf "%s@%s" .Values.image.repository .Values.image.digest }}
{{- else }}
{{- printf "%s:%s" .Values.image.repository (default .Chart.AppVersion .Values.image.tag) }}
{{- end }}
{{- end }}


{{/*
StorageClass for a persistence block.

Order: the volume's own `storageClass`, then `global.storageClass.<purpose>`,
then `global.storageClass.default`. `global.storageClass` may also be a plain
string, which applies to every purpose.
*/}}
{{- define "cleanuparr.storageClass" -}}
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
{{- define "cleanuparr.configClaimName" -}}
{{- if .Values.persistence.config.existingClaim }}
{{- .Values.persistence.config.existingClaim }}
{{- else }}
{{- printf "%s-config" (include "cleanuparr.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Name of the media PVC.
*/}}
{{- define "cleanuparr.mediaClaimName" -}}
{{- if .Values.persistence.media.existingClaim }}
{{- .Values.persistence.media.existingClaim }}
{{- else }}
{{- printf "%s-media" (include "cleanuparr.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Value validation.
*/}}
{{- define "cleanuparr.validateValues" -}}
{{- if gt (int .Values.replicaCount) 1 }}
{{- fail "cleanuparr: replicaCount must be 1. Cleanuparr is a single-instance application backed by an RWO volume; running multiple replicas corrupts its database." }}
{{- end }}
{{- if and .Values.persistence.media.enabled (not .Values.persistence.media.existingClaim) (not .Values.persistence.media.size) }}
{{- fail "cleanuparr: persistence.media.enabled is true but neither persistence.media.existingClaim nor persistence.media.size is set. Set one of them." }}
{{- end }}
{{- end }}
