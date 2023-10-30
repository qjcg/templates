package main

import (
	"list"
	"strings"
	"text/template"
	"tool/cli"
	"tool/exec"
	"tool/file"
)

#D2DiagramTemplate: """
	root: "NATS Deployment Architecture" {
	{{- range $idx, $cluster := . }}
	{{ $cluster.name -}}: {
		 {{- range $name, $node := $cluster.nodes }}
		 {{ $name }}
		 {{- end }}
	}
	{{ end }}
	}
	"""

command: diagram: {
	$short: "Build NATS d2 diagram."

	let fileName = "docs/deployment-architecture.d2"
	let fileNameSVG = strings.Replace(fileName, "d2", "svg", -1)

	write: file.Create & {
		filename: fileName
		contents: template.Execute(#D2DiagramTemplate, _Clusters)
	}

	print: cli.Print & {
		text:   "wrote \(fileName)"
		$after: write
	}

	buildSVG: exec.Run & {
		cmd:    "d2 \(fileName)"
		$after: print
	}

	open: exec.Run & {
		cmd:    "open -a firefox \(fileNameSVG)"
		$after: buildSVG
	}

}
