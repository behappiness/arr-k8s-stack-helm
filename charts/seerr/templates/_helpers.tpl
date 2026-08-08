{{/*
Expand the name of the chart.
*/}}
{{- define "seerr.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Fully qualified app name.
*/}}
{{- define "seerr.fullname" -}}
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
{{- define "seerr.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "seerr.labels" -}}
helm.sh/chart: {{ include "seerr.chart" . }}
{{ include "seerr.selectorLabels" . }}
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
{{- define "seerr.selectorLabels" -}}
app.kubernetes.io/name: {{ include "seerr.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
ServiceAccount name.
*/}}
{{- define "seerr.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "seerr.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Container image reference. A digest, when set, wins over the tag.
*/}}
{{- define "seerr.image" -}}
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
{{- define "seerr.storageClass" -}}
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
{{- define "seerr.configClaimName" -}}
{{- if .Values.persistence.config.existingClaim }}
{{- .Values.persistence.config.existingClaim }}
{{- else }}
{{- printf "%s-config" (include "seerr.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Value validation.
*/}}
{{- define "seerr.validateValues" -}}
{{- if gt (int .Values.replicaCount) 1 }}
{{- fail "seerr: replicaCount must be 1. Seerr is a single-instance application backed by an RWO volume; running multiple replicas corrupts its database." }}
{{- end }}
{{- end }}

