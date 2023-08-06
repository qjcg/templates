package main

import (
	"log"

	"github.com/nats-io/nats.go"
	"github.com/nats-io/nats.go/micro"
)

func main() {
	nc, err := nats.Connect(nats.DefaultURL)
	if err != nil {
		log.Fatal(err)
	}
	defer nc.Close()

	echoHandler := func(req micro.Request) {
		if err := req.Respond(req.Data()); err != nil {
			log.Fatal(err)
		}
	}

	config := micro.Config{
		Name:        "GSSEchoService",
		Version:     "1.0.0",
		Description: "Send back what you receive",

		Endpoint: &micro.EndpointConfig{
			Subject: "echo",
			Handler: micro.HandlerFunc(echoHandler),
		},
	}

	srv, err := micro.AddService(nc, config)
	if err != nil {
		log.Fatal(err)
	}
	defer func() {
		if err := srv.Stop(); err != nil {
			log.Fatal(err)
		}
	}()

	select {} // Wait forever.
}
