package traits

import (
	"guku.io/devx/v1"
)

#HelmFields: {
	repoType: string
	chart!:   string
	url!:     string
	version!: string
	release:  string
	values: [string]: _
	namespace:       string
	timeout:         uint
	atomic:          bool
	createNamespace: bool
	dependsOn: [...#HelmFields]
}

// a helm chart using helm repo
#Helm: v1.#Trait & {
	$metadata: traits: Helm: null
	k8s: {
		name: string
		version: {
			major: uint | *1
			minor: uint
			...
		}
		...
	}
	helm: #HelmFields & {
		repoType: "git" | "oci" | *"default"
		chart!:   string
		url!:     string
		version!: string
		release:  string | *$metadata.id
		values: [string]: _
		namespace:       string
		timeout:         uint | *600
		atomic:          bool | *true
		createNamespace: bool | *true
		dependsOn: [...#HelmFields]
	}
}
