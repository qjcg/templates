out := docker-compose.yaml
cue := $(out:.yaml=.cue)
conf_out := conf

build: $(out) conf

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

.PHONY: conf
conf:
	cue build

diagram_d2 := deployment-architecture.d2
diagram_svg := $(diagram_d2:.d2=.svg)

svg: $(diagram_d2)
	d2 $<

.PHONY: clean
clean:
	rm -rf $(out) $(conf_out) $(diagram_svg)
