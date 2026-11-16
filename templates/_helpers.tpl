{{/*
Host of the dot-ai Service for in-cluster clients such as the controller. The name comes from the
dot-ai subchart's own fullname helper, so overrides and truncation match the Service.
Renders <service>.<namespace>.svc, which resolves under any cluster DNS domain and matches the
".svc" NO_PROXY entry of typical proxy setups, or <service>.<namespace>.svc.<clusterDomain> when
clusterDomain is set.
*/}}
{{- define "dot-ai-stack.dotAiHost" -}}
{{- $name := include "dot-ai.fullname" (dict "Values" (index .Values "dot-ai") "Chart" (dict "Name" "dot-ai") "Release" .Release) -}}
{{- $host := printf "%s.%s.svc" $name .Release.Namespace -}}
{{- with .Values.clusterDomain -}}
{{- $host = printf "%s.%s" $host . -}}
{{- end -}}
{{- $host -}}
{{- end -}}
