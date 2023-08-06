package environments

import (
	"stakpak.dev/devx/v2alpha1"
	"stakpak.dev/devx/v1/traits"
	tfaws "stakpak.dev/devx/v1/transformers/terraform/aws"
)

#ECS: v2alpha1.#StackBuilder & {
	config: {
		aws: {
			region:  string
			account: string
		}
		vpc: name: string
		ecs: {
			name:       string
			launchType: string
		}
		secrets: {
			service: *"ParameterStore" | "SecretsManager"
		}
		gateway?: traits.#GatewaySpec
	}

	taskfile: {
		vars: {
			AWS_REGION:  config.aws.region
			AWS_ACCOUNT: config.aws.account
		}
		tasks: {
			build: {
				preconditions: [{
					sh:  "[ {{.IMAGE_NAME}} != '<no value>' ]"
					msg: "variable IMAGE_NAME is not set. please set taskfile.tasks.{{.TASK}}.vars.IMAGE_NAME or run the task with the IMAGE_NAME env var set"
				}]
				cmds: [
					"docker build . -t {{.AWS_ACCOUNT}}.dkr.ecr.{{.AWS_REGION}}.amazonaws.com/{{.IMAGE_NAME}} -t {{.IMAGE_NAME}} {{.CLI_ARGS}}",
				]
			}
			push: {
				vars: build.vars
				cmds: [
					"aws ecr get-login-password --region {{.AWS_REGION}}  | docker login --username AWS --password-stdin {{.AWS_ACCOUNT}}.dkr.ecr.{{.AWS_REGION}}.amazonaws.com",
					"docker push {{.AWS_ACCOUNT}}.dkr.ecr.{{.AWS_REGION}}.amazonaws.com/{{.IMAGE_NAME}} {{.CLI_ARGS}}",
				]
			}
			apply: {
				cmds: [
					"terraform apply",
					...,
				]
			}
			"apply-auto": {
				cmds: [
					"terraform apply -auto-approve",
					...,
				]
			}
		}
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
		if config.secrets.service == "SecretsManager" {
			"add-secretmanager-key": pipeline: [
				tfaws.#AddSecretManagerKey & {
					aws: config.aws
				},
			]
		}
		if config.secrets.service == "ParameterStore" {
			"add-ssm-secret-key": pipeline: [
				tfaws.#AddSSMSecretKey & {
					aws: config.aws
				},
			]
			"terraform/add-ssm-secret-value": {
				match: labels: secrets: "create"
				pipeline: [
					tfaws.#AddSSMSecretParameter,
				]
			}
		}
		"terraform/add-ecs-service": pipeline: [
			tfaws.#AddECSService & {
				aws: {
					config.aws
					vpc: config.vpc
				}
				clusterName: config.ecs.name
				launchType:  config.ecs.launchType
			},
			tfaws.#AddECSServiceRollout,
		]
		"terraform/expose-ecs-service": pipeline: [tfaws.#ExposeECSService & {
			aws: vpc: config.vpc
			clusterName: config.ecs.name
		}]
		"terraform/add-ecs-replicas": pipeline: [tfaws.#AddECSReplicas]
		"terraform/add-ecs-http-routes": pipeline: [tfaws.#AddHTTPRouteECS]
		"terraform/add-http-route": pipeline: [tfaws.#AddHTTPRoute & {aws: vpc: config.vpc}]
		"terraform/add-efs-volumes": pipeline: [tfaws.#AddEFSVolume & {aws: vpc: config.vpc}]
		"terraform/add-ecs-efs-volumes": pipeline: [tfaws.#AddECSVolumeEFS & {aws: vpc: config.vpc}]
	}
}
