package main

import (
	"list"
	"text/template"
)

#NATSServer: {
	image:    *"nats:2" | string
	command!: string
	environment?: [string]: string
	ports?: [...string]
	volumes?: [...string]
}

#ConfTemplate: """
	accounts: {
	
	  $SYS: {
	    users: [
	      { user: admin, password: password }
	    ]
	  },
	
	  TEAM_A: {
	    jetstream: enabled,
	    users: [
	      { user: john, password: password }
	    ]
	  }
	
	}
	
	jetstream {}
	
	leafnodes {}

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

#DebugTemplate: template.Execute(#ConfTemplate, {
	clusterName: "ZZ"
	gatewayName: clusterName
})

#Server: {
	name!:    string
	qty!:     uint
	cluster?: string
}

let servers = [
	{clusterName: "CA", name: "ca-montreal", qty:  3},
	{clusterName: "US", name: "us-chicago", qty:   3},
	{clusterName: "US", name: "us-newjersey", qty: 3},
	{clusterName: "GB", name: "gb-london", qty:    3},
	{clusterName: "SG", name: "sg-singapore", qty: 3},
]

// NATS clusters.							

for i, srv in servers {
	for n in list.Range(1, srv.qty+1, 1) {

		let confFile = "\(srv.name).conf"
		let portPrefix = "\(i+1)\(n)"
		let svcName = "\(srv.name)-\(n)"
		let volName = "nats-\(svcName)"

		services: {

			// NATS cluster.
			// See https://github.com/ConnectEverything/rethink_connectivity_examples/blob/main/episode_5/docker-compose.yml
			"\(svcName)": #NATSServer & {
				command: "--name \(svcName) --config \(confFile)"
				ports: [
					"\(portPrefix)422:4222",
					"\(portPrefix)622:6222",
					"\(portPrefix)722:7422",
					"\(portPrefix)822:8222",
				]
				volumes: [
					"./conf/\(confFile):/\(confFile):ro",
					"\(volName):/nats",
				]
			}
		}

		volumes: {
			(volName): {}
		}

	}
}

services: natsbox: {
	image:   "natsio/nats-box"
	command: "sleep 1d"
	environment: {
		NATS_URL:      "nats://ca-montreal-1:4222"
		NATS_USER:     "admin"
		NATS_PASSWORD: "password"
	}
}
