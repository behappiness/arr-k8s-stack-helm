{{/*
Hardware transcoding. Which mechanism works depends on the cluster:

  hostDevice   bind-mount /dev/dri. Works with any VAAPI GPU and needs nothing
               installed cluster-side, but the container has to run privileged:
               a hostPath gives it the device inode, while opening the device
               is gated by the runtime's device cgroup, which only `privileged`
               (or a device plugin) opens. Without it every open() returns
               EPERM and ffmpeg reports no usable render device. The namespace
               must also allow `privileged` under Pod Security Standards.
  devicePlugin request a resource such as gpu.intel.com/i915, amd.com/gpu or
               squat.ai/dri. Needs that plugin installed; this chart does not
               ship one, since a media chart installing a cluster-wide DaemonSet
               is out of scope.
  dra          Dynamic Resource Allocation (resource.k8s.io/v1, GA in 1.34).
               The NVIDIA DRA driver uses this, and it is the only route when
               the device plugin is not advertising nvidia.com/gpu. Selectors
               can pin one card so the others stay free.

`none` disables it and transcoding falls back to the CPU.
*/}}

{{/* Volumes contributed by the selected mode. */}}
{{- define "plex.hwaccel.volumes" -}}
{{- if eq .Values.hardwareAcceleration.mode "hostDevice" }}
- name: dri
  hostPath:
    path: {{ .Values.hardwareAcceleration.hostDevice.path }}
{{- end }}
{{- end }}

{{/* Volume mounts contributed by the selected mode. */}}
{{- define "plex.hwaccel.volumeMounts" -}}
{{- if eq .Values.hardwareAcceleration.mode "hostDevice" }}
- name: dri
  mountPath: {{ .Values.hardwareAcceleration.hostDevice.path }}
{{- end }}
{{- end }}

{{/* Resources, merged with the device-plugin request so both can set `resources`. */}}
{{- define "plex.hwaccel.resources" -}}
{{- $resources := deepCopy (.Values.resources | default dict) -}}
{{- if eq .Values.hardwareAcceleration.mode "devicePlugin" -}}
{{- $device := dict .Values.hardwareAcceleration.devicePlugin.resource .Values.hardwareAcceleration.devicePlugin.count -}}
{{- $limits := merge $device (dig "limits" dict $resources) -}}
{{- $resources = merge (dict "limits" $limits) $resources -}}
{{- end -}}
{{- with $resources }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/* Pod-level resourceClaims, for DRA. */}}
{{- define "plex.hwaccel.podResourceClaims" -}}
{{- if eq .Values.hardwareAcceleration.mode "dra" }}
- name: gpu
  resourceClaimTemplateName: {{ printf "%s-gpu" (include "plex.fullname" .) }}
{{- end }}
{{- end }}

{{/* Container-level claim reference, for DRA. */}}
{{- define "plex.hwaccel.containerResourceClaims" -}}
{{- if eq .Values.hardwareAcceleration.mode "dra" }}
claims:
  - name: gpu
{{- end }}
{{- end }}

{{/* Validation. */}}
{{- define "plex.hwaccel.validate" -}}
{{- $mode := .Values.hardwareAcceleration.mode -}}
{{- if not (has $mode (list "none" "hostDevice" "devicePlugin" "dra")) }}
{{- fail (printf "plex: hardwareAcceleration.mode must be one of none, hostDevice, devicePlugin or dra (got %q)" $mode) }}
{{- end }}
{{- if and (eq $mode "devicePlugin") (not .Values.hardwareAcceleration.devicePlugin.resource) }}
{{- fail "plex: hardwareAcceleration.mode is \"devicePlugin\" but hardwareAcceleration.devicePlugin.resource is empty. Set the resource name the plugin advertises, e.g. gpu.intel.com/i915." }}
{{- end }}
{{- if and (eq $mode "dra") (not .Values.hardwareAcceleration.dra.deviceClassName) }}
{{- fail "plex: hardwareAcceleration.mode is \"dra\" but hardwareAcceleration.dra.deviceClassName is empty, e.g. gpu.nvidia.com." }}
{{- end }}
{{- if and (eq $mode "dra") (semverCompare "<1.34-0" (.Capabilities.KubeVersion.Version | trimPrefix "v")) }}
{{- fail (printf "plex: hardwareAcceleration.mode is \"dra\", which needs resource.k8s.io/v1 (Kubernetes 1.34 or newer). This cluster reports %s." .Capabilities.KubeVersion.Version) }}
{{- end }}
{{- end }}

{{/*
Container securityContext for the selected mode.

hostDevice has to run privileged. Kubernetes has no way to add a device cgroup
rule for a hostPath, so an unprivileged container can see /dev/dri and still be
refused when it opens the render node. devicePlugin and dra do not need this:
the kubelet hands the device to the runtime, which grants it properly.
*/}}
{{- define "plex.hwaccel.securityContext" -}}
{{- $sc := deepCopy (.Values.securityContext | default dict) -}}
{{- if eq .Values.hardwareAcceleration.mode "hostDevice" }}
{{- if .Values.hardwareAcceleration.hostDevice.privileged }}
{{- $sc = merge (dict "privileged" true "allowPrivilegeEscalation" true) $sc -}}
{{- end }}
{{- end }}
{{- with $sc }}
{{- toYaml . }}
{{- end }}
{{- end }}
