{{/*
Expand the name of the chart.
*/}}
{{- define "tracearr.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Fully qualified app name.
*/}}
{{- define "tracearr.fullname" -}}
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
{{- define "tracearr.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "tracearr.labels" -}}
helm.sh/chart: {{ include "tracearr.chart" . }}
{{ include "tracearr.selectorLabels" . }}
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
{{- define "tracearr.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tracearr.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
ServiceAccount name.
*/}}
{{- define "tracearr.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "tracearr.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Container image reference. A digest, when set, wins over the tag.
*/}}
{{- define "tracearr.image" -}}
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
{{- define "tracearr.storageClass" -}}
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
{{- define "tracearr.configClaimName" -}}
{{- if .Values.persistence.config.existingClaim }}
{{- .Values.persistence.config.existingClaim }}
{{- else }}
{{- printf "%s-config" (include "tracearr.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Name of the Secret holding the connection strings and signing keys.
*/}}
{{- define "tracearr.secretName" -}}
{{- if .Values.config.existingSecret }}
{{- .Values.config.existingSecret }}
{{- else }}
{{- include "tracearr.fullname" . }}
{{- end }}
{{- end }}

{{/*
A signing key. Order: a configured value, the key already in the cluster, then
a new one. The lookup keeps it stable across `helm upgrade`; a new key would
invalidate every session.
*/}}
{{- define "tracearr.signingKey" -}}
{{- $ctx := .ctx -}}
{{- if .value }}
{{- .value }}
{{- else }}
{{- $prior := (lookup "v1" "Secret" $ctx.Release.Namespace (include "tracearr.fullname" $ctx)) -}}
{{- $existing := "" -}}
{{- if $prior }}
{{- $existing = index (default dict $prior.data) .key | default "" -}}
{{- end }}
{{- if $existing }}
{{- $existing | b64dec }}
{{- else }}
{{- randAlphaNum 64 }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Value validation.
*/}}
{{- define "tracearr.validateValues" -}}
{{- if gt (int .Values.replicaCount) 1 }}
{{- fail "tracearr: replicaCount must be 1. Tracearr is a single-instance application backed by an RWO volume; running multiple replicas corrupts its database." }}
{{- end }}
{{- if and (not .Values.config.databaseUrl) (not .Values.config.existingSecret) }}
{{- fail "tracearr: config.databaseUrl is empty. Tracearr stores everything in PostgreSQL and exits on start without DATABASE_URL - there is no SQLite mode. Set config.databaseUrl, or config.existingSecret pointing at a Secret with a `database-url` key." }}
{{- end }}
{{- if and (not .Values.config.redisUrl) (not .Values.config.existingSecret) }}
{{- fail "tracearr: config.redisUrl is empty. Tracearr needs Redis alongside PostgreSQL. Set config.redisUrl, or config.existingSecret pointing at a Secret with a `redis-url` key." }}
{{- end }}
{{- end }}
