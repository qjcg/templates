package main

import (
	"context"
	"embed"
	"flag"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/a-h/templ"

	"github.com/qjcg/templ-example/components"
)

//go:embed static
var staticContent embed.FS

type component struct {
	templ.Component
}

func (c component) dump() {
	c.Render(context.Background(), os.Stdout)
}

func (c component) serve() {
	http.Handle("/static/", http.FileServer(http.FS(staticContent)))
	http.Handle("/", templ.Handler(c))
	fmt.Println("Listening on :3000")
	log.Fatal(http.ListenAndServe(":3000", nil))

}

func main() {
	flagDump := flag.Bool("d", false, "dump content to stdout")
	flag.Parse()

	baseConfig := components.BaseConfig{
		Title: "Demo: Single Page App",
		NavLinks: [][2]string{
			{"About", "#About"},
			{"Contact", "#Contact"},
		},
	}

	c := component{components.Base(baseConfig)}

	if *flagDump {
		c.dump()
		return
	}

	c.serve()
}
