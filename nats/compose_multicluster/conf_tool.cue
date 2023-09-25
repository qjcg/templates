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

#NATSConfTemplate: """
	accounts: {

	  $SYS: {
	    users: [
	      { user: {{ .adminUser }}, password: {{ .password }} }
	    ]
	  },

	  TEAM_A: {
	    jetstream: enabled,
	    users: [
	      { user: {{ .regularUser }}, password: {{ .password }} }
	    ]
	  }

	}

	jetstream: {}

	leafnodes: {}

	cluster: {
	  name: {{ .clusterName }},
	  port: 6222,
	  routes: [
	    "nats://ca-montreal-1:6222"
	  ]
	}

	gateway: {
	  name: {{ .gatewayName }},
	  port: 7222,
	  gateways: [
	    { name: CA, url: "nats://ca-montreal-1:7222" }
	    { name: US, url: "nats://us-chicago-1:7222" }
	    { name: SG, url: "nats://sg-singapore-1:7222" }
	  ]
	}
	"""

#DebugTemplate: template.Execute(#NATSConfTemplate, {
	clusterName: "ZZ"
	gatewayName: clusterName
})

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
