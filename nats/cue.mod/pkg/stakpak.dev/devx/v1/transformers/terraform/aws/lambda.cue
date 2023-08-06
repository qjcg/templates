package aws

import (
	"strings"
	"encoding/json"
	"strconv"
	"stakpak.dev/devx/v1"
	"stakpak.dev/devx/v1/traits"
	resources "stakpak.dev/devx/v1/resources/aws"
	schema "stakpak.dev/devx/v1/transformers/terraform"
)

// add a Lambda function using a container image
#AddLambda: v1.#Transformer & {
	traits.#Workload
	$metadata:  _
	containers: _

	aws: {
		region:  string
		account: string
		// vpc: {
		// 	name: string
		// 	...
		// }
		lambda: {
			timeout: uint | *5
			...
		}
		...
	}
	appName: string | *$metadata.id
	$resources: terraform: schema.#Terraform & {
		data: {
			// aws_vpc: "\(aws.vpc.name)": tags: Name: aws.vpc.name
			// aws_subnets: "\(aws.vpc.name)": {
			// 	filter: [
			// 		{
			// 			name: "vpc-id"
			// 			values: ["${data.aws_vpc.\(aws.vpc.name).id}"]
			// 		},
			// 		{
			// 			name: "mapPublicIpOnLaunch"
			// 			values: ["false"]
			// 		},
			// 	]
			// }
		}
		resource: {
			aws_cloudwatch_log_group: "\(appName)": {
				name:              "/aws/lambda/\(appName)"
				retention_in_days: 14
			}
			aws_iam_role: "lambda_\(appName)": {
				name:               "lambda-\(appName)"
				assume_role_policy: json.Marshal(resources.#IAMPolicy &
					{
						Version: "2012-10-17"
						Statement: [{
							Sid:    "Lambda"
							Effect: "Allow"
							Principal: Service: "lambda.amazonaws.com"
							Action: "sts:AssumeRole"
						}]
					})
			}
			aws_iam_role_policy: "lambda_\(appName)_default": {
				name:   "lambda-\(appName)-default"
				role:   "${aws_iam_role.lambda_\(appName).name}"
				policy: json.Marshal(resources.#IAMPolicy &
					{
						Version: "2012-10-17"
						Statement: [
							{
								Effect: "Allow"
								Action: [
									"logs:DescribeLogGroups",
								]
								Resource: "*"
							},
							{
								Effect: "Allow"
								Action: [
									"logs:CreateLogStream",
									"logs:DescribeLogStreams",
									"logs:PutLogEvents",
								]
								Resource: "${aws_cloudwatch_log_group.\(appName).arn}"
							},
							{
								Sid:    "LambdaSecret"
								Effect: "Allow"
								Action: [
									"ssm:GetParameters",
									"secretsmanager:GetSecretValue",
									"kms:Decrypt",
								]
								let arns = {
									for _, v in containers.default.env if (v & v1.#Secret) != _|_ {
										if strings.HasPrefix(v.key, "arn:aws:secretsmanager:") {
											"arn:aws:secretsmanager:\(aws.region):\(aws.account):secret:\(v.name)-??????": null
										}
										if strings.HasPrefix(v.key, "arn:aws:ssm:") {
											"\(v.key)": null
										}
									}
								}
								Resource: [
									"arn:aws:kms:\(aws.region):\(aws.account):key/*",
									for arn, _ in arns {arn},
								]
							},
						]
					})
			}
			aws_lambda_function: "\(appName)": {
				function_name: appName
				package_type:  "Image"
				image_uri:     containers.default.image
				role:          "${aws_iam_role.lambda_\(appName).arn}"

				if containers.default.resources.requests.memory != _|_ {
					memory_size: strconv.Atoi(strings.TrimSuffix(containers.default.resources.requests.memory, "M"))
				}

				environment: variables: {
					for k, v in containers.default.env {
						if (v & string) != _|_ {
							"\(k)": v
						}
					}
				}

				source_code_hash: "${uuid()}"

				timeout: aws.lambda.timeout
				// vpc_config: {
				// 	subnet_ids: "${data.aws_subnets.\(aws.vpc.name).ids}"
				// 	security_group_ids: [aws_security_group.example.id]
				// }
			}
		}
	}
}
