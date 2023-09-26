package main

import (
	"list"
	"encoding/json"
	"text/template"
	"tool/cli"
	"tool/exec"
	"tool/file"
)

#NATSConf: self = {
	adminUser!:   string
	regularUser!: string
	password!:    string
	clusterName!: string
	gatewayName!: string

	Out: {
		accounts: {

			$SYS: users: [
				{user: adminUser, password: self.password},
			]

			TEAM_A: {
				jetstream: "enabled"
				users: [
					{user: regularUser, password: self.password},
				]
			}
		}

		jetstream: {}
		leafnodes: {}

		cluster: {
			name: clusterName
			port: 6222
			routes: [
				"nats://ca-montreal-1:6222",
			]
		}

		gateway: {
			name: gatewayName
			port: 7222
			gateways: [
				{name: "CA", url: "nats://ca-montreal-1:7222"},
				{name: "US", url: "nats://us-chicago-1:7222"},
				{name: "SG", url: "nats://sg-singapore-1:7222"},
			]
		}

	}
}

command: build: {
	$short: "Build NATS config files."

	let outdir = "conf"

	mkdir: file.MkdirAll & {
		path: outdir
	}

	for i, c in _clusters {
		for n in list.Range(1, c.nodes+1, 1) {
			for name, cueData in services {

				let fileName = "\(outdir)/\(name).json"

				"write_\(name)": file.Create & {
					filename: fileName
					contents: json.Marshal({
						({
							adminUser:   "admin"
							regularUser: "john"
							password:    "password"
							clusterName: "myCluster"
							gatewayName: "myCluster"

							#NATSConf
						}).Out
					})

					$after: mkdir
				}

				"print_\(name)": cli.Print & {
					text:   fileName
					$after: "write_\(name)"
				}

			}

		}
	}

}

command: debug: {
	$short: "Debug NATS config files."

	_debugConf: #NATSConf & {
		adminUser:   "admin"
		regularUser: "john"
		password:    "password"
		clusterName: "myCluster"
		gatewayName: "myGateway"
	}

	print: exec.Run & {
		cmd:   "jq"
		stdin: json.Marshal(_debugConf.Out)
	}

}
