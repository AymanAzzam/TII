{{- define "hextris.name" -}}
hextris
{{- end }}

{{- define "hextris.fullname" -}}
{{ .Release.Name }}-{{ include "hextris.name" . }}
{{- end }}
