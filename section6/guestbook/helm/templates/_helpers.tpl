{{- define "guestbook-ui.name" -}}
guestbook-ui
{{- end -}}

{{- define "guestbook-ui.fullname" -}}
{{ include "guestbook-ui.name" . }}
{{- end -}}
