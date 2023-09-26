package main

import (
	"list"
	"strings"
)

#NATSContainer: {
	image: "nats:2"

	_clusterName!: string
	command!:      string

	environment?: [string]: string
	ports?: [...string]
	volumes?: [...string]
}

#Country: {
	name!: string
	code!: string
}

_Countries: [Name=string]: name: Name
_Countries: {
	Canada: code:    "CA"
	USA: code:       "US"
	GB: code:        "GB"
	Singapore: code: "SG"
}

#City: {
	name!:    string
	country!: #Country
}

_Cities: [Name=string]: name: Name
_Cities: {
	Montreal: country:  _Countries.Canada
	Singapore: country: _Countries.Singapore
	London: country:    _Countries.GB
	Chicago: country:   _Countries.USA
	NewJersey: country: _Countries.USA
}

#NATSClusterConfig: {
	name!:  string
	nodes!: uint8
	city!:  #City
}

#defaultNATSClusterConfig: self = {
	name:  strings.ToLower("\(self.city.country.code)-\(self.city.name)")
	nodes: *3 | uint8

	#NATSClusterConfig
}

_clusters: [...#defaultNATSClusterConfig] & [
		{city: _Cities.Chicago},
		{city: _Cities.London},
		{city: _Cities.Montreal},
		{city: _Cities.NewJersey},
		{city: _Cities.Singapore},
]

// NATS clusters.

for i, c in _clusters {
	for n in list.Range(1, c.nodes+1, 1) {

		let nodeName = "\(c.name)-\(n)"
		let confFile = "\(nodeName).json"
		let portPrefix = "\(i+1)\(n)"
		let volName = "nats-\(nodeName)"

		services: {
			// NATS cluster.
			// See https://github.com/ConnectEverything/rethink_connectivity_examples/blob/main/episode_5/docker-compose.yml
			"\(nodeName)": #NATSContainer & {
				_clusterName: "\(c.name)"

				command: "--name \(nodeName) --config \(confFile)"
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

		volumes: (volName): {}

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
