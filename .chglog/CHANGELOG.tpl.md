<!-- this is a generated file -->




























{{- if .Info.Title }}
# CHANGELOG for *{{ .Info.Title }}*
{{- end }}

{{ if .Versions -}}
<a name="Unreleased"></a>
## [Unreleased]

{{ if .Unreleased.CommitGroups -}}
{{ range .Unreleased.CommitGroups -}}
### {{ .Title }}
{{ range .Commits -}}
- {{ if .Scope }}**{{ .Scope }}:** {{ end }}{{ .Subject }}
{{- if .Refs }}
{{- range .Refs }}[(#{{ .Ref }})]({{ $.Info.RepositoryURL }}/-/issues/{{ .Ref }}){{ end -}}
{{ end }}
{{ if .Mentions }}
    Mentions: {{ .Mentions }}
{{ end -}}
{{ if .Signers }}
    Signed Off By:
{{- range .Signers }}
    - {{ .Name }} ({{ .Email }})
{{ end -}}
{{ end -}}
{{ if .CoAuthors }}
    Co-authored by:
{{- range .CoAuthors }}
    - {{ .Name }} ({{ .Email }})
{{ end -}}
{{ end -}}
{{ if .Notes }}
{{- range .Notes }}
    **{{ .Title }}**: {{ .Body }}
{{ end -}}
{{ end -}}
{{ end }}
{{ end -}}
{{ end -}}
{{ end -}} 
{{ range .Versions }}
<a name="{{ .Tag.Name }}"></a>
## {{ if .Tag.Previous }}[{{ .Tag.Name }}]{{ else }}{{ .Tag.Name }}{{ end }} - {{ datetime "2006-01-02" .Tag.Date }}
{{ range .CommitGroups -}}
### {{ .Title }}
{{ range .Commits -}}
- {{ if .Scope }}**{{ .Scope }}:** {{ end }}{{ .Subject }}
{{- if .Refs }}
{{- range .Refs }}[(#{{ .Ref }})]({{ $.Info.RepositoryURL }}/-/issues/{{ .Ref }}){{ end -}}
{{ end }}
{{ if .Mentions }}
    Mentions: {{ .Mentions }}
{{ end -}}
{{ if .Signers }}
    Signed Off By:
{{- range .Signers }}
    - {{ .Name }} ({{ .Email }})
{{ end -}}
{{ end -}}
{{ if .CoAuthors }}
    Co-authored by:
{{- range .CoAuthors }}
    - {{ .Name }} ({{ .Email }})
{{ end -}}
{{ end -}}
{{ if .Notes }}
{{- range .Notes }}
    **{{ .Title }}**: {{ .Body }}
{{ end -}}
{{ end -}}
{{ end }}
{{ end -}} 
{{- if .RevertCommits -}}
### Reverts
{{ range .RevertCommits -}}
- {{ .Revert.Header }}
{{ end }} {{ end -}} 
{{- if .MergeCommits -}}
### Merge Requests
{{ range .MergeCommits -}}
- {{ .Header }}
{{ end }} {{ end -}} 
{{- if .NoteGroups -}}
{{ range .NoteGroups -}}
### {{ .Title }}
{{ range .Notes }}
{{ .Body }}
{{ end }} {{ end -}} {{ end -}} {{ end -}} 

{{- if .Versions }}
[Unreleased]: {{ .Info.RepositoryURL }}/compare/{{ $latest := index .Versions 0 }}{{ $latest.Tag.Name }}...HEAD
{{ range .Versions -}}
{{ if .Tag.Previous -}}
[{{ .Tag.Name }}]: {{ $.Info.RepositoryURL }}/compare/{{ .Tag.Previous.Name }}...{{ .Tag.Name }}
{{ end -}}
{{ end -}}
{{ end -}}
