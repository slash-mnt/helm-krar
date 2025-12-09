{{/*
Expand the name of the chart.
*/}}
{{- define "krar.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "krar.fullname" -}}
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
Create chart name and version as used by the chart label.
*/}}
{{- define "krar.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "krar.labels" -}}
helm.sh/chart: {{ include "krar.chart" . }}
{{ include "krar.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "krar.selectorLabels" -}}
app.kubernetes.io/name: {{ include "krar.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "krar.serviceAccountName" -}}
{{- default (include "krar.fullname" .) .Values.serviceAccountName }}
{{- end }}

{{/*
Create the name of the cluster role to use
*/}}
{{- define "krar.clusterRoleName" -}}
{{- default (include "krar.fullname" .) .Values.clusterRoleName }}
{{- end }}

{{/*
Create the name of the cluster role to use
*/}}
{{- define "krar.roleName" -}}
{{- default (include "krar.fullname" .) .Values.roleName }}
{{- end }}