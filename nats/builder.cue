package main

import (
	"guku.io/devx/v2alpha1"
	"guku.io/devx/v2alpha1/environments"
)

builders: v2alpha1.#Environments & {
	dev:  environments.#Compose
	prod: environments.#Kubernetes
}
