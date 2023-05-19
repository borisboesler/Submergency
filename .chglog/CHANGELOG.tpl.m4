dnl
<!-- this is a generated file -->

dnl change comment marker (#,\n) -> (/*,*/)
changecom(/*,*/)

dnl
dnl Template to emit the commits' refs
dnl
define(
	CHGLOG_COMMIT_REFS,
{{- if .Refs }}
{{- range .Refs }}[(#{{ .Ref }})]({{ $.Info.RepositoryURL }}/-/issues/{{ .Ref }}){{ end -}}
{{ end }})


dnl
dnl Template to emit the subject
dnl
define(
	CHGLOG_COMMIT_SUBJECT,
- {{ if .Scope }}**{{ .Scope }}:** {{ end }}{{ .Subject }})


dnl
dnl Template to emit the subject with references
dnl
define(
	CHGLOG_COMMIT_SUBJECT_WITH_REFS,
- {{ if .Scope }}**{{ .Scope }}:** {{ end }}{{ .Subject }}
CHGLOG_COMMIT_REFS)


dnl
dnl Template to emit the commits' mentions
dnl
define(
	CHGLOG_COMMIT_MENTIONS,
{{ if .Mentions }}
dnl need 4 spaces
    Mentions: {{ .Mentions }}
{{ end -}})


dnl
dnl Template to emit all signers in a commit
dnl
define(
	CHGLOG_COMMIT_SIGNER_ENTRIES,
{{ if .Signers }}
dnl need 4 spaces
    Signed Off By:
{{- range .Signers }}
    - {{ .Name }} ({{ .Email }})
{{ end -}}
{{ end -}})


dnl
dnl Template to emit all co-autors in a commit
dnl
define(
	CHGLOG_COMMIT_COAUTHORS_ENTRIES,
{{ if .CoAuthors }}
dnl need 4 spaces
    Co-authored by:
{{- range .CoAuthors }}
    - {{ .Name }} ({{ .Email }})
{{ end -}}
{{ end -}})


dnl
dnl Template to emit the commits' notes
dnl
define(
	CHGLOG_COMMIT_NOTES,
{{ if .Notes }}
dnl need 4 spaces
{{- range .Notes }}
    **{{ .Title }}**: {{ .Body }}
{{ end -}}
{{ end -}})


dnl
dnl Template to emit a commit entry
dnl
define(
	CHGLOG_COMMITGROUP_ENTRY,
### {{ .Title }}
{{ range .Commits -}}
dnl CHGLOG_COMMIT_SUBJECT
CHGLOG_COMMIT_SUBJECT_WITH_REFS
CHGLOG_COMMIT_MENTIONS
CHGLOG_COMMIT_SIGNER_ENTRIES
CHGLOG_COMMIT_COAUTHORS_ENTRIES
CHGLOG_COMMIT_NOTES
{{ end }})



dnl
dnl The template to emit the full CHANGELOG
dnl
{{- if .Info.Title }}
# CHANGELOG for *{{ .Info.Title }}*
{{- end }}

{{ if .Versions -}}
<a name="Unreleased"></a>
## [Unreleased]

{{ if .Unreleased.CommitGroups -}}
{{ range .Unreleased.CommitGroups -}}
CHGLOG_COMMITGROUP_ENTRY
{{ end -}}
{{ end -}}
{{ end -}} dnl {{ if .Versions -}}

{{ range .Versions }}
<a name="{{ .Tag.Name }}"></a>
## {{ if .Tag.Previous }}[{{ .Tag.Name }}]{{ else }}{{ .Tag.Name }}{{ end }} - {{ datetime "2006-01-02" .Tag.Date }}
{{ range .CommitGroups -}}
CHGLOG_COMMITGROUP_ENTRY
{{ end -}} dnl {{ range .CommitGroups -}}

{{- if .RevertCommits -}}
### Reverts
{{ range .RevertCommits -}}
- {{ .Revert.Header }}
{{ end }} dnl {{ range .RevertCommits -}}
{{ end -}} dnl {{- if .RevertCommits -}}

{{- if .MergeCommits -}}
### Merge Requests
{{ range .MergeCommits -}}
- {{ .Header }}
{{ end }} dnl {{ range .MergeCommits -}}
{{ end -}} dnl {{- if .MergeCommits -}}

{{- if .NoteGroups -}}
{{ range .NoteGroups -}}
### {{ .Title }}
{{ range .Notes }}
{{ .Body }}
{{ end }} dnl {{ range .Notes }}
{{ end -}} dnl {{ range .NoteGroups -}}
{{ end -}} dnl {{- if .NoteGroups -}}
{{ end -}} dnl {{ range .Versions }}


dnl create links into the gitlab view of the repository
{{- if .Versions }}
[Unreleased]: {{ .Info.RepositoryURL }}/compare/{{ $latest := index .Versions 0 }}{{ $latest.Tag.Name }}...HEAD
{{ range .Versions -}}
{{ if .Tag.Previous -}}
[{{ .Tag.Name }}]: {{ $.Info.RepositoryURL }}/compare/{{ .Tag.Previous.Name }}...{{ .Tag.Name }}
{{ end -}}
{{ end -}}
{{ end -}}
