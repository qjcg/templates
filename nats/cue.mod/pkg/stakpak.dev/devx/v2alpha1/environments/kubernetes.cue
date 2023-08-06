package environments

import (
	"stakpak.dev/devx/v2alpha1"
	"stakpak.dev/devx/v1/traits"
	"stakpak.dev/devx/v1/transformers/kubernetes"
	corev1 "k8s.io/api/core/v1"
)

#Kubernetes: v2alpha1.#StackBuilder & {
	config: {
		defaultSecurityContext?: _
		namespace?:              string
		httpProbes?: {
			livenessProbe:  _
			readinessProbe: _
		}
		cmdProbes?: {
			livenessProbe:  _
			readinessProbe: _
		}
		routes?: {
			ingress?: {
				enabled:      true
				defaultClass: string
			}
			gateway?: {
				enabled: true
			}
		}
		enableHPA: bool | *true
		gateway?:  traits.#GatewaySpec
		imagePullSecrets?: [...corev1.#LocalObjectReference]
	}

	components: {
		if config.gateway != _|_ {
			[string]: http?: {
				gateway: config.gateway
				...
			}
		}
	}

	flows: {
		// ignore traits
		"ignore-secret": match: traits: Secret: null

		// all resources transformers
		if config.namespace != _|_ {
			"k8s/add-namespace": pipeline: [kubernetes.#AddNamespace & {
				namespace: config.namespace
			}]
		}
		"k8s/add-labels": pipeline: [kubernetes.#AddLabels & {
			labels: [string]: string
		}]
		"k8s/add-annotations": pipeline: [kubernetes.#AddAnnotations & {
			annotations: [string]: string
		}]

		// pod spec
		"k8s/add-pod-labels": pipeline: [kubernetes.#AddPodLabels & {
			podLabels: [string]: string
		}]
		"k8s/add-pod-annotations": pipeline: [kubernetes.#AddPodAnnotations & {
			podAnnotations: [string]: string
		}]
		"k8s/add-pod-tolerations": pipeline: [kubernetes.#AddPodTolerations & {
			podTolerations: [...]
		}]
		if config.defaultSecurityContext != _|_ {
			"k8s/add-pod-securitycontext": pipeline: [kubernetes.#AddPodSecurityContext & {
				podSecurityContext: config.defaultSecurityContext
			}]
		}

		// workloads
		"k8s/add-deployment": {
			exclude: traits: Cronable: null
			pipeline: [kubernetes.#AddDeployment & {
				if config.imagePullSecrets != _|_ {
					k8s: imagePullSecrets: config.imagePullSecrets
				}
			}]
		}
		"k8s/add-cronjob": pipeline: [
			kubernetes.#AddCronJob & {
				if config.imagePullSecrets != _|_ {
					k8s: imagePullSecrets: config.imagePullSecrets
				}
			},
		]
		"k8s/add-workload-volumes": pipeline: [kubernetes.#AddWorkloadVolumes]

		if config.httpProbes != _|_ {
			"k8s/add-workload-http-probes": {
				match: traits: Exposable: null
				pipeline: [kubernetes.#AddWorkloadProbes & {
					livenessProbe:  config.httpProbes.livenessProbe
					readinessProbe: config.httpProbes.readinessProbe
				}]
			}
		}
		if config.cmdProbes != _|_ {
			"k8s/add-workload-cmd-probes": {
				exclude: traits: Exposable: null
				pipeline: [kubernetes.#AddWorkloadProbes & {
					livenessProbe:  config.cmdProbes.livenessProbe
					readinessProbe: config.cmdProbes.readinessProbe
				}]
			}
		}

		// servers
		"k8s/add-service": pipeline: [kubernetes.#AddService]
		if config.routes != _|_ && config.routes.ingress != _|_ {
			"k8s/add-http-ingress": pipeline: [
				kubernetes.#AddIngress & kubernetes.#AddAnnotations & {
					ingressClassName: string | *config.routes.ingress.defaultClass
				},
			]
		}
		if config.routes != _|_ && config.routes.gateway != _|_ {
		}

		// scaling
		"k8s/add-replicas": pipeline: [kubernetes.#AddReplicas]

		if config.enableHPA != _|_ {
			"k8s/add-hpa": pipeline: [kubernetes.#AddHPA & {
				hpaMetrics: [...] | *[
						{
						type: "Resource"
						resource: {
							name: "cpu"
							target: {
								type:               "Utilization"
								averageUtilization: 80
							}
						}
					},
					{
						type: "Resource"
						resource: {
							name: "memory"
							target: {
								type:               "Utilization"
								averageUtilization: 80
							}
						}
					},
				]
			}]
		}
	}
}
