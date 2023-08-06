package github

import (
	"guku.io/devx/v1"
	"guku.io/devx/v2alpha1/traits"
	"guku.io/devx/v2alpha1/workflow/tasks"
	"guku.io/devx/v2alpha1/workflow/triggers"
)

#PipelineResource: {
	#GitHubCISpec
	$metadata: labels: {
		driver: "github"
		type:   ""
	}
}

#AddWorkflow: v1.#Transformer & {
	traits.#Workflow
	$metadata: _
	workflow:  _

	$resources: "\($metadata.id)": #PipelineResource & {
		name: workflow.name
		on: {
			for _, trigger in workflow.triggers {
				if trigger.$metadata.trigger == "PushEvent" {
					push: (triggers.#PushEvent & trigger).filters
				}
				if trigger.$metadata.trigger == "PullRequestEvent" {
					pull_request: (triggers.#PullRequestEvent & trigger).filters
				}
				if trigger.$metadata.trigger == "ManualEvent" {
					workflow_dispatch: {
						inputs: (triggers.#ManualEvent & trigger).inputs
						...
					}
				}
			}
		}
		jobs: {
			for name, task in workflow.tasks {
				if task.$metadata.task == "BuildPushECR" {
					"\(name)": (#BuildPushECR & task).spec
					"\(name)": needs: [ for t in task.dependencies {t.id}]
				}
				if task.$metadata.task == "Terraform" {
					"\(name)": (#Terraform & task).spec
					"\(name)": needs: [ for t in task.dependencies {t.id}]
				}
				if task.$metadata.task == "RawTask" {
					"\(name)": (tasks.#RawTask & task).spec
					"\(name)": needs: [ for t in task.dependencies {t.id}]
				}
			}
		}
	}
}
