package kubernetes

import (
	"list"
	"strings"
	"guku.io/devx/v1"
	"guku.io/devx/v1/traits"
	appsv1 "k8s.io/api/apps/v1"
	corev1 "k8s.io/api/core/v1"
	netv1 "k8s.io/api/networking/v1"
	autoscalingv2beta2 "k8s.io/api/autoscaling/v2beta2"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

WorkloadTypes: ["k8s.io/apps/v1/deployment", "k8s.io/apps/v1/statefulset"]

_#KubernetesName: =~"^[a-z0-9][-a-z0-9]{0,251}[a-z0-9]?$"
_#KubernetesMeta: {
	metadata?: metav1.#ObjectMeta
	...
}
_#WorkloadResource: {
	_#KubernetesMeta
	$metadata: labels: {
		driver: "kubernetes"
		type:   string
	}
	spec: {
		template: corev1.#PodTemplateSpec
		...
	}
}
_#DeploymentResource: {
	appsv1.#Deployment
	$metadata: labels: {
		driver: "kubernetes"
		type:   "k8s.io/apps/v1/deployment"
	}
	kind:       "Deployment"
	apiVersion: "apps/v1"
	metadata: name: _#KubernetesName
	spec: template: spec: securityContext: {
		runAsUser:  uint | *10000
		runAsGroup: uint | *10000
		fsGroup:    uint | *10000
	}
}
_#ServiceAccountResource: {
	corev1.#ServiceAccount
	$metadata: labels: {
		driver: "kubernetes"
		type:   "k8s.io/core/v1/serviceaccount"
	}
	kind:       "ServiceAccount"
	apiVersion: "v1"
	metadata: name: _#KubernetesName
}
_#ServiceResource: {
	corev1.#Service
	$metadata: labels: {
		driver: "kubernetes"
		type:   "k8s.io/core/v1/service"
	}
	kind:       "Service"
	apiVersion: "v1"
	metadata: name: _#KubernetesName
}
_#HPAResource: {
	autoscalingv2beta2.#HorizontalPodAutoscaler
	$metadata: labels: {
		driver: "kubernetes"
		type:   "k8s.io/autoscaling/v2beta2/horizontalpodautoscaler"
	}
	kind:       "HorizontalPodAutoscaler"
	apiVersion: "autoscaling/v2beta2"
	metadata: name: _#KubernetesName
}

_#ContainersSpec: {
	#InputContainers: _
	[ for k, container in #InputContainers {
		{
			name:    k
			image:   container.image
			command: container.command
			args:    container.args
			env: [
				for name, value in container.env {
					if (value & string) != _|_ {
						{
							"name":  name
							"value": value
						}
					}
					if (value & v1.#Secret) != _|_ {
						{
							"name": name
							valueFrom: secretKeyRef: {
								"name": value.name & _#KubernetesName
								if value.property == _|_ {
									"key": name
								}
								if value.property != _|_ {
									"key": value.property
								}
								optional: false
							}
						}
					}
				},
			]
			if container.resources.limits.cpu != _|_ {
				resources: limits: cpu: container.resources.limits.cpu
			}
			if container.resources.limits.memory != _|_ {
				resources: limits: memory: container.resources.limits.memory
			}
			if container.resources.requests.cpu != _|_ {
				resources: requests: cpu: container.resources.requests.cpu
			}
			if container.resources.requests.memory != _|_ {
				resources: requests: memory: container.resources.requests.memory
			}
		}
	},
	]
}

#AddDeployment: v1.#Transformer & {
	v1.#Component
	traits.#Workload
	$metadata:  _
	restart:    _
	containers: _

	appName:            string | *$metadata.id
	serviceAccountName: string | *$metadata.id
	$resources: {
		"\(appName)-deployment": _#DeploymentResource & {
			metadata: {
				name: appName
				labels: app: appName
			}
			spec: {
				selector: matchLabels: app: appName
				template: {
					metadata: {
						annotations: {}
						labels: app: appName
					}
					spec: {
						"serviceAccountName": serviceAccountName
						restartPolicy:        "Always"
						"containers":         _#ContainersSpec & {
							#InputContainers: containers
						}
					}
				}
			}
		}

		"\(appName)-sa": _#ServiceAccountResource & {
			metadata: {
				name: serviceAccountName
				labels: app: appName
			}
		}
	}
}

#AddService: v1.#Transformer & {
	traits.#Workload
	traits.#Exposable
	$metadata: _
	endpoints: _

	appName:     string | *$metadata.id
	serviceName: string | *$metadata.id
	endpoints: default: host: serviceName
	$resources: "\(serviceName)-svc": _#ServiceResource & {
		metadata: name: serviceName
		spec: {
			selector: app: "\(appName)"
			ports: [
				for p in endpoints.default.ports {
					{
						if p.name != _|_ {
							name: p.name
						}

						if p.name == _|_ {
							name: "\(p.port)"
						}

						port: p.port
					}
				},
			]
			type: string | *"ClusterIP"
		}
	}
}

#AddReplicas: v1.#Transformer & {
	v1.#Component
	traits.#Workload
	traits.#Replicable
	$metadata: _
	replicas:  _

	$resources: [_]: this={
		if list.Contains(WorkloadTypes, this.$metadata.labels.type) {
			_#WorkloadResource & {
				spec: "replicas": replicas.min
			}
		}
	}
}

#AddHPA: v1.#Transformer & {
	v1.#Component
	traits.#Workload
	traits.#Replicable
	$metadata: _
	hpaMetrics: [...autoscalingv2beta2.#MetricSpec]
	replicas: _
	appName:  string | *$metadata.id
	$resources: "\(appName)-hpa": _#HPAResource & {
		metadata: {
			name: appName
			labels: app: appName
		}
		spec: {
			scaleTargetRef: {
				name:       $resources["\(appName)-deployment"].metadata.name
				kind:       $resources["\(appName)-deployment"].kind
				apiVersion: $resources["\(appName)-deployment"].apiVersion
			}
			minReplicas: replicas.min
			maxReplicas: replicas.max
			metrics:     hpaMetrics
		}
	}
}

#AddPodLabels: v1.#Transformer & {
	v1.#Component
	traits.#Workload
	$metadata: _
	podLabels: [string]: string

	$resources: [_]: this={
		if list.Contains(WorkloadTypes, this.$metadata.labels.type) {
			_#WorkloadResource & {
				spec: template: metadata: labels: podLabels
			}
		}
	}
}

#AddPodAnnotations: v1.#Transformer & {
	v1.#Component
	traits.#Workload
	$metadata: _
	podAnnotations: [string]: string

	$resources: [_]: this={
		if list.Contains(WorkloadTypes, this.$metadata.labels.type) {
			_#WorkloadResource & {
				spec: template: metadata: annotations: podAnnotations
			}
		}
	}
}

#AddNamespace: v1.#Transformer & {
	v1.#Component
	namespace: string

	$resources: [_]: this={
		if this.$metadata.labels.driver == "kubernetes" {
			_#KubernetesMeta
			metadata: "namespace": namespace
		}
	}
}

#AddLabels: v1.#Transformer & {
	v1.#Component
	labels: [string]: string

	$resources: [_]: this={
		if this.$metadata.labels.driver == "kubernetes" {
			_#KubernetesMeta
			metadata: "labels": labels
		}
	}
}

#AddAnnotations: v1.#Transformer & {
	v1.#Component
	annotations: [string]: string

	$resources: [_]: this={
		if this.$metadata.labels.driver == "kubernetes" {
			_#KubernetesMeta
			metadata: "annotations": annotations
		}
	}
}

#AddPodTolerations: v1.#Transformer & {
	v1.#Component
	traits.#Workload
	$metadata: _

	podTolerations: [...corev1.#Toleration]

	$resources: [_]: this={
		if list.Contains(WorkloadTypes, this.$metadata.labels.type) {
			_#WorkloadResource & {
				spec: template: spec: tolerations: podTolerations
			}
		}
	}
}

#AddPodSecurityContext: v1.#Transformer & {
	v1.#Component
	traits.#Workload
	$metadata: _

	podSecurityContext: corev1.#PodSecurityContext

	$resources: [_]: this={
		if list.Contains(WorkloadTypes, this.$metadata.labels.type) {
			_#WorkloadResource & {
				spec: template: spec: securityContext: podSecurityContext
			}
		}
	}
}

#AddWorkloadVolumes: v1.#Transformer & {
	v1.#Component
	traits.#Workload
	traits.#Volume

	volumes:    _
	containers: _

	$resources: [_]: this={
		if list.Contains(WorkloadTypes, this.$metadata.labels.type) {
			_#WorkloadResource & {
				spec: template: spec: {
					"volumes": [
						for _, volume in volumes {
							if volume.ephemeral != _|_ {
								{
									name: volume.ephemeral
									emptyDir: {}
								}
							}
							if volume.secret != _|_ {
								{
									name: volume.secret.name
									secret: {
										secretName: volume.secret.name
										optional:   false
									}
								}
							}
						},
					]
					"containers": [
						for _, container in containers {
							volumeMounts: [
								for mount in container.mounts {
									{
										if mount.volume.ephemeral != _|_ {
											name: mount.volume.ephemeral
										}
										if mount.volume.secret != _|_ {
											name: mount.volume.secret.name
										}
										mountPath: mount.path
										readOnly:  mount.readOnly
									}
								},
							]
						},
					]
				}
			}
		}
	}
}

#AddWorkloadProbes: v1.#Transformer & {
	v1.#Component
	traits.#Workload

	livenessProbe:  corev1.#Probe
	readinessProbe: corev1.#Probe

	containers: _
	$resources: [_]: this={
		if list.Contains(WorkloadTypes, this.$metadata.labels.type) {
			_#WorkloadResource & {
				spec: template: spec: "containers": [
					for _, container in containers {
						"livenessProbe":  livenessProbe
						"readinessProbe": readinessProbe
					},
				]
			}
		}
	}
}

_#IngressResource: {
	netv1.#Ingress
	$metadata: labels: {
		driver: "kubernetes"
		type:   "k8s.io/networking/v1/ingress"
	}
	kind:       "Ingress"
	apiVersion: "v1"
	metadata: name: _#KubernetesName
}

#AddIngress: v1.#Transformer & {
	traits.#HTTPRoute
	$metadata:        _
	http:             _
	ingressName:      string | *$metadata.id
	ingressClassName: string
	$resources: "\($metadata.id)-ingress": _#IngressResource & {
		metadata: name: ingressName
		spec: {
			"ingressClassName": ingressClassName
			let routeRules = [ for rule in http.rules {
				http: {
					paths: [{
						if strings.HasSuffix(rule.match.path, "*") {
							path:     strings.TrimSuffix(rule.match.path, "*")
							pathType: "Prefix"
						}
						if !strings.HasSuffix(rule.match.path, "*") {
							path:     rule.match.path
							pathType: "Exact"
						}

						for backend in rule.backends {
							"backend": service: {
								name: backend.endpoint.host
								port: number: backend.port
							}
						}
					}]
				}
			}]
			rules: [
				for hostname in http.hostnames for rule in routeRules {
					{
						host: hostname
						rule
					}
				},
				if len(http.hostnames) == 0 for rule in routeRules {
					{
						rule
					}
				},
			]
		}
	}
}

#AddUser: v1.#Transformer & {
	traits.#User
	users: [string]: {
		username: string
		password: {
			name:     "\(username)"
			property: "password"
		}
	}
}

#AddKubernetesResources: v1.#Transformer & {
	traits.#KubernetesResources
	$metadata:    _
	k8sResources: _
	$resources: {
		for name, resource in k8sResources {
			"\($metadata.id)-\(name)": {
				$metadata: labels: {
					driver: "kubernetes"
					type:   "\(apiVersion)/\(strings.ToLower(kind))"
				}
				apiVersion: string
				kind:       string
				resource
			}
		}
	}
}

_#CronJobResource: {
	$metadata: labels: {
		driver: "kubernetes"
		type:   "k8s.io/batch/v1/cronjob"
	}
	kind:       "CronJob"
	apiVersion: "batch/v1"
	metadata: name: _#KubernetesName
	spec: {
		schedule: =~"((((\\d+,)+\\d+|(\\d+(\\/|-)\\d+)|\\d+|\\*) ?){5,7})"
		jobTemplate: spec: {
			template: corev1.#PodTemplateSpec
			...
		}
	}
}

#AddCronJob: v1.#Transformer & {
	traits.#Cronable
	traits.#Workload
	$metadata:   _
	cron:        _
	containers:  _
	cronJobName: string | *$metadata.id
	$resources: "\($metadata.id)-cron-job": _#CronJobResource & {
		metadata: name: cronJobName
		spec: {
			schedule: cron.schedule
			jobTemplate: spec: template: {
				spec: {
					"containers": _#ContainersSpec & {
						#InputContainers: containers
					}
					restartPolicy: "OnFailure"
				}
			}
		}
	}
}
