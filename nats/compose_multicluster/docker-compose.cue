package main

import (
	"list"
	"strings"
)

#NATSContainer: {
	image: "nats:2"

	command!: string

	environment?: [string]: string
	ports?: [...string]
	volumes?: [...string]
}

#Country: {
	name!: string
	code!: string
}

// A list of countries along with their 2-letter codes.
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

// A list of cities along with the countries they are part of.
_Cities: [Name=string]: name: Name
_Cities: {
	Montreal: country:  _Countries.Canada
	Singapore: country: _Countries.Singapore
	London: country:    _Countries.GB
	Chicago: country:   _Countries.USA
	NewJersey: country: _Countries.USA
}

#NATSClusterParams: {
	name!:  string
	nodes!: uint8
	city!:  #City
}

#defaultNATSClusterParams: self = {
	name:  strings.ToLower("\(self.city.country.code)-\(self.city.name)")
	nodes: *3 | uint8

	#NATSClusterParams
}

_clusters: [ClusterName=string]: {
	params: #NATSClusterParams

	nodes: [NodeName=string]: {
		params:
			container: #NATSContainer
	}
}

for name, data in _clusters {
	_clusters: "\(name)": {
		for n in c.params.nodes {
			let nodeName = "\(name)-\(n)"
			let confFile = "\(nodeName).json"
			let volName = "nats-\(nodeName)"

			nodes: "\(nodeName)": #NATSContainer & {
				command: "--config \(confFile)"
				volumes: [
					"./conf/\(confFile):/\(confFile):ro",
					"\(volName):/nats",
				]
			}

		}
	}
}

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
				command: "--config \(confFile)"
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
