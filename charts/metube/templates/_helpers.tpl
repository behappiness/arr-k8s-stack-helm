{{/*
Expand the name of the chart.
*/}}
{{- define "metube.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Fully qualified app name.
*/}}
{{- define "metube.fullname" -}}
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
{{- define "metube.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "metube.labels" -}}
helm.sh/chart: {{ include "metube.chart" . }}
{{ include "metube.selectorLabels" . }}
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
{{- define "metube.selectorLabels" -}}
app.kubernetes.io/name: {{ include "metube.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
ServiceAccount name.
*/}}
{{- define "metube.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "metube.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Container image reference. A digest, when set, wins over the tag.
*/}}
{{- define "metube.image" -}}
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
{{- define "metube.storageClass" -}}
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
{{- define "metube.configClaimName" -}}
{{- if .Values.persistence.config.existingClaim }}
{{- .Values.persistence.config.existingClaim }}
{{- else }}
{{- printf "%s-config" (include "metube.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Name of the media PVC.
*/}}
{{- define "metube.mediaClaimName" -}}
{{- if .Values.persistence.media.existingClaim }}
{{- .Values.persistence.media.existingClaim }}
{{- else }}
{{- printf "%s-media" (include "metube.fullname" .) }}
{{- end }}
{{- end }}

{{/*
An HTTP probe, with its path moved under `metube.urlPrefix`.

MeTube serves its UI at URL_PREFIX and nowhere else, so under a prefix a probe
against `/` gets a 404 and kills a healthy pod. Only httpGet probes with an
absolute path are rewritten; exec and tcpSocket probes pass through untouched.
*/}}
{{- define "metube.probe" -}}
{{- $probe := omit .probe "enabled" -}}
{{- $prefix := .root.Values.metube.urlPrefix -}}
{{- $get := $probe.httpGet | default dict -}}
{{- if and $prefix $get.path (hasPrefix "/" $get.path) -}}
{{- $path := printf "%s/%s" (trimSuffix "/" $prefix) (trimPrefix "/" $get.path) -}}
{{- $probe = merge (dict "httpGet" (merge (dict "path" $path) $get)) $probe -}}
{{- end -}}
{{- toYaml $probe -}}
{{- end }}

{{/*
Value validation.
*/}}
{{- define "metube.validateValues" -}}
{{- if gt (int .Values.replicaCount) 1 }}
{{- fail "metube: replicaCount must be 1. MeTube keeps its download queue in a state directory on an RWO volume; a second replica cannot mount it, and would race the first on the same partial files if it could." }}
{{- end }}
{{- if and .Values.persistence.media.enabled (not .Values.persistence.media.existingClaim) (not .Values.persistence.media.size) }}
{{- fail "metube: persistence.media.enabled is true but neither persistence.media.existingClaim nor persistence.media.size is set. Set one of them." }}
{{- end }}
{{- if not .Values.metube.downloadDir }}
{{- fail "metube: metube.downloadDir is empty. MeTube would fall back to its working directory inside the container and every download would be lost on restart." }}
{{- end }}

{{- $mount := .Values.persistence.media.mountPath -}}
{{- if .Values.persistence.media.enabled }}
{{- if not (hasPrefix (printf "%s/" $mount) .Values.metube.downloadDir) }}
{{- fail (printf "metube: metube.downloadDir is %q, which is not inside the media volume mounted at %q. Downloads would go to the container filesystem and disappear on restart, while the volume they were meant for stays empty. Put it under %s/." .Values.metube.downloadDir $mount $mount) }}
{{- end }}
{{- /*
  A finished download is moved out of TEMP_DIR into DOWNLOAD_DIR. Within one
  filesystem that is a rename; across a mount boundary it is a byte-for-byte
  copy, so the job needs the file's size twice over and takes as long again.
*/}}
{{- if and .Values.metube.tempDir (not (hasPrefix (printf "%s/" $mount) .Values.metube.tempDir)) }}
{{- fail (printf "metube: metube.tempDir is %q but downloads land in %q on the media volume. A move across that boundary is a full copy of the finished file, not a rename: it needs the space twice and takes as long as the download did. Leave tempDir empty to keep partials beside the finished files, or point it inside %s/." .Values.metube.tempDir .Values.metube.downloadDir $mount) }}
{{- end }}
{{- if and .Values.metube.audioDownloadDir (not (hasPrefix (printf "%s/" $mount) .Values.metube.audioDownloadDir)) }}
{{- fail (printf "metube: metube.audioDownloadDir is %q, which is not inside the media volume mounted at %q. Audio downloads would be written to the container filesystem and lost on restart." .Values.metube.audioDownloadDir $mount) }}
{{- end }}

{{- else }}
{{- /*
  Without the media volume, the download directory has to land on some other
  volume the pod actually mounts. MeTube will happily write to a path that is
  just the container's writable layer: the UI reports every download as
  finished, and the files are gone at the next restart. Nothing else in the
  chart would notice, so it is checked here.
*/}}
{{- $roots := list }}
{{- if .Values.persistence.config.enabled }}{{- $roots = append $roots "/config" }}{{- end }}
{{- range .Values.extraVolumeMounts }}{{- $roots = append $roots .mountPath }}{{- end }}
{{- $ok := false }}
{{- range $roots }}
{{- if or (eq $.Values.metube.downloadDir .) (hasPrefix (printf "%s/" .) $.Values.metube.downloadDir) }}{{- $ok = true }}{{- end }}
{{- end }}
{{- if not $ok }}
{{- fail (printf "metube: metube.downloadDir is %q, but no volume is mounted there. persistence.media.enabled is false and the directory is not under %s either, so downloads would go to the container's writable layer and be lost the next time the pod restarts - silently, because MeTube still reports them as complete. Enable persistence.media and keep the downloads on the shared library volume, or point metube.downloadDir at a volume this pod does mount." .Values.metube.downloadDir (or (join ", " $roots) "any mounted path")) }}
{{- end }}
{{- end }}

{{- /*
  URL_PREFIX is used verbatim as the route MeTube mounts its app on. Without the
  surrounding slashes it builds a path like `metubestatic/...` and the UI loads
  a blank page - which looks like a broken deployment, not a typo.
*/}}
{{- $prefix := .Values.metube.urlPrefix -}}
{{- if and $prefix (or (not (hasPrefix "/" $prefix)) (not (hasSuffix "/" $prefix))) }}
{{- fail (printf "metube: metube.urlPrefix is %q. It has to start and end with a slash, e.g. \"/metube/\", or MeTube builds broken asset URLs and the UI loads as a blank page." $prefix) }}
{{- end }}
{{- end }}
