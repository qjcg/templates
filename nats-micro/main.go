package main

import (
	"bytes"
	"log"
	"runtime"
	"strconv"

	"github.com/nats-io/nats.go"
	"github.com/nats-io/nats.go/micro"
)

func main() {
	nc, err := nats.Connect(nats.DefaultURL)
	if err != nil {
		log.Fatal(err)
	}
	defer nc.Close()

	srv, err := micro.AddService(nc, micro.Config{
		Name:        "Demo",
		Version:     "0.1.0",
		Description: "A service providing some simple demo endpoints.",
	})
	if err != nil {
		log.Fatal(err)
	}
	defer srv.Stop()

	g := srv.AddGroup("svc")

	err = g.AddEndpoint(
		"echo",
		micro.HandlerFunc(echoHandler),
		micro.WithEndpointMetadata(map[string]string{
			"schema":  "foo",
			"awesome": "yes",
		}))
	if err != nil {
		log.Fatal(err)
	}

	err = g.AddEndpoint(
		"upper",
		micro.HandlerFunc(upcaseHandler),
		micro.WithEndpointMetadata(map[string]string{
			"schema":  "foo",
			"awesome": "yes",
		}))
	if err != nil {
		log.Fatal(err)
	}

	err = g.AddEndpoint(
		"double",
		micro.HandlerFunc(doubleHandler),
		micro.WithEndpointMetadata(map[string]string{
			"schema":  "foo",
			"awesome": "yes",
		}))
	if err != nil {
		log.Fatal(err)
	}

	runtime.Goexit()
}

func echoHandler(req micro.Request) {
	req.Respond(req.Data())
}

func upcaseHandler(req micro.Request) {
	req.RespondJSON(struct {
		original   string
		upperCased string
	}{
		original:   string(req.Data()),
		upperCased: string(bytes.ToUpper(req.Data())),
	})
}

// doubleHandler reads in an integer from the request and doubles it
func doubleHandler(req micro.Request) {
	n, err := strconv.ParseInt(string(req.Data()), 0, 8)
	if err != nil {
		req.Error("123", err.Error(), []byte(""))
	}
	req.Respond([]byte(strconv.FormatInt(n*2, 10)))
}
