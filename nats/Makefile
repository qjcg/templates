# Docker

.PHONY: up
up:
	docker compose up -d

.PHONY: down
down:
	docker compose down -v

.PHONY: ps
ps:
	docker compose ps -a

.PHONY: client
client:
	docker compose exec client /bin/sh


# NATS

nsc_nkeys_dir := nsc
nsc_store_root := nsc_store
nsc_dir_all := $(nsc_nkeys_dir) $(nsc_store_root)
resolver_conf := resolver.conf
operator_name := examplecorp

.PHONY: keys-init
keys-init:
	NKEYS_PATH=nsc-keystore \
		nsc init --name $(operator_name)

.PHONY: keys-generate
keys-generate:
	nsc generate config \
		--mem-resolver \
		--config-file $(resolver_conf)

.PHONY: keys-clean
keys-clean:
	rm -rf $(nsc_dir_all) $(resolver_conf)


# Diagram

diagram_in := docs/main.d2
diagram_out := $(diagram_in:.d2=.svg)

d2opts_base := --layout elk --sketch
d2opts_watch := --watch --port 9999

.PHONY: diagram
diagram: $(diagram_out)

.PHONY: watch
watch: $(diagram_in)
	d2 $(d2opts_base) $(d2opts_watch) $<

$(diagram_out): $(diagram_in)
	d2 $(d2opts_base) $< $@

.PHONY: clean
clean:
	rm -f $(diagram_out)
