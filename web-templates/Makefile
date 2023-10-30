out := templ-example

.PHONY: all
all: generate build

.PHONY: generate
generate: fmt
	templ generate

.PHONY: build
build:
	go build

.PHONY: deps
deps:
	npm ci

.PHONY: bundle
bundle:
	minify \
	--bundle \
	--output static/bundle.js \
	./node_modules/htmx.org/dist/htmx.min.js \
	./node_modules/hyperscript.org/dist/_hyperscript.min.js

.PHONY: fmt
fmt:
	templ fmt ./components

.PHONY: clean
clean:
	rm -rf $(out) node_modules
