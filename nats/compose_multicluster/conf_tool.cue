package main

import (
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

	clusterName?:  string
	clusterRoutes: *["nats://ca-montreal-1:6222"] | [...]

	gatewayName!: string
	gateways?: [...]

	leafnodes: *[] | [...]

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

		if clusterName != _|_ {
			cluster: {
				name:   clusterName
				port:   6222
				routes: clusterRoutes
			}
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

	for c in _Clusters {
		for nodeName, nodeData in c.nodes {
			let fileName = "\(outdir)/\(nodeName).json"

			let data = json.Marshal(({
				adminUser:   "admin"
				regularUser: "john"
				password:    "password"
				gatewayName: "myCluster"
				clusterName: c.name

				#NATSConf
			}).Out)

			"write_\(nodeName)": file.Create & {
				filename: fileName
				contents: data

				$after: mkdir
			}

			"print_\(nodeName)": cli.Print & {
				text:   fileName
				$after: "write_\(nodeName)"
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
