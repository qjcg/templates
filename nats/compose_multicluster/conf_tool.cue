package main

import (
	"list"
	"text/template"
	"tool/cli"
	"tool/file"
)

command: build: {
	$short: "Build NATS config files."

	let outdir = "conf"

	mkdir: file.MkdirAll & {
		path: outdir
	}

	for name, cueData in services {

		let fileName = "\(outdir)/\(name).conf"

		"write_\(name)": file.Create & {
			filename: fileName
			contents: template.Execute(#NATSConfTemplate, {
				adminUser:   "admin"
				regularUser: "john"
				password:    "password"

				cueData
			})
			$after: mkdir
		}

		"print_\(name)": cli.Print & {
			text:   fileName
			$after: "write_\(name)"
		}

	}

}
