{{/*
Generate a random jupyter token.
*/}}
{{- define "jupyter.random_token" -}}
{{- /* Create "tmp_vars" dict inside ".Release" to store various stuff. */ -}}
{{- if not (index .Release "tmp_vars") -}}
{{-   $_ := set .Release "tmp_vars" dict -}}
{{- end -}}
{{- /* Some random ID of this token, in case there will be other random values alongside this instance. */ -}}
{{- $key := printf "%s_%s" .Release.Name "token" -}}
{{- /* If $key does not yet exist in .Release.tmp_vars, then... */ -}}
{{- if not (index .Release.tmp_vars $key) -}}
{{- /* ... store random token under the $key */ -}}
{{-   $_ := set .Release.tmp_vars $key (randAlphaNum 32) -}}
{{- end -}}
{{- /* Retrieve previously generated value. */ -}}
{{- index .Release.tmp_vars $key -}}
{{- end -}}

{{/*
Expand the name of the chart.
*/}}
{{- define "pod.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "pod.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "pod.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "pod.labels" -}}
helm.sh/chart: {{ include "pod.chart" . }}
{{ include "pod.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "pod.selectorLabels" -}}
app.kubernetes.io/name: {{ include "pod.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "pod.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "pod.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Common ingress annotations
*/}}
{{- define "ingress.annotations" -}}
{{- if .Values.ingress.tls }}
cert-manager.io/cluster-issuer: letsencrypt-prod
{{- end }}
{{- with .Values.ingress.annotations }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
Create the name of the ingress host to use
*/}}
{{- define "ingress.host" -}}
{{- $fullName := include "pod.fullname" . -}}
{{- printf "%s-x-%s.%s" $fullName .Release.Namespace .Values.ingress.domain }}
{{- end }}