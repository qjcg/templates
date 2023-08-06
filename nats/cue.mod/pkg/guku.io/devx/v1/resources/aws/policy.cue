package aws

#IAMPolicy: {
	Version?: "2008-10-17" | "2012-10-17"
	Id?:      string
	Statement: [..._#Statement]
}

_#Statement: {
	Sid?:                            string
	["Principal" | "NotPrincipal"]?: _#PrincipalMap | *"*"
	Effect:                          *"Allow" | "Deny"
	["Action" | "NotAction"]:        string | [...string]
	["Resource" | "NotResource"]:    string | [...string]
	Condition?:                      _#Condition
}

_#PrincipalMap: {
	AWS?: string | [...string]
	Federated?: [...string]
	Service?: string | [...string]
	CanonicalUser?: [...string]
}

_#Condition: {
	[Type=string]: [Key=string]: [..._#ConditionValue]
}

_#ConditionValue: string | number | bool
