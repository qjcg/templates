package main

import (
	"guku.io/devx/v1"
	"guku.io/devx/v1/traits"
)

stack: v1.#Stack & {
	components: {

		commonSecrets: {
			traits.#Secret

			secrets: apiKey: {
				name:    "apikey-a"
				version: "4"
			}
		}

		client: {
			traits.#Workload

			containers: default: {
				image: "natsio/nats-box"
				command: ["/bin/sleep"]
				args: ["1d"]
			}
		}

		nats1: {
			traits.#Workload
			//traits.#Volume

			containers: default: {
				image: "bitnami/nats"
				// mounts: [
				// 	{
				// 		// or you can mount secrets as files via volumes
				// 		volume: volumes.default
				// 		path:   "secrets/file"
				// 	},
				// ]
			}
		}

		nats2: {
			traits.#Workload

			containers: default: image: "bitnami/nats"
		}
	}
}
