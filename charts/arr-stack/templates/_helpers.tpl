{{- define "arr-stack.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "arr-stack.fullname" -}}
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

{{- define "arr-stack.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "arr-stack.labels" -}}
helm.sh/chart: {{ include "arr-stack.chart" . }}
app.kubernetes.io/name: {{ include "arr-stack.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: arr-stack
{{- end }}

{{/*
Name of the shared media claim.
*/}}
{{- define "arr-stack.mediaClaimName" -}}
{{- if .Values.media.existingClaim }}
{{- .Values.media.existingClaim }}
{{- else }}
{{- .Values.media.claimName }}
{{- end }}
{{- end }}
