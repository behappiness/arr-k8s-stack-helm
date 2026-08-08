{{/*
Expand the name of the chart.
*/}}
{{- define "prowlarr.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Fully qualified app name.
*/}}
{{- define "prowlarr.fullname" -}}
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
{{- define "prowlarr.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "prowlarr.labels" -}}
helm.sh/chart: {{ include "prowlarr.chart" . }}
{{ include "prowlarr.selectorLabels" . }}
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
{{- define "prowlarr.selectorLabels" -}}
app.kubernetes.io/name: {{ include "prowlarr.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
ServiceAccount name.
*/}}
{{- define "prowlarr.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "prowlarr.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Container image reference. A digest, when set, wins over the tag.
*/}}
{{- define "prowlarr.image" -}}
{{- if .Values.image.digest }}
{{- printf "%s@%s" .Values.image.repository .Values.image.digest }}
{{- else }}
{{- printf "%s:%s" .Values.image.repository (default .Chart.AppVersion .Values.image.tag) }}
{{- end }}
{{- end }}

{{/*
The environment variable prefix this application reads its configuration from.
A property of the application, not something an operator should change.
*/}}
{{- define "prowlarr.envPrefix" -}}PROWLARR{{- end }}

{{/*
StorageClass for a persistence block.

Order: the volume's own `storageClass`, then `global.storageClass.<purpose>`,
then `global.storageClass.default`. `global.storageClass` may also be a plain
string, which applies to every purpose.
*/}}
{{- define "prowlarr.storageClass" -}}
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
{{- define "prowlarr.configClaimName" -}}
{{- if .Values.persistence.config.existingClaim }}
{{- .Values.persistence.config.existingClaim }}
{{- else }}
{{- printf "%s-config" (include "prowlarr.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Value validation.
*/}}
{{- define "prowlarr.validateValues" -}}
{{- if gt (int .Values.replicaCount) 1 }}
{{- fail "prowlarr: replicaCount must be 1. Prowlarr is a single-instance application backed by an RWO volume; running multiple replicas corrupts its database." }}
{{- end }}
{{- end }}

{{/*
Render a probe, prefixing httpGet.path with config.urlBase. Every endpoint
moves under the URL base, so an unprefixed probe 404s.
*/}}
{{- define "prowlarr.probe" -}}
{{- $probe := omit .probe "enabled" -}}
{{- if and $probe.httpGet .urlBase -}}
{{- $httpGet := merge (dict "path" (printf "%s%s" .urlBase $probe.httpGet.path)) $probe.httpGet -}}
{{- $probe = merge (dict "httpGet" $httpGet) $probe -}}
{{- end -}}
{{- toYaml $probe -}}
{{- end }}
