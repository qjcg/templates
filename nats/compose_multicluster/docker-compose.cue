package main

import (
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
	cities!: [string]: name: string
}

_Countries: [string]: #Country
_Countries: [CountryName=string]: name: CountryName
_Countries: [string]: cities: [CityName=string]: name: CityName
_Countries: {
	Canada: {
		code: "CA"
		cities: Montreal: _
	}

	USA: {
		code: "US"
		cities: {
			Chicago:   _
			NewJersey: _
		}
	}

	GreatBritain: {
		code: "GB"
		cities: London: _
	}

	Singapore: {
		code: "SG"
		cities: Singapore: _
	}
}

_CountriesByCity: {
	for Country in _Countries {
		for CityName, _ in Country.cities {
			"\(CityName)": Country.name
		}
	}
}

#Cluster: {
	let Country = _CountriesByCity[city]

	city!:    string
	name:     *strings.ToLower("\(_Countries[Country].code)-\(city)") | string
	numNodes: *3 | uint8

	for i, _ in ([0] * numNodes) {
		let nodeName = "\(name)-\(i+1)"

		nodes: (nodeName): {
			container: #NATSContainer & {
				command: "--config \(confFile)"
			}
			confFile: *"\(nodeName).json" | string
			volName:  *"nats-\(nodeName)" | string

			Out: {
				services: (nodeName): {
					command: "--config \(confFile)"
					volumes: [
						"./conf/\(confFile):/\(confFile):ro",
						"\(volName):/nats",
					]
				}

				volumes: (volName): {}
			}
		}
	}
}

_Clusters: [string]: #Cluster
_Clusters: {
	Foo: city: "Chicago"
	Bar: city: "Montreal"
}

for clusterData in _Clusters {
	for nodeData in clusterData.nodes {
		nodeData.Out
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
