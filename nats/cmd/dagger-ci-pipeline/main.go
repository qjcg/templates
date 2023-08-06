package main

import (
	"context"
	"fmt"
	"log"

	"dagger.io/dagger"
)

type client struct {
	*dagger.Client
}

func NewClient() (*client, error) {
	ctx := context.Background()
	daggerClient, err := dagger.Connect(ctx)
	return &client{daggerClient}, err
}

func (c *client) Lint() {
	src := c.Host().Directory(".")

	return c.Pipeline("lint").
		Container().
		From("golangci/golangci-lint:v1.53-alpine").
		WithDirectory("/src", src).WithWorkdir("/src").
		WithExec([]string{"golangci-lint", "run"}).
		Stdout(c.Context)
}

func main() {
	c, err := NewClient()
	if err != nil {
		log.Fatal(err)
	}

	client, err := dagger.Connect(ctx)
	if err != nil {
		panic(err)
	}
	defer client.Close()

	src := client.Host().Directory(".")

	output, err := client.Pipeline("lint").
		Container().
		From("golangci/golangci-lint:v1.53-alpine").
		WithDirectory("/src", src).WithWorkdir("/src").
		WithExec([]string{"golangci-lint", "run"}).
		Stdout(ctx)

	if err != nil {
		panic(err)
	}

	if len(output) > 0 {
		fmt.Println(output[:300])
	}
}
