package main

import (
	"context"
	"log"

	"dagger.io/dagger"
)

func main() {
	ctx := context.Background()
	client, err := dagger.Connect(ctx)
	if err != nil {
		log.Fatalf("faild to connect to dagger client: %v", err)
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
		log.Fatalf("failed to run dagger pipeline: %v", err)
	}

	if len(output) > 0 {
		log.Println(output[:300])
	}
}
