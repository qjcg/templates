package main

import (
	"fmt"
	"os"

	"github.com/AlecAivazis/survey/v2"
)

var questions = map[string][]*survey.Question{
	"type": {
		{
			Name: "TemplateType",
			Prompt: &survey.MultiSelect{
				Message: "Template type:",
				Options: []string{"service", "dashboard", "pipeline"},
				Default: "service",
				Help:    "The type of template to be used",
			},
		},
	},

	"service": {
		{
			Name: "Name",
			Prompt: &survey.Input{
				Message: "Service name:",
				Help:    "Name of the service",
			},
			Validate: survey.Required,
		},
		{
			Name: "Host",
			Prompt: &survey.Input{
				Message: "Host:",
				Default: "localhost",
				Help:    "The hostname for your service",
			},
		},

		{
			Name: "Port",
			Prompt: &survey.Input{
				Message: "Port number:",
				Default: "42",
				Help:    "A port number between 0-65535",
			},
		},
	},

	"dashboard": {
		{
			Name: "Name",
			Prompt: &survey.Input{
				Message: "Dashboard name:",
				Help:    "Name of the dashboard",
			},
			Validate: survey.Required,
		},
		{
			Name: "Template",
			Prompt: &survey.Select{
				Message: "Template type:",
				Options: []string{"foo", "bar", "vanilla"},
				Default: "foo",
				Help:    "The dashboard template to use",
			},
		},
	},

	"pipeline": {
		{
			Name: "Name",
			Prompt: &survey.Input{
				Message: "Pipeline name:",
				Help:    "Name of the pipeline",
			},
			Validate: survey.Required,
		},
		{
			Name: "Template",
			Prompt: &survey.Select{
				Message: "Template type:",
				Options: []string{"foo", "bar", "vanilla"},
				Default: "foo",
				Help:    "The pipeline template to use",
			},
		},
	},
}

type Conf struct {
	TemplateType []string
}

type Service struct {
	Name string
	Host string
	Port uint
}

type Dashboard struct {
	Name     string
	Template string
}

type Pipeline struct {
	Name     string
	Template string
}

func main() {
	fmt.Printf("Welcome to the Awesome Software Solutions Tool! 💯\n\n")

	var conf Conf
	err := survey.Ask(questions["type"], &conf, survey.WithKeepFilter(true))
	if err != nil {
		fmt.Printf("failed to complete type questions: %v\n", err)
		os.Exit(1)
	}
	fmt.Printf("%v\n\n", conf.TemplateType)

	for _, tt := range conf.TemplateType {
		switch tt {
		case "service":
			var service Service
			err = survey.Ask(questions["service"], &service)
			if err != nil {
				fmt.Printf("failed to complete service questions: %v\n", err)
				os.Exit(1)
			}
			fmt.Printf("%v\n\n", service)

		case "dashboard":
			var dashboard Dashboard
			err = survey.Ask(questions["dashboard"], &dashboard)
			if err != nil {
				fmt.Printf("failed to complete dashboard questions: %v\n", err)
				os.Exit(1)
			}
			fmt.Printf("%v\n\n", dashboard)

		case "pipeline":
			var pipeline Pipeline
			err = survey.Ask(questions["pipeline"], &pipeline)
			if err != nil {
				fmt.Printf("failed to complete pipeline questions: %v\n", err)
				os.Exit(1)
			}
			fmt.Printf("%v\n\n", pipeline)
		}
	}
}
