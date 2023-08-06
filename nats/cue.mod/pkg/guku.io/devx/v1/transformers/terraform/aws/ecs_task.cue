package aws

import "strings"

_#TaskDefinition: {
	// Intellisense for Amazon ECS Task Definition schema version
	// v1.2.0, based on AWS SDK for Go version v1.33.9.
	@jsonschema(schema="http://json-schema.org/draft-07/schema#")

	// You must specify a family for a task definition, which allows
	// you to track multiple versions of the same task definition.
	// The family is used as a name for your task definition. Up to
	// 255 letters (uppercase and lowercase), numbers, and hyphens
	// are allowed.
	family: string

	// The short name or full Amazon Resource Name (ARN) of the IAM
	// role that containers in this task can assume. All containers
	// in this task are granted the permissions that are specified in
	// this role. For more information, see
	// https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-iam-roles.html
	// IAM Roles for Tasks in the Amazon Elastic Container Service
	// Developer Guide.
	taskRoleArn?: string

	// The Amazon Resource Name (ARN) of the task execution role that
	// grants the Amazon ECS container agent permission to make AWS
	// API calls on your behalf. The task execution IAM role is
	// required depending on the requirements of your task. For more
	// information, see
	// https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html
	// Amazon ECS task execution IAM role in the Amazon Elastic
	// Container Service Developer Guide.
	executionRoleArn?: string

	// The Docker networking mode to use for the containers in the
	// task. The valid values are none, bridge, awsvpc, and host. The
	// default Docker network mode is bridge. If you are using the
	// Fargate launch type, the awsvpc network mode is required. If
	// you are using the EC2 launch type, any network mode can be
	// used. If the network mode is set to none, you cannot specify
	// port mappings in your container definitions, and the tasks
	// containers do not have external connectivity. The host and
	// awsvpc network modes offer the highest networking performance
	// for containers because they use the EC2 network stack instead
	// of the virtualized network stack provided by the bridge mode.
	// With the host and awsvpc network modes, exposed container
	// ports are mapped directly to the corresponding host port (for
	// the host network mode) or the attached elastic network
	// interface port (for the awsvpc network mode), so you cannot
	// take advantage of dynamic host port mappings. If the network
	// mode is awsvpc, the task is allocated an elastic network
	// interface, and you must specify a NetworkConfiguration value
	// when you create a service or run a task with the task
	// definition. For more information, see
	// https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-networking.html
	// Task Networking in the Amazon Elastic Container Service
	// Developer Guide. Currently, only Amazon ECS-optimized AMIs,
	// other Amazon Linux variants with the ecs-init package, or AWS
	// Fargate infrastructure support the awsvpc network mode. If the
	// network mode is host, you cannot run multiple instantiations
	// of the same task on a single container instance when port
	// mappings are used. Docker for Windows uses different network
	// modes than Docker for Linux. When you register a task
	// definition with Windows containers, you must not specify a
	// network mode. If you use the console to register a task
	// definition with Windows containers, you must choose the
	// <default> network mode object. For more information, see
	// https://docs.docker.com/engine/reference/run/#network-settings
	// Network settings in the Docker run reference.
	networkMode?: "bridge" | "host" | "awsvpc" | "none"

	// A list of container definitions in JSON format that describe
	// the different containers that make up your task.
	containerDefinitions: [..._#ContainerDefinition]

	// A list of volume definitions in JSON format that containers in
	// your task may use.
	volumes?: [...{
		// The name of the volume. Up to 255 letters (uppercase and
		// lowercase), numbers, and hyphens are allowed. This name is
		// referenced in the sourceVolume parameter of container
		// definition mountPoints.
		name?: string

		// This parameter is specified when you are using bind mount host
		// volumes. The contents of the host parameter determine whether
		// your bind mount host volume persists on the host container
		// instance and where it is stored. If the host parameter is
		// empty, then the Docker daemon assigns a host path for your
		// data volume. However, the data is not guaranteed to persist
		// after the containers associated with it stop running. Windows
		// containers can mount whole directories on the same drive as
		// $env:ProgramData. Windows containers cannot mount directories
		// on a different drive, and mount point cannot be across drives.
		// For example, you can mount C:\my\path:C:\my\path and D:\:D:\,
		// but not D:\my\path:C:\my\path or D:\:C:\my\path.
		host?: {
			// When the host parameter is used, specify a sourcePath to
			// declare the path on the host container instance that is
			// presented to the container. If this parameter is empty, then
			// the Docker daemon has assigned a host path for you. If the
			// host parameter contains a sourcePath file location, then the
			// data volume persists at the specified location on the host
			// container instance until you delete it manually. If the
			// sourcePath value does not exist on the host container
			// instance, the Docker daemon creates it. If the location does
			// exist, the contents of the source path folder are exported. If
			// you are using the Fargate launch type, the sourcePath
			// parameter is not supported.
			sourcePath?: string
		}

		// This parameter is specified when you are using Docker volumes.
		// Docker volumes are only supported when you are using the EC2
		// launch type. Windows containers only support the use of the
		// local driver. To use bind mounts, specify the host parameter
		// instead.
		dockerVolumeConfiguration?: {
			// The scope for the Docker volume that determines its lifecycle.
			// Docker volumes that are scoped to a task are automatically
			// provisioned when the task starts and destroyed when the task
			// stops. Docker volumes that are scoped as shared persist after
			// the task stops.
			scope?: "task" | "shared"

			// If this value is true, the Docker volume is created if it does
			// not already exist. This field is only used if the scope is
			// shared.
			autoprovision?: bool

			// The Docker volume driver to use. The driver value must match
			// the driver name provided by Docker because it is used for task
			// placement. If the driver was installed using the Docker plugin
			// CLI, use docker plugin ls to retrieve the driver name from
			// your container instance. If the driver was installed using
			// another method, use Docker plugin discovery to retrieve the
			// driver name. For more information, see
			// https://docs.docker.com/engine/extend/plugin_api/#plugin-discovery
			// Docker plugin discovery. This parameter maps to Driver in the
			// https://docs.docker.com/engine/api/v1.35/#operation/VolumeCreate
			// Create a volume section of the
			// https://docs.docker.com/engine/api/v1.35/ Docker Remote API
			// and the xxdriver option to
			// https://docs.docker.com/engine/reference/commandline/volume_create/
			// docker volume create.
			driver?: string

			// A map of Docker driver-specific options passed through. This
			// parameter maps to DriverOpts in the
			// https://docs.docker.com/engine/api/v1.35/#operation/VolumeCreate
			// Create a volume section of the
			// https://docs.docker.com/engine/api/v1.35/ Docker Remote API
			// and the xxopt option to
			// https://docs.docker.com/engine/reference/commandline/volume_create/
			// docker volume create.
			driverOpts?: {
				"insert-key"?: string
				...
			}

			// Custom metadata to add to your Docker volume. This parameter
			// maps to Labels in the
			// https://docs.docker.com/engine/api/v1.35/#operation/VolumeCreate
			// Create a volume section of the
			// https://docs.docker.com/engine/api/v1.35/ Docker Remote API
			// and the xxlabel option to
			// https://docs.docker.com/engine/reference/commandline/volume_create/
			// docker volume create.
			labels?: {
				"insert-key"?: string
				...
			}
		}

		// This parameter is specified when you are using an Amazon
		// Elastic File System file system for task storage.
		efsVolumeConfiguration?: {
			// The Amazon EFS file system ID to use.
			fileSystemId: string

			// The directory within the Amazon EFS file system to mount as the
			// root directory inside the host. If this parameter is omitted,
			// the root of the Amazon EFS volume will be used. Specifying /
			// will have the same effect as omitting this parameter.
			rootDirectory?: string

			// Whether or not to enable encryption for Amazon EFS data in
			// transit between the Amazon ECS host and the Amazon EFS server.
			// Transit encryption must be enabled if Amazon EFS IAM
			// authorization is used. If this parameter is omitted, the
			// default value of DISABLED is used. For more information, see
			// https://docs.aws.amazon.com/efs/latest/ug/encryption-in-transit.html
			// Encrypting Data in Transit in the Amazon Elastic File System
			// User Guide.
			transitEncryption?: "ENABLED" | "DISABLED"

			// The port to use when sending encrypted data between the Amazon
			// ECS host and the Amazon EFS server. If you do not specify a
			// transit encryption port, it will use the port selection
			// strategy that the Amazon EFS mount helper uses. For more
			// information, see
			// https://docs.aws.amazon.com/efs/latest/ug/efs-mount-helper.html
			// EFS Mount Helper in the Amazon Elastic File System User Guide.
			transitEncryptionPort?: int

			// The authorization configuration details for the Amazon EFS file
			// system.
			authorizationConfig?: {
				// The Amazon EFS access point ID to use. If an access point is
				// specified, the root directory value specified in the
				// EFSVolumeConfiguration will be relative to the directory set
				// for the access point. If an access point is used, transit
				// encryption must be enabled in the EFSVolumeConfiguration. For
				// more information, see
				// https://docs.aws.amazon.com/efs/latest/ug/efs-access-points.html
				// Working with Amazon EFS Access Points in the Amazon Elastic
				// File System User Guide.
				accessPointId?: string

				// Whether or not to use the Amazon ECS task IAM role defined in a
				// task definition when mounting the Amazon EFS file system. If
				// enabled, transit encryption must be enabled in the
				// EFSVolumeConfiguration. If this parameter is omitted, the
				// default value of DISABLED is used. For more information, see
				// https://docs.aws.amazon.com/AmazonECS/latest/developerguide/efs-volumes.html#efs-volume-accesspoints
				// Using Amazon EFS Access Points in the Amazon Elastic Container
				// Service Developer Guide.
				iam?: "ENABLED" | "DISABLED"
			}
		}
	}]

	// An array of placement constraint objects to use for the task.
	// You can specify a maximum of 10 constraints per task (this
	// limit includes constraints in the task definition and those
	// specified at runtime).
	placementConstraints?: [...{
		// The type of constraint. The MemberOf constraint restricts
		// selection to be from a group of valid candidates.
		type?: "memberOf"

		// A cluster query language expression to apply to the constraint.
		// For more information, see
		// https://docs.aws.amazon.com/AmazonECS/latest/developerguide/cluster-query-language.html
		// Cluster Query Language in the Amazon Elastic Container Service
		// Developer Guide.
		expression?: string
	}]

	// The launch type required by the task. If no value is specified,
	// it defaults to EC2.
	requiresCompatibilities?: [..."EC2" | "FARGATE"]

	// The number of CPU units used by the task. It can be expressed
	// as an integer using CPU units, for example 1024, or as a
	// string using vCPUs, for example 1 vCPU or 1 vcpu, in a task
	// definition. String values are converted to an integer
	// indicating the CPU units when the task definition is
	// registered. Task-level CPU and memory parameters are ignored
	// for Windows containers. We recommend specifying
	// container-level resources for Windows containers. If you are
	// using the EC2 launch type, this field is optional. Supported
	// values are between 128 CPU units (0.125 vCPUs) and 10240 CPU
	// units (10 vCPUs). If you are using the Fargate launch type,
	// this field is required and you must use one of the following
	// values, which determines your range of supported values for
	// the memory parameter: 256 (.25 vCPU) - Available memory
	// values: 512 (0.5 GB), 1024 (1 GB), 2048 (2 GB) 512 (.5 vCPU) -
	// Available memory values: 1024 (1 GB), 2048 (2 GB), 3072 (3
	// GB), 4096 (4 GB) 1024 (1 vCPU) - Available memory values: 2048
	// (2 GB), 3072 (3 GB), 4096 (4 GB), 5120 (5 GB), 6144 (6 GB),
	// 7168 (7 GB), 8192 (8 GB) 2048 (2 vCPU) - Available memory
	// values: Between 4096 (4 GB) and 16384 (16 GB) in increments of
	// 1024 (1 GB) 4096 (4 vCPU) - Available memory values: Between
	// 8192 (8 GB) and 30720 (30 GB) in increments of 1024 (1 GB)
	cpu?: string

	// The amount of memory (in MiB) used by the task. It can be
	// expressed as an integer using MiB, for example 1024, or as a
	// string using GB, for example 1GB or 1 GB, in a task
	// definition. String values are converted to an integer
	// indicating the MiB when the task definition is registered.
	// Task-level CPU and memory parameters are ignored for Windows
	// containers. We recommend specifying container-level resources
	// for Windows containers. If using the EC2 launch type, this
	// field is optional. If using the Fargate launch type, this
	// field is required and you must use one of the following
	// values, which determines your range of supported values for
	// the cpu parameter: 512 (0.5 GB), 1024 (1 GB), 2048 (2 GB) -
	// Available cpu values: 256 (.25 vCPU) 1024 (1 GB), 2048 (2 GB),
	// 3072 (3 GB), 4096 (4 GB) - Available cpu values: 512 (.5 vCPU)
	// 2048 (2 GB), 3072 (3 GB), 4096 (4 GB), 5120 (5 GB), 6144 (6
	// GB), 7168 (7 GB), 8192 (8 GB) - Available cpu values: 1024 (1
	// vCPU) Between 4096 (4 GB) and 16384 (16 GB) in increments of
	// 1024 (1 GB) - Available cpu values: 2048 (2 vCPU) Between 8192
	// (8 GB) and 30720 (30 GB) in increments of 1024 (1 GB) -
	// Available cpu values: 4096 (4 vCPU)
	memory?: string

	// The metadata that you apply to the task definition to help you
	// categorize and organize them. Each tag consists of a key and
	// an optional value, both of which you define. The following
	// basic restrictions apply to tags: Maximum number of tags per
	// resource - 50 For each resource, each tag key must be unique,
	// and each tag key can have only one value. Maximum key length -
	// 128 Unicode characters in UTF-8 Maximum value length - 256
	// Unicode characters in UTF-8 If your tagging schema is used
	// across multiple services and resources, remember that other
	// services may have restrictions on allowed characters.
	// Generally allowed characters are: letters, numbers, and spaces
	// representable in UTF-8, and the following characters: + - = .
	// _ : / @. Tag keys and values are case-sensitive. Do not use
	// aws:, AWS:, or any upper or lowercase combination of such as a
	// prefix for either keys or values as it is reserved for AWS
	// use. You cannot edit or delete tag keys or values with this
	// prefix. Tags with this prefix do not count against your tags
	// per resource limit.
	tags?: [...{
		// One part of a key-value pair that make up a tag. A key is a
		// general label that acts like a category for more specific tag
		// values.
		key?: strings.MaxRunes(128) & strings.MinRunes(1) & =~"^([\\p{L}\\p{Z}\\p{N}_.:/=+\\-@]*)$"

		// The optional part of a key-value pair that make up a tag. A
		// value acts as a descriptor within a tag category (key).
		value?: strings.MaxRunes(256) & strings.MinRunes(0) & =~"^([\\p{L}\\p{Z}\\p{N}_.:/=+\\-@]*)$"
	}]

	// The process namespace to use for the containers in the task.
	// The valid values are host or task. If host is specified, then
	// all containers within the tasks that specified the host PID
	// mode on the same container instance share the same process
	// namespace with the host Amazon EC2 instance. If task is
	// specified, all containers within the specified task share the
	// same process namespace. If no value is specified, the default
	// is a private namespace. For more information, see
	// https://docs.docker.com/engine/reference/run/#pid-settings---pid
	// PID settings in the Docker run reference. If the host PID mode
	// is used, be aware that there is a heightened risk of undesired
	// process namespace expose. For more information, see
	// https://docs.docker.com/engine/security/security/ Docker
	// security. This parameter is not supported for Windows
	// containers or tasks using the Fargate launch type.
	pidMode?: "host" | "task"

	// The IPC resource namespace to use for the containers in the
	// task. The valid values are host, task, or none. If host is
	// specified, then all containers within the tasks that specified
	// the host IPC mode on the same container instance share the
	// same IPC resources with the host Amazon EC2 instance. If task
	// is specified, all containers within the specified task share
	// the same IPC resources. If none is specified, then IPC
	// resources within the containers of a task are private and not
	// shared with other containers in a task or on the container
	// instance. If no value is specified, then the IPC resource
	// namespace sharing depends on the Docker daemon setting on the
	// container instance. For more information, see
	// https://docs.docker.com/engine/reference/run/#ipc-settings---ipc
	// IPC settings in the Docker run reference. If the host IPC mode
	// is used, be aware that there is a heightened risk of undesired
	// IPC namespace expose. For more information, see
	// https://docs.docker.com/engine/security/security/ Docker
	// security. If you are setting namespaced kernel parameters
	// using systemControls for the containers in the task, the
	// following will apply to your IPC resource namespace. For more
	// information, see
	// https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html
	// System Controls in the Amazon Elastic Container Service
	// Developer Guide. For tasks that use the host IPC mode, IPC
	// namespace related systemControls are not supported. For tasks
	// that use the task IPC mode, IPC namespace related
	// systemControls will apply to all containers within a task.
	// This parameter is not supported for Windows containers or
	// tasks using the Fargate launch type.
	ipcMode?: "host" | "task" | "none"

	// No description available
	proxyConfiguration?: {
		// The proxy type. The only supported value is APPMESH.
		type?: "APPMESH"

		// The name of the container that will serve as the App Mesh
		// proxy.
		containerName: string

		// The set of network configuration parameters to provide the
		// Container Network Interface (CNI) plugin, specified as
		// key-value pairs. IgnoredUID - (Required) The user ID (UID) of
		// the proxy container as defined by the user parameter in a
		// container definition. This is used to ensure the proxy ignores
		// its own traffic. If IgnoredGID is specified, this field can be
		// empty. IgnoredGID - (Required) The group ID (GID) of the proxy
		// container as defined by the user parameter in a container
		// definition. This is used to ensure the proxy ignores its own
		// traffic. If IgnoredUID is specified, this field can be empty.
		// AppPorts - (Required) The list of ports that the application
		// uses. Network traffic to these ports is forwarded to the
		// ProxyIngressPort and ProxyEgressPort. ProxyIngressPort -
		// (Required) Specifies the port that incoming traffic to the
		// AppPorts is directed to. ProxyEgressPort - (Required)
		// Specifies the port that outgoing traffic from the AppPorts is
		// directed to. EgressIgnoredPorts - (Required) The egress
		// traffic going to the specified ports is ignored and not
		// redirected to the ProxyEgressPort. It can be an empty list.
		// EgressIgnoredIPs - (Required) The egress traffic going to the
		// specified IP addresses is ignored and not redirected to the
		// ProxyEgressPort. It can be an empty list.
		properties?: [...{
			// The name of the key-value pair. For environment variables, this
			// is the name of the environment variable.
			name?: string

			// The value of the key-value pair. For environment variables,
			// this is the value of the environment variable.
			value?: string
		}]
	}

	// The Elastic Inference accelerators to use for the containers in
	// the task.
	inferenceAccelerators?: [...{
		// The Elastic Inference accelerator device name. The deviceName
		// must also be referenced in a container definition as a
		// ResourceRequirement.
		deviceName: string

		// The Elastic Inference accelerator type to use.
		deviceType: string
	}]
}

_#ContainerDefinition: {
	// The name of a container. If you are linking multiple containers
	// together in a task definition, the name of one container can
	// be entered in the links of another container to connect the
	// containers. Up to 255 letters (uppercase and lowercase),
	// numbers, and hyphens are allowed. This parameter maps to name
	// in the
	// https://docs.docker.com/engine/api/v1.35/#operation/ContainerCreate
	// Create a container section of the
	// https://docs.docker.com/engine/api/v1.35/ Docker Remote API
	// and the --name option to
	// https://docs.docker.com/engine/reference/run/ docker run.
	name?: string

	// The image used to start a container. This string is passed
	// directly to the Docker daemon. Images in the Docker Hub
	// registry are available by default. Other repositories are
	// specified with either repository-url/image:tag or
	// repository-url/image@digest . Up to 255 letters (uppercase and
	// lowercase), numbers, hyphens, underscores, colons, periods,
	// forward slashes, and number signs are allowed. This parameter
	// maps to Image in the
	// https://docs.docker.com/engine/api/v1.35/#operation/ContainerCreate
	// Create a container section of the
	// https://docs.docker.com/engine/api/v1.35/ Docker Remote API
	// and the IMAGE parameter of
	// https://docs.docker.com/engine/reference/run/ docker run. When
	// a new task starts, the Amazon ECS container agent pulls the
	// latest version of the specified image and tag for the
	// container to use. However, subsequent updates to a repository
	// image are not propagated to already running tasks. Images in
	// Amazon ECR repositories can be specified by either using the
	// full registry/repository:tag or registry/repository@digest.
	// For example,
	// 012345678910.dkr.ecr.<region-name>.amazonaws.com/<repository-name>:latest
	// or
	// 012345678910.dkr.ecr.<region-name>.amazonaws.com/<repository-name>@sha256:94afd1f2e64d908bc90dbca0035a5b567EXAMPLE.
	// Images in official repositories on Docker Hub use a single
	// name (for example, ubuntu or mongo). Images in other
	// repositories on Docker Hub are qualified with an organization
	// name (for example, amazon/amazon-ecs-agent). Images in other
	// online repositories are qualified further by a domain name
	// (for example, quay.io/assemblyline/ubuntu).
	image?: string

	// The private repository authentication credentials to use.
	repositoryCredentials?: {
		// The Amazon Resource Name (ARN) of the secret containing the
		// private repository credentials. When you are using the Amazon
		// ECS API, AWS CLI, or AWS SDK, if the secret exists in the same
		// Region as the task that you are launching then you can use
		// either the full ARN or the name of the secret. When you are
		// using the AWS Management Console, you must specify the full
		// ARN of the secret.
		credentialsParameter: string
	}

	// The number of cpu units reserved for the container. This
	// parameter maps to CpuShares in the
	// https://docs.docker.com/engine/api/v1.35/#operation/ContainerCreate
	// Create a container section of the
	// https://docs.docker.com/engine/api/v1.35/ Docker Remote API
	// and the --cpu-shares option to
	// https://docs.docker.com/engine/reference/run/ docker run. This
	// field is optional for tasks using the Fargate launch type, and
	// the only requirement is that the total amount of CPU reserved
	// for all containers within a task be lower than the task-level
	// cpu value. You can determine the number of CPU units that are
	// available per EC2 instance type by multiplying the vCPUs
	// listed for that instance type on the
	// http://aws.amazon.com/ec2/instance-types/ Amazon EC2 Instances
	// detail page by 1,024. Linux containers share unallocated CPU
	// units with other containers on the container instance with the
	// same ratio as their allocated amount. For example, if you run
	// a single-container task on a single-core instance type with
	// 512 CPU units specified for that container, and that is the
	// only task running on the container instance, that container
	// could use the full 1,024 CPU unit share at any given time.
	// However, if you launched another copy of the same task on that
	// container instance, each task would be guaranteed a minimum of
	// 512 CPU units when needed, and each container could float to
	// higher CPU usage if the other container was not using it, but
	// if both tasks were 100% active all of the time, they would be
	// limited to 512 CPU units. On Linux container instances, the
	// Docker daemon on the container instance uses the CPU value to
	// calculate the relative CPU share ratios for running
	// containers. For more information, see
	// https://docs.docker.com/engine/reference/run/#cpu-share-constraint
	// CPU share constraint in the Docker documentation. The minimum
	// valid CPU share value that the Linux kernel allows is 2.
	// However, the CPU parameter is not required, and you can use
	// CPU values below 2 in your container definitions. For CPU
	// values below 2 (including null), the behavior varies based on
	// your Amazon ECS container agent version: Agent versions less
	// than or equal to 1.1.0: Null and zero CPU values are passed to
	// Docker as 0, which Docker then converts to 1,024 CPU shares.
	// CPU values of 1 are passed to Docker as 1, which the Linux
	// kernel converts to two CPU shares. Agent versions greater than
	// or equal to 1.2.0: Null, zero, and CPU values of 1 are passed
	// to Docker as 2. On Windows container instances, the CPU limit
	// is enforced as an absolute limit, or a quota. Windows
	// containers only have access to the specified amount of CPU
	// that is described in the task definition.
	cpu?: int

	// The amount (in MiB) of memory to present to the container. If
	// your container attempts to exceed the memory specified here,
	// the container is killed. The total amount of memory reserved
	// for all containers within a task must be lower than the task
	// memory value, if one is specified. This parameter maps to
	// Memory in the
	// https://docs.docker.com/engine/api/v1.35/#operation/ContainerCreate
	// Create a container section of the
	// https://docs.docker.com/engine/api/v1.35/ Docker Remote API
	// and the --memory option to
	// https://docs.docker.com/engine/reference/run/ docker run. If
	// using the Fargate launch type, this parameter is optional. If
	// using the EC2 launch type, you must specify either a
	// task-level memory value or a container-level memory value. If
	// you specify both a container-level memory and
	// memoryReservation value, memory must be greater than
	// memoryReservation. If you specify memoryReservation, then that
	// value is subtracted from the available memory resources for
	// the container instance on which the container is placed.
	// Otherwise, the value of memory is used. The Docker daemon
	// reserves a minimum of 4 MiB of memory for a container, so you
	// should not specify fewer than 4 MiB of memory for your
	// containers.
	memory?: int

	// The soft limit (in MiB) of memory to reserve for the container.
	// When system memory is under heavy contention, Docker attempts
	// to keep the container memory to this soft limit. However, your
	// container can consume more memory when it needs to, up to
	// either the hard limit specified with the memory parameter (if
	// applicable), or all of the available memory on the container
	// instance, whichever comes first. This parameter maps to
	// MemoryReservation in the
	// https://docs.docker.com/engine/api/v1.35/#operation/ContainerCreate
	// Create a container section of the
	// https://docs.docker.com/engine/api/v1.35/ Docker Remote API
	// and the --memory-reservation option to
	// https://docs.docker.com/engine/reference/run/ docker run. If a
	// task-level memory value is not specified, you must specify a
	// non-zero integer for one or both of memory or
	// memoryReservation in a container definition. If you specify
	// both, memory must be greater than memoryReservation. If you
	// specify memoryReservation, then that value is subtracted from
	// the available memory resources for the container instance on
	// which the container is placed. Otherwise, the value of memory
	// is used. For example, if your container normally uses 128 MiB
	// of memory, but occasionally bursts to 256 MiB of memory for
	// short periods of time, you can set a memoryReservation of 128
	// MiB, and a memory hard limit of 300 MiB. This configuration
	// would allow the container to only reserve 128 MiB of memory
	// from the remaining resources on the container instance, but
	// also allow the container to consume more memory resources when
	// needed. The Docker daemon reserves a minimum of 4 MiB of
	// memory for a container, so you should not specify fewer than 4
	// MiB of memory for your containers.
	memoryReservation?: int

	// The links parameter allows containers to communicate with each
	// other without the need for port mappings. This parameter is
	// only supported if the network mode of a task definition is
	// bridge. The name:internalName construct is analogous to
	// name:alias in Docker links. Up to 255 letters (uppercase and
	// lowercase), numbers, and hyphens are allowed. For more
	// information about linking Docker containers, go to
	// https://docs.docker.com/network/links/ Legacy container links
	// in the Docker documentation. This parameter maps to Links in
	// the
	// https://docs.docker.com/engine/api/v1.35/#operation/ContainerCreate
	// Create a container section of the
	// https://docs.docker.com/engine/api/v1.35/ Docker Remote API
	// and the --link option to
	// https://docs.docker.com/engine/reference/run/ docker run. This
	// parameter is not supported for Windows containers. Containers
	// that are collocated on a single container instance may be able
	// to communicate with each other without requiring links or host
	// port mappings. Network isolation is achieved on the container
	// instance using security groups and VPC settings.
	links?: [...string]

	// The list of port mappings for the container. Port mappings
	// allow containers to access ports on the host container
	// instance to send or receive traffic. For task definitions that
	// use the awsvpc network mode, you should only specify the
	// containerPort. The hostPort can be left blank or it must be
	// the same value as the containerPort. Port mappings on Windows
	// use the NetNAT gateway address rather than localhost. There is
	// no loopback for port mappings on Windows, so you cannot access
	// a container's mapped port from the host itself. This parameter
	// maps to PortBindings in the
	// https://docs.docker.com/engine/api/v1.35/#operation/ContainerCreate
	// Create a container section of the
	// https://docs.docker.com/engine/api/v1.35/ Docker Remote API
	// and the --publish option to
	// https://docs.docker.com/engine/reference/run/ docker run. If
	// the network mode of a task definition is set to none, then you
	// can't specify port mappings. If the network mode of a task
	// definition is set to host, then host ports must either be
	// undefined or they must match the container port in the port
	// mapping. After a task reaches the RUNNING status, manual and
	// automatic host and container port assignments are visible in
	// the Network Bindings section of a container description for a
	// selected task in the Amazon ECS console. The assignments are
	// also visible in the networkBindings section DescribeTasks
	// responses.
	portMappings?: [...{
		// The port number on the container that is bound to the
		// user-specified or automatically assigned host port. If you are
		// using containers in a task with the awsvpc or host network
		// mode, exposed ports should be specified using containerPort.
		// If you are using containers in a task with the bridge network
		// mode and you specify a container port and not a host port,
		// your container automatically receives a host port in the
		// ephemeral port range. For more information, see hostPort. Port
		// mappings that are automatically assigned in this way do not
		// count toward the 100 reserved ports limit of a container
		// instance. You cannot expose the same container port for
		// multiple protocols. An error will be returned if this is
		// attempted.
		containerPort?: int

		// The port number on the container instance to reserve for your
		// container. If you are using containers in a task with the
		// awsvpc or host network mode, the hostPort can either be left
		// blank or set to the same value as the containerPort. If you
		// are using containers in a task with the bridge network mode,
		// you can specify a non-reserved host port for your container
		// port mapping, or you can omit the hostPort (or set it to 0)
		// while specifying a containerPort and your container
		// automatically receives a port in the ephemeral port range for
		// your container instance operating system and Docker version.
		// The default ephemeral port range for Docker version 1.6.0 and
		// later is listed on the instance under
		// /proc/sys/net/ipv4/ip_local_port_range. If this kernel
		// parameter is unavailable, the default ephemeral port range
		// from 49153 through 65535 is used. Do not attempt to specify a
		// host port in the ephemeral port range as these are reserved
		// for automatic assignment. In general, ports below 32768 are
		// outside of the ephemeral port range. The default ephemeral
		// port range from 49153 through 65535 is always used for Docker
		// versions before 1.6.0. The default reserved ports are 22 for
		// SSH, the Docker ports 2375 and 2376, and the Amazon ECS
		// container agent ports 51678-51680. Any host port that was
		// previously specified in a running task is also reserved while
		// the task is running (after a task stops, the host port is
		// released). The current reserved ports are displayed in the
		// remainingResources of DescribeContainerInstances output. A
		// container instance can have up to 100 reserved ports at a
		// time, including the default reserved ports. Automatically
		// assigned ports don't count toward the 100 reserved ports
		// limit.
		hostPort?: int

		// The protocol used for the port mapping. Valid values are tcp
		// and udp. The default is tcp.
		protocol?: "tcp" | "udp"
	}]

	// If the essential parameter of a container is marked as true,
	// and that container fails or stops for any reason, all other
	// containers that are part of the task are stopped. If the
	// essential parameter of a container is marked as false, then
	// its failure does not affect the rest of the containers in a
	// task. If this parameter is omitted, a container is assumed to
	// be essential. All tasks must have at least one essential
	// container. If you have an application that is composed of
	// multiple containers, you should group containers that are used
	// for a common purpose into components, and separate the
	// different components into multiple task definitions. For more
	// information, see
	// https://docs.aws.amazon.com/AmazonECS/latest/developerguide/application_architecture.html
	// Application Architecture in the Amazon Elastic Container
	// Service Developer Guide.
	essential?: bool

	// Early versions of the Amazon ECS container agent do not
	// properly handle entryPoint parameters. If you have problems
	// using entryPoint, update your container agent or enter your
	// commands and arguments as command array items instead. The
	// entry point that is passed to the container. This parameter
	// maps to Entrypoint in the
	// https://docs.docker.com/engine/api/v1.35/#operation/ContainerCreate
	// Create a container section of the
	// https://docs.docker.com/engine/api/v1.35/ Docker Remote API
	// and the --entrypoint option to
	// https://docs.docker.com/engine/reference/run/ docker run. For
	// more information, see
	// https://docs.docker.com/engine/reference/builder/#entrypoint
	// https://docs.docker.com/engine/reference/builder/#entrypoint.
	entryPoint?: [...string]

	// The command that is passed to the container. This parameter
	// maps to Cmd in the
	// https://docs.docker.com/engine/api/v1.35/#operation/ContainerCreate
	// Create a container section of the
	// https://docs.docker.com/engine/api/v1.35/ Docker Remote API
	// and the COMMAND parameter to
	// https://docs.docker.com/engine/reference/run/ docker run. For
	// more information, see
	// https://docs.docker.com/engine/reference/builder/#cmd
	// https://docs.docker.com/engine/reference/builder/#cmd. If
	// there are multiple arguments, each argument should be a
	// separated string in the array.
	command?: [...string]

	// The environment variables to pass to a container. This
	// parameter maps to Env in the
	// https://docs.docker.com/engine/api/v1.35/#operation/ContainerCreate
	// Create a container section of the
	// https://docs.docker.com/engine/api/v1.35/ Docker Remote API
	// and the --env option to
	// https://docs.docker.com/engine/reference/run/ docker run. We
	// do not recommend using plaintext environment variables for
	// sensitive information, such as credential data.
	environment?: [...{
		// The name of the key-value pair. For environment variables, this
		// is the name of the environment variable.
		name?: string

		// The value of the key-value pair. For environment variables,
		// this is the value of the environment variable.
		value?: string
	}]

	// A list of files containing the environment variables to pass to
	// a container. This parameter maps to the --env-file option to
	// https://docs.docker.com/engine/reference/run/ docker run. You
	// can specify up to ten environment files. The file must have a
	// .env file extension. Each line in an environment file should
	// contain an environment variable in VARIABLE=VALUE format.
	// Lines beginning with # are treated as comments and are
	// ignored. For more information on the environment variable file
	// syntax, see https://docs.docker.com/compose/env-file/ Declare
	// default environment variables in file. If there are
	// environment variables specified using the environment
	// parameter in a container definition, they take precedence over
	// the variables contained within an environment file. If
	// multiple environment files are specified that contain the same
	// variable, they are processed from the top down. It is
	// recommended to use unique variable names. For more
	// information, see
	// https://docs.aws.amazon.com/AmazonECS/latest/developerguide/taskdef-envfiles.html
	// Specifying Environment Variables in the Amazon Elastic
	// Container Service Developer Guide. This field is not valid for
	// containers in tasks using the Fargate launch type.
	environmentFiles?: [...{
		// The Amazon Resource Name (ARN) of the Amazon S3 object
		// containing the environment variable file.
		value: string

		// The file type to use. The only supported value is s3.
		type: "s3"
	}]

	// The mount points for data volumes in your container. This
	// parameter maps to Volumes in the
	// https://docs.docker.com/engine/api/v1.35/#operation/ContainerCreate
	// Create a container section of the
	// https://docs.docker.com/engine/api/v1.35/ Docker Remote API
	// and the --volume option to
	// https://docs.docker.com/engine/reference/run/ docker run.
	// Windows containers can mount whole directories on the same
	// drive as $env:ProgramData. Windows containers cannot mount
	// directories on a different drive, and mount point cannot be
	// across drives.
	mountPoints?: [...{
		// The name of the volume to mount. Must be a volume name
		// referenced in the name parameter of task definition volume.
		sourceVolume?: string

		// The path on the container to mount the host volume at.
		containerPath?: string

		// If this value is true, the container has read-only access to
		// the volume. If this value is false, then the container can
		// write to the volume. The default value is false.
		readOnly?: bool
	}]

	// Data volumes to mount from another container. This parameter
	// maps to VolumesFrom in the
	// https://docs.docker.com/engine/api/v1.35/#operation/ContainerCreate
	// Create a container section of the
	// https://docs.docker.com/engine/api/v1.35/ Docker Remote API
	// and the --volumes-from option to
	// https://docs.docker.com/engine/reference/run/ docker run.
	volumesFrom?: [...{
		// The name of another container within the same task definition
		// from which to mount volumes.
		sourceContainer?: string

		// If this value is true, the container has read-only access to
		// the volume. If this value is false, then the container can
		// write to the volume. The default value is false.
		readOnly?: bool
	}]

	// Linux-specific modifications that are applied to the container,
	// such as Linux kernel capabilities. For more information see
	// KernelCapabilities. This parameter is not supported for
	// Windows containers.
	linuxParameters?: {
		// The Linux capabilities for the container that are added to or
		// dropped from the default configuration provided by Docker. For
		// tasks that use the Fargate launch type, capabilities is
		// supported for all platform versions but the add parameter is
		// only supported if using platform version 1.4.0 or later.
		capabilities?: {
			// The Linux capabilities for the container that have been added
			// to the default configuration provided by Docker. This
			// parameter maps to CapAdd in the
			// https://docs.docker.com/engine/api/v1.35/#operation/ContainerCreate
			// Create a container section of the
			// https://docs.docker.com/engine/api/v1.35/ Docker Remote API
			// and the --cap-add option to
			// https://docs.docker.com/engine/reference/run/ docker run. The
			// SYS_PTRACE capability is supported for tasks that use the
			// Fargate launch type if they are also using platform version
			// 1.4.0. The other capabilities are not supported for any
			// platform versions. Valid values: "ALL" | "AUDIT_CONTROL" |
			// "AUDIT_WRITE" | "BLOCK_SUSPEND" | "CHOWN" | "DAC_OVERRIDE" |
			// "DAC_READ_SEARCH" | "FOWNER" | "FSETID" | "IPC_LOCK" |
			// "IPC_OWNER" | "KILL" | "LEASE" | "LINUX_IMMUTABLE" |
			// "MAC_ADMIN" | "MAC_OVERRIDE" | "MKNOD" | "NET_ADMIN" |
			// "NET_BIND_SERVICE" | "NET_BROADCAST" | "NET_RAW" | "SETFCAP" |
			// "SETGID" | "SETPCAP" | "SETUID" | "SYS_ADMIN" | "SYS_BOOT" |
			// "SYS_CHROOT" | "SYS_MODULE" | "SYS_NICE" | "SYS_PACCT" |
			// "SYS_PTRACE" | "SYS_RAWIO" | "SYS_RESOURCE" | "SYS_TIME" |
			// "SYS_TTY_CONFIG" | "SYSLOG" | "WAKE_ALARM"
			add?: [...string]

			// The Linux capabilities for the container that have been removed
			// from the default configuration provided by Docker. This
			// parameter maps to CapDrop in the
			// https://docs.docker.com/engine/api/v1.35/#operation/ContainerCreate
			// Create a container section of the
			// https://docs.docker.com/engine/api/v1.35/ Docker Remote API
			// and the --cap-drop option to
			// https://docs.docker.com/engine/reference/run/ docker run.
			// Valid values: "ALL" | "AUDIT_CONTROL" | "AUDIT_WRITE" |
			// "BLOCK_SUSPEND" | "CHOWN" | "DAC_OVERRIDE" | "DAC_READ_SEARCH"
			// | "FOWNER" | "FSETID" | "IPC_LOCK" | "IPC_OWNER" | "KILL" |
			// "LEASE" | "LINUX_IMMUTABLE" | "MAC_ADMIN" | "MAC_OVERRIDE" |
			// "MKNOD" | "NET_ADMIN" | "NET_BIND_SERVICE" | "NET_BROADCAST" |
			// "NET_RAW" | "SETFCAP" | "SETGID" | "SETPCAP" | "SETUID" |
			// "SYS_ADMIN" | "SYS_BOOT" | "SYS_CHROOT" | "SYS_MODULE" |
			// "SYS_NICE" | "SYS_PACCT" | "SYS_PTRACE" | "SYS_RAWIO" |
			// "SYS_RESOURCE" | "SYS_TIME" | "SYS_TTY_CONFIG" | "SYSLOG" |
			// "WAKE_ALARM"
			drop?: [...string]
		}

		// Any host devices to expose to the container. This parameter
		// maps to Devices in the
		// https://docs.docker.com/engine/api/v1.35/#operation/ContainerCreate
		// Create a container section of the
		// https://docs.docker.com/engine/api/v1.35/ Docker Remote API
		// and the --device option to
		// https://docs.docker.com/engine/reference/run/ docker run. If
		// you are using tasks that use the Fargate launch type, the
		// devices parameter is not supported.
		devices?: [...{
			// The path for the device on the host container instance.
			hostPath: string

			// The path inside the container at which to expose the host
			// device.
			containerPath?: string

			// The explicit permissions to provide to the container for the
			// device. By default, the container has permissions for read,
			// write, and mknod for the device.
			permissions?: [..."read" | "write" | "mknod"]
		}]

		// Run an init process inside the container that forwards signals
		// and reaps processes. This parameter maps to the --init option
		// to https://docs.docker.com/engine/reference/run/ docker run.
		// This parameter requires version 1.25 of the Docker Remote API
		// or greater on your container instance. To check the Docker
		// Remote API version on your container instance, log in to your
		// container instance and run the following command: sudo docker
		// version --format '{{.Server.APIVersion}}'
		initProcessEnabled?: bool

		// The value for the size (in MiB) of the /dev/shm volume. This
		// parameter maps to the --shm-size option to
		// https://docs.docker.com/engine/reference/run/ docker run. If
		// you are using tasks that use the Fargate launch type, the
		// sharedMemorySize parameter is not supported.
		sharedMemorySize?: int

		// The container path, mount options, and size (in MiB) of the
		// tmpfs mount. This parameter maps to the --tmpfs option to
		// https://docs.docker.com/engine/reference/run/ docker run. If
		// you are using tasks that use the Fargate launch type, the
		// tmpfs parameter is not supported.
		tmpfs?: [...{
			// The absolute file path where the tmpfs volume is to be mounted.
			containerPath: string

			// The size (in MiB) of the tmpfs volume.
			size: int

			// The list of tmpfs volume mount options. Valid values:
			// "defaults" | "ro" | "rw" | "suid" | "nosuid" | "dev" | "nodev"
			// | "exec" | "noexec" | "sync" | "async" | "dirsync" | "remount"
			// | "mand" | "nomand" | "atime" | "noatime" | "diratime" |
			// "nodiratime" | "bind" | "rbind" | "unbindable" | "runbindable"
			// | "private" | "rprivate" | "shared" | "rshared" | "slave" |
			// "rslave" | "relatime" | "norelatime" | "strictatime" |
			// "nostrictatime" | "mode" | "uid" | "gid" | "nr_inodes" |
			// "nr_blocks" | "mpol"
			mountOptions?: [...string]
		}]

		// The total amount of swap memory (in MiB) a container can use.
		// This parameter will be translated to the --memory-swap option
		// to https://docs.docker.com/engine/reference/run/ docker run
		// where the value would be the sum of the container memory plus
		// the maxSwap value. If a maxSwap value of 0 is specified, the
		// container will not use swap. Accepted values are 0 or any
		// positive integer. If the maxSwap parameter is omitted, the
		// container will use the swap configuration for the container
		// instance it is running on. A maxSwap value must be set for the
		// swappiness parameter to be used. If you are using tasks that
		// use the Fargate launch type, the maxSwap parameter is not
		// supported.
		maxSwap?: int

		// This allows you to tune a container's memory swappiness
		// behavior. A swappiness value of 0 will cause swapping to not
		// happen unless absolutely necessary. A swappiness value of 100
		// will cause pages to be swapped very aggressively. Accepted
		// values are whole numbers between 0 and 100. If the swappiness
		// parameter is not specified, a default value of 60 is used. If
		// a value is not specified for maxSwap then this parameter is
		// ignored. This parameter maps to the --memory-swappiness option
		// to https://docs.docker.com/engine/reference/run/ docker run.
		// If you are using tasks that use the Fargate launch type, the
		// swappiness parameter is not supported.
		swappiness?: int
	}

	// The secrets to pass to the container. For more information, see
	// https://docs.aws.amazon.com/AmazonECS/latest/developerguide/specifying-sensitive-data.html
	// Specifying Sensitive Data in the Amazon Elastic Container
	// Service Developer Guide.
	secrets?: [...{
		// The name of the secret.
		name: string

		// The secret to expose to the container. The supported values are
		// either the full ARN of the AWS Secrets Manager secret or the
		// full ARN of the parameter in the AWS Systems Manager Parameter
		// Store. If the AWS Systems Manager Parameter Store parameter
		// exists in the same Region as the task you are launching, then
		// you can use either the full ARN or name of the parameter. If
		// the parameter exists in a different Region, then the full ARN
		// must be specified.
		valueFrom: string
	}]

	// The dependencies defined for container startup and shutdown. A
	// container can contain multiple dependencies. When a dependency
	// is defined for container startup, for container shutdown it is
	// reversed. For tasks using the EC2 launch type, the container
	// instances require at least version 1.26.0 of the container
	// agent to enable container dependencies. However, we recommend
	// using the latest container agent version. For information
	// about checking your agent version and updating to the latest
	// version, see
	// https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-agent-update.html
	// Updating the Amazon ECS Container Agent in the Amazon Elastic
	// Container Service Developer Guide. If you are using an Amazon
	// ECS-optimized Linux AMI, your instance needs at least version
	// 1.26.0-1 of the ecs-init package. If your container instances
	// are launched from version 20190301 or later, then they contain
	// the required versions of the container agent and ecs-init. For
	// more information, see
	// https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html
	// Amazon ECS-optimized Linux AMI in the Amazon Elastic Container
	// Service Developer Guide. For tasks using the Fargate launch
	// type, the task or service requires platform version 1.3.0 or
	// later.
	dependsOn?: [...{
		// The name of a container.
		containerName: string

		// The dependency condition of the container. The following are
		// the available conditions and their behavior: START - This
		// condition emulates the behavior of links and volumes today. It
		// validates that a dependent container is started before
		// permitting other containers to start. COMPLETE - This
		// condition validates that a dependent container runs to
		// completion (exits) before permitting other containers to
		// start. This can be useful for nonessential containers that run
		// a script and then exit. SUCCESS - This condition is the same
		// as COMPLETE, but it also requires that the container exits
		// with a zero status. HEALTHY - This condition validates that
		// the dependent container passes its Docker health check before
		// permitting other containers to start. This requires that the
		// dependent container has health checks configured. This
		// condition is confirmed only at task startup.
		condition: "START" | "COMPLETE" | "SUCCESS" | "HEALTHY"
	}]

	// Time duration (in seconds) to wait before giving up on
	// resolving dependencies for a container. For example, you
	// specify two containers in a task definition with containerA
	// having a dependency on containerB reaching a COMPLETE,
	// SUCCESS, or HEALTHY status. If a startTimeout value is
	// specified for containerB and it does not reach the desired
	// status within that time then containerA will give up and not
	// start. This results in the task transitioning to a STOPPED
	// state. For tasks using the Fargate launch type, this parameter
	// requires that the task or service uses platform version 1.3.0
	// or later. If this parameter is not specified, the default
	// value of 3 minutes is used. For tasks using the EC2 launch
	// type, if the startTimeout parameter is not specified, the
	// value set for the Amazon ECS container agent configuration
	// variable ECS_CONTAINER_START_TIMEOUT is used by default. If
	// neither the startTimeout parameter or the
	// ECS_CONTAINER_START_TIMEOUT agent configuration variable are
	// set, then the default values of 3 minutes for Linux containers
	// and 8 minutes on Windows containers are used. Your container
	// instances require at least version 1.26.0 of the container
	// agent to enable a container start timeout value. However, we
	// recommend using the latest container agent version. For
	// information about checking your agent version and updating to
	// the latest version, see
	// https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-agent-update.html
	// Updating the Amazon ECS Container Agent in the Amazon Elastic
	// Container Service Developer Guide. If you are using an Amazon
	// ECS-optimized Linux AMI, your instance needs at least version
	// 1.26.0-1 of the ecs-init package. If your container instances
	// are launched from version 20190301 or later, then they contain
	// the required versions of the container agent and ecs-init. For
	// more information, see
	// https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html
	// Amazon ECS-optimized Linux AMI in the Amazon Elastic Container
	// Service Developer Guide.
	startTimeout?: int

	// Time duration (in seconds) to wait before the container is
	// forcefully killed if it doesn't exit normally on its own. For
	// tasks using the Fargate launch type, the task or service
	// requires platform version 1.3.0 or later. The max stop timeout
	// value is 120 seconds and if the parameter is not specified,
	// the default value of 30 seconds is used. For tasks using the
	// EC2 launch type, if the stopTimeout parameter is not
	// specified, the value set for the Amazon ECS container agent
	// configuration variable ECS_CONTAINER_STOP_TIMEOUT is used by
	// default. If neither the stopTimeout parameter or the
	// ECS_CONTAINER_STOP_TIMEOUT agent configuration variable are
	// set, then the default values of 30 seconds for Linux
	// containers and 30 seconds on Windows containers are used. Your
	// container instances require at least version 1.26.0 of the
	// container agent to enable a container stop timeout value.
	// However, we recommend using the latest container agent
	// version. For information about checking your agent version and
	// updating to the latest version, see
	// https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-agent-update.html
	// Updating the Amazon ECS Container Agent in the Amazon Elastic
	// Container Service Developer Guide. If you are using an Amazon
	// ECS-optimized Linux AMI, your instance needs at least version
	// 1.26.0-1 of the ecs-init package. If your container instances
	// are launched from version 20190301 or later, then they contain
	// the required versions of the container agent and ecs-init. For
	// more information, see
	// https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html
	// Amazon ECS-optimized Linux AMI in the Amazon Elastic Container
	// Service Developer Guide.
	stopTimeout?: int

	// The hostname to use for your container. This parameter maps to
	// Hostname in the
	// https://docs.docker.com/engine/api/v1.35/#operation/ContainerCreate
	// Create a container section of the
	// https://docs.docker.com/engine/api/v1.35/ Docker Remote API
	// and the --hostname option to
	// https://docs.docker.com/engine/reference/run/ docker run. The
	// hostname parameter is not supported if you are using the
	// awsvpc network mode.
	hostname?: string

	// The user name to use inside the container. This parameter maps
	// to User in the
	// https://docs.docker.com/engine/api/v1.35/#operation/ContainerCreate
	// Create a container section of the
	// https://docs.docker.com/engine/api/v1.35/ Docker Remote API
	// and the --user option to
	// https://docs.docker.com/engine/reference/run/ docker run. You
	// can use the following formats. If specifying a UID or GID, you
	// must specify it as a positive integer. user user:group uid
	// uid:gid user:gid uid:group This parameter is not supported for
	// Windows containers.
	user?: string

	// The working directory in which to run commands inside the
	// container. This parameter maps to WorkingDir in the
	// https://docs.docker.com/engine/api/v1.35/#operation/ContainerCreate
	// Create a container section of the
	// https://docs.docker.com/engine/api/v1.35/ Docker Remote API
	// and the --workdir option to
	// https://docs.docker.com/engine/reference/run/ docker run.
	workingDirectory?: string

	// When this parameter is true, networking is disabled within the
	// container. This parameter maps to NetworkDisabled in the
	// https://docs.docker.com/engine/api/v1.35/#operation/ContainerCreate
	// Create a container section of the
	// https://docs.docker.com/engine/api/v1.35/ Docker Remote API.
	// This parameter is not supported for Windows containers.
	disableNetworking?: bool

	// When this parameter is true, the container is given elevated
	// privileges on the host container instance (similar to the root
	// user). This parameter maps to Privileged in the
	// https://docs.docker.com/engine/api/v1.35/#operation/ContainerCreate
	// Create a container section of the
	// https://docs.docker.com/engine/api/v1.35/ Docker Remote API
	// and the --privileged option to
	// https://docs.docker.com/engine/reference/run/ docker run. This
	// parameter is not supported for Windows containers or tasks
	// using the Fargate launch type.
	privileged?: bool

	// When this parameter is true, the container is given read-only
	// access to its root file system. This parameter maps to
	// ReadonlyRootfs in the
	// https://docs.docker.com/engine/api/v1.35/#operation/ContainerCreate
	// Create a container section of the
	// https://docs.docker.com/engine/api/v1.35/ Docker Remote API
	// and the --read-only option to
	// https://docs.docker.com/engine/reference/run/ docker run. This
	// parameter is not supported for Windows containers.
	readonlyRootFilesystem?: bool

	// A list of DNS servers that are presented to the container. This
	// parameter maps to Dns in the
	// https://docs.docker.com/engine/api/v1.35/#operation/ContainerCreate
	// Create a container section of the
	// https://docs.docker.com/engine/api/v1.35/ Docker Remote API
	// and the --dns option to
	// https://docs.docker.com/engine/reference/run/ docker run. This
	// parameter is not supported for Windows containers.
	dnsServers?: [...string]

	// A list of DNS search domains that are presented to the
	// container. This parameter maps to DnsSearch in the
	// https://docs.docker.com/engine/api/v1.35/#operation/ContainerCreate
	// Create a container section of the
	// https://docs.docker.com/engine/api/v1.35/ Docker Remote API
	// and the --dns-search option to
	// https://docs.docker.com/engine/reference/run/ docker run. This
	// parameter is not supported for Windows containers.
	dnsSearchDomains?: [...string]

	// A list of hostnames and IP address mappings to append to the
	// /etc/hosts file on the container. This parameter maps to
	// ExtraHosts in the
	// https://docs.docker.com/engine/api/v1.35/#operation/ContainerCreate
	// Create a container section of the
	// https://docs.docker.com/engine/api/v1.35/ Docker Remote API
	// and the --add-host option to
	// https://docs.docker.com/engine/reference/run/ docker run. This
	// parameter is not supported for Windows containers or tasks
	// that use the awsvpc network mode.
	extraHosts?: [...{
		// The hostname to use in the /etc/hosts entry.
		hostname: string

		// The IP address to use in the /etc/hosts entry.
		ipAddress: string
	}]

	// A list of strings to provide custom labels for SELinux and
	// AppArmor multi-level security systems. This field is not valid
	// for containers in tasks using the Fargate launch type. With
	// Windows containers, this parameter can be used to reference a
	// credential spec file when configuring a container for Active
	// Directory authentication. For more information, see
	// https://docs.aws.amazon.com/AmazonECS/latest/developerguide/windows-gmsa.html
	// Using gMSAs for Windows Containers in the Amazon Elastic
	// Container Service Developer Guide. This parameter maps to
	// SecurityOpt in the
	// https://docs.docker.com/engine/api/v1.35/#operation/ContainerCreate
	// Create a container section of the
	// https://docs.docker.com/engine/api/v1.35/ Docker Remote API
	// and the --security-opt option to
	// https://docs.docker.com/engine/reference/run/ docker run. The
	// Amazon ECS container agent running on a container instance
	// must register with the ECS_SELINUX_CAPABLE=true or
	// ECS_APPARMOR_CAPABLE=true environment variables before
	// containers placed on that instance can use these security
	// options. For more information, see
	// https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-agent-config.html
	// Amazon ECS Container Agent Configuration in the Amazon Elastic
	// Container Service Developer Guide.
	dockerSecurityOptions?: [...string]

	// When this parameter is true, this allows you to deploy
	// containerized applications that require stdin or a tty to be
	// allocated. This parameter maps to OpenStdin in the
	// https://docs.docker.com/engine/api/v1.35/#operation/ContainerCreate
	// Create a container section of the
	// https://docs.docker.com/engine/api/v1.35/ Docker Remote API
	// and the --interactive option to
	// https://docs.docker.com/engine/reference/run/ docker run.
	interactive?: bool

	// When this parameter is true, a TTY is allocated. This parameter
	// maps to Tty in the
	// https://docs.docker.com/engine/api/v1.35/#operation/ContainerCreate
	// Create a container section of the
	// https://docs.docker.com/engine/api/v1.35/ Docker Remote API
	// and the --tty option to
	// https://docs.docker.com/engine/reference/run/ docker run.
	pseudoTerminal?: bool

	// A key/value map of labels to add to the container. This
	// parameter maps to Labels in the
	// https://docs.docker.com/engine/api/v1.35/#operation/ContainerCreate
	// Create a container section of the
	// https://docs.docker.com/engine/api/v1.35/ Docker Remote API
	// and the --label option to
	// https://docs.docker.com/engine/reference/run/ docker run. This
	// parameter requires version 1.18 of the Docker Remote API or
	// greater on your container instance. To check the Docker Remote
	// API version on your container instance, log in to your
	// container instance and run the following command: sudo docker
	// version --format '{{.Server.APIVersion}}'
	dockerLabels?: {
		"insert-key"?: string
		...
	}

	// A list of ulimits to set in the container. If a ulimit value is
	// specified in a task definition, it will override the default
	// values set by Docker. This parameter maps to Ulimits in the
	// https://docs.docker.com/engine/api/v1.35/#operation/ContainerCreate
	// Create a container section of the
	// https://docs.docker.com/engine/api/v1.35/ Docker Remote API
	// and the --ulimit option to
	// https://docs.docker.com/engine/reference/run/ docker run.
	// Valid naming values are displayed in the Ulimit data type.
	// This parameter requires version 1.18 of the Docker Remote API
	// or greater on your container instance. To check the Docker
	// Remote API version on your container instance, log in to your
	// container instance and run the following command: sudo docker
	// version --format '{{.Server.APIVersion}}' This parameter is
	// not supported for Windows containers.
	ulimits?: [...{
		// The type of the ulimit.
		name: "core" | "cpu" | "data" | "fsize" | "locks" | "memlock" | "msgqueue" | "nice" | "nofile" | "nproc" | "rss" | "rtprio" | "rttime" | "sigpending" | "stack"

		// The soft limit for the ulimit type.
		softLimit: int

		// The hard limit for the ulimit type.
		hardLimit: int
	}]

	// The log configuration specification for the container. This
	// parameter maps to LogConfig in the
	// https://docs.docker.com/engine/api/v1.35/#operation/ContainerCreate
	// Create a container section of the
	// https://docs.docker.com/engine/api/v1.35/ Docker Remote API
	// and the --log-driver option to
	// https://docs.docker.com/engine/reference/run/ docker run. By
	// default, containers use the same logging driver that the
	// Docker daemon uses. However the container may use a different
	// logging driver than the Docker daemon by specifying a log
	// driver with this parameter in the container definition. To use
	// a different logging driver for a container, the log system
	// must be configured properly on the container instance (or on a
	// different log server for remote logging options). For more
	// information on the options for different supported log
	// drivers, see
	// https://docs.docker.com/engine/admin/logging/overview/
	// Configure logging drivers in the Docker documentation. Amazon
	// ECS currently supports a subset of the logging drivers
	// available to the Docker daemon (shown in the LogConfiguration
	// data type). Additional log drivers may be available in future
	// releases of the Amazon ECS container agent. This parameter
	// requires version 1.18 of the Docker Remote API or greater on
	// your container instance. To check the Docker Remote API
	// version on your container instance, log in to your container
	// instance and run the following command: sudo docker version
	// --format '{{.Server.APIVersion}}' The Amazon ECS container
	// agent running on a container instance must register the
	// logging drivers available on that instance with the
	// ECS_AVAILABLE_LOGGING_DRIVERS environment variable before
	// containers placed on that instance can use these log
	// configuration options. For more information, see
	// https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-agent-config.html
	// Amazon ECS Container Agent Configuration in the Amazon Elastic
	// Container Service Developer Guide.
	logConfiguration?: {
		// The log driver to use for the container. The valid values
		// listed earlier are log drivers that the Amazon ECS container
		// agent can communicate with by default. For tasks using the
		// Fargate launch type, the supported log drivers are awslogs,
		// splunk, and awsfirelens. For tasks using the EC2 launch type,
		// the supported log drivers are awslogs, fluentd, gelf,
		// json-file, journald, logentries,syslog, splunk, and
		// awsfirelens. For more information about using the awslogs log
		// driver, see
		// https://docs.aws.amazon.com/AmazonECS/latest/developerguide/using_awslogs.html
		// Using the awslogs Log Driver in the Amazon Elastic Container
		// Service Developer Guide. For more information about using the
		// awsfirelens log driver, see
		// https://docs.aws.amazon.com/AmazonECS/latest/developerguide/using_firelens.html
		// Custom Log Routing in the Amazon Elastic Container Service
		// Developer Guide. If you have a custom driver that is not
		// listed, you can fork the Amazon ECS container agent project
		// that is https://github.com/aws/amazon-ecs-agent available on
		// GitHub and customize it to work with that driver. We encourage
		// you to submit pull requests for changes that you would like to
		// have included. However, we do not currently provide support
		// for running modified copies of this software.
		logDriver: "json-file" | "syslog" | "journald" | "gelf" | "fluentd" | "awslogs" | "splunk" | "awsfirelens"

		// The configuration options to send to the log driver. This
		// parameter requires version 1.19 of the Docker Remote API or
		// greater on your container instance. To check the Docker Remote
		// API version on your container instance, log in to your
		// container instance and run the following command: sudo docker
		// version --format '{{.Server.APIVersion}}'
		options?: {
			"insert-key"?: string
			...
		}

		// The secrets to pass to the log configuration. For more
		// information, see
		// https://docs.aws.amazon.com/AmazonECS/latest/developerguide/specifying-sensitive-data.html
		// Specifying Sensitive Data in the Amazon Elastic Container
		// Service Developer Guide.
		secretOptions?: [...{
			// The name of the secret.
			name: string

			// The secret to expose to the container. The supported values are
			// either the full ARN of the AWS Secrets Manager secret or the
			// full ARN of the parameter in the AWS Systems Manager Parameter
			// Store. If the AWS Systems Manager Parameter Store parameter
			// exists in the same Region as the task you are launching, then
			// you can use either the full ARN or name of the parameter. If
			// the parameter exists in a different Region, then the full ARN
			// must be specified.
			valueFrom: string
		}]
	}

	// The container health check command and associated configuration
	// parameters for the container. This parameter maps to
	// HealthCheck in the
	// https://docs.docker.com/engine/api/v1.35/#operation/ContainerCreate
	// Create a container section of the
	// https://docs.docker.com/engine/api/v1.35/ Docker Remote API
	// and the HEALTHCHECK parameter of
	// https://docs.docker.com/engine/reference/run/ docker run.
	healthCheck?: {
		// A string array representing the command that the container runs
		// to determine if it is healthy. The string array must start
		// with CMD to execute the command arguments directly, or
		// CMD-SHELL to run the command with the container's default
		// shell. For example: [ "CMD-SHELL", "curl -f http://localhost/
		// || exit 1" ] An exit code of 0 indicates success, and non-zero
		// exit code indicates failure. For more information, see
		// HealthCheck in the
		// https://docs.docker.com/engine/api/v1.35/#operation/ContainerCreate
		// Create a container section of the
		// https://docs.docker.com/engine/api/v1.35/ Docker Remote API.
		command: [...string]

		// The time period in seconds between each health check execution.
		// You may specify between 5 and 300 seconds. The default value
		// is 30 seconds.
		interval?: int

		// The time period in seconds to wait for a health check to
		// succeed before it is considered a failure. You may specify
		// between 2 and 60 seconds. The default value is 5.
		timeout?: int

		// The number of times to retry a failed health check before the
		// container is considered unhealthy. You may specify between 1
		// and 10 retries. The default value is 3.
		retries?: int

		// The optional grace period within which to provide containers
		// time to bootstrap before failed health checks count towards
		// the maximum number of retries. You may specify between 0 and
		// 300 seconds. The startPeriod is disabled by default. If a
		// health check succeeds within the startPeriod, then the
		// container is considered healthy and any subsequent failures
		// count toward the maximum number of retries.
		startPeriod?: int
	}

	// A list of namespaced kernel parameters to set in the container.
	// This parameter maps to Sysctls in the
	// https://docs.docker.com/engine/api/v1.35/#operation/ContainerCreate
	// Create a container section of the
	// https://docs.docker.com/engine/api/v1.35/ Docker Remote API
	// and the --sysctl option to
	// https://docs.docker.com/engine/reference/run/ docker run. It
	// is not recommended that you specify network-related
	// systemControls parameters for multiple containers in a single
	// task that also uses either the awsvpc or host network modes.
	// For tasks that use the awsvpc network mode, the container that
	// is started last determines which systemControls parameters
	// take effect. For tasks that use the host network mode, it
	// changes the container instance's namespaced kernel parameters
	// as well as the containers.
	systemControls?: [...{
		// The namespaced kernel parameter for which to set a value.
		namespace?: string

		// The value for the namespaced kernel parameter specified in
		// namespace.
		value?: string
	}]

	// The type and amount of a resource to assign to a container. The
	// only supported resource is a GPU.
	resourceRequirements?: [...{
		// The value for the specified resource type. If the GPU type is
		// used, the value is the number of physical GPUs the Amazon ECS
		// container agent will reserve for the container. The number of
		// GPUs reserved for all containers in a task should not exceed
		// the number of available GPUs on the container instance the
		// task is launched on. If the InferenceAccelerator type is used,
		// the value should match the deviceName for an
		// InferenceAccelerator specified in a task definition.
		value: string

		// The type of resource to assign to a container. The supported
		// values are GPU or InferenceAccelerator.
		type: "GPU" | "InferenceAccelerator"
	}]

	// The FireLens configuration for the container. This is used to
	// specify and configure a log router for container logs. For
	// more information, see
	// https://docs.aws.amazon.com/AmazonECS/latest/developerguide/using_firelens.html
	// Custom Log Routing in the Amazon Elastic Container Service
	// Developer Guide.
	firelensConfiguration?: {
		// The log router to use. The valid values are fluentd or
		// fluentbit.
		type: "fluentd" | "fluentbit"

		// The options to use when configuring the log router. This field
		// is optional and can be used to specify a custom configuration
		// file or to add additional metadata, such as the task, task
		// definition, cluster, and container instance details to the log
		// event. If specified, the syntax to use is
		// "options":{"enable-ecs-log-metadata":"true|false","config-file-type:"s3|file","config-file-value":"arn:aws:s3:::mybucket/fluent.conf|filepath"}.
		// For more information, see
		// https://docs.aws.amazon.com/AmazonECS/latest/developerguide/using_firelens.html#firelens-taskdef
		// Creating a Task Definition that Uses a FireLens Configuration
		// in the Amazon Elastic Container Service Developer Guide.
		options?: {
			"insert-key"?: string
			...
		}
	}
}
