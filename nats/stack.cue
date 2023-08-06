package main

import (
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/v1/traits"
)

stack: v1.#Stack & {
	components: {

		commonSecrets: {
			traits.#Secret

			secrets: apiKey: {
				name: "myApikey"
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
			traits.#Volume

			containers: default: {
				image: "bitnami/nats:2"
				env: {
					MY_API_KEY: commonSecrets.secrets.apiKey.name
				}
				mounts: [
					{
						volume: volumes.default
						path:   "secrets/file"
					},
				]
			}

			volumes: default: {
				secret: commonSecrets.secrets.apiKey
			}
		}

		nats2: {
			traits.#Workload

			containers: default: image: "bitnami/nats:2"
		}
	}
}
