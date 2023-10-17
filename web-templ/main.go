package main

import (
	"context"
	"embed"
	"flag"
	"io"
	"log"
	"net/http"
	"os"

	"github.com/a-h/templ"

	"github.com/qjcg/templates/web-templ/components/base"
)

//go:embed static
var staticContent embed.FS

func dump(c templ.Component, w io.Writer) {
	c.Render(context.Background(), w)
}

func serve(c templ.Component) {
	http.Handle("/static/", http.FileServer(http.FS(staticContent)))
	http.Handle("/", templ.Handler(c))
	log.Println("Listening on :3000")
	log.Fatal(http.ListenAndServe(":3000", nil))

}

func main() {
	flagDump := flag.Bool("d", false, "dump content to stdout")
	flag.Parse()

	config := base.Config{
		Title: "Demo: Single Page App",
		NavLinks: [][2]string{
			{"About", "#About"},
			{"Contact", "#Contact"},
		},
	}

	mainComponent := config.Main()

	if *flagDump {
		dump(mainComponent, os.Stdout)
		return
	}

	serve(mainComponent)
}
