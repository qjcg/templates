out := docker-compose.yaml
cue := $(out:.yaml=.cue)
conf_out := conf

build: $(out) conf svg

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

diagram_dir := docs
diagram_d2 := $(diagram_dir)/deployment-architecture.d2
diagram_svg := $(diagram_d2:.d2=.svg)

svg: $(diagram_d2)
	d2 $<

.PHONY: cluster
cluster:
	NATS_PORT=4222 NATS_SERVER_NAME=ca-montreal-1 NATS_CLUSTER_NAME=CA NATS_CLUSTER_PORT=6222 nats-server -c conf/cluster.conf &
	NATS_PORT=4223 NATS_SERVER_NAME=ca-montreal-2 NATS_CLUSTER_NAME=CA NATS_CLUSTER_PORT=6223 nats-server -c conf/cluster.conf &
	NATS_PORT=4224 NATS_SERVER_NAME=ca-montreal-3 NATS_CLUSTER_NAME=CA NATS_CLUSTER_PORT=6224 nats-server -c conf/cluster.conf &

.PHONY: cluster-delete
cluster-delete:
	pkill nats-server

.PHONY: clean
clean:
	rm -rf $(out) $(conf_out) $(diagram_svg)
