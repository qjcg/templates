out := docker-compose.yaml
cue := $(out:.yaml=.cue)

build: $(out)

$(out): $(cue)
	cue export $< --out yaml > $@

.PHONY: debug-template
debug-template: $(cue)
	@cue export -e '#DebugTemplate' | sed 's/\\"//g' | xargs printf

certs:
	mkcert -install
	mkcert example.com

certs-clean:
	mkcert -uninstall

.PHONY: clean
clean:
	rm -f $(out)
