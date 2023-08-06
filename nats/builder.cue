package main

import (
	"stakpak.dev/devx/v2alpha1"
	"stakpak.dev/devx/v2alpha1/environments"
)

builders: v2alpha1.#Environments & {
	dev:  environments.#Compose
	prod: environments.#Kubernetes
}
