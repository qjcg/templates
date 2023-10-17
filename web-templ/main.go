package main

import (
	"context"
	"embed"
	"flag"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"

	"github.com/a-h/templ"

	"github.com/qjcg/templates/web-templ/components"
)

//go:embed static
var staticContent embed.FS

type component struct {
	templ.Component
}

func (c component) dump(w io.Writer) {
	c.Render(context.Background(), w)
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

	c := component{baseConfig.Main()}

	if *flagDump {
		c.dump(os.Stdout)
		return
	}

	c.serve()
}
