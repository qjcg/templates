out := docker-compose.yaml

build: $(out)

$(out): docker-compose.cue
	cue export $< --out yaml > $@

.PHONY: debug-template
debug-template: docker-compose.cue
	@cue export -e '#DebugTemplate' | sed 's/\\"//g' | xargs printf

certs:
	mkcert -install
	mkcert example.com

certs-clean:
	mkcert -uninstall

.PHONY: clean
clean:
	rm -f $(out)
