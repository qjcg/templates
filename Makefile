templates_basepath := github.com/qjcg/templates
templates := $(shell fd --type d --maxdepth 1 --exclude '_*' | xargs -n 1 basename)
test_dir := /tmp/gonew_test

test:
	$(foreach t,$(templates),cd $(t) && go test ./...; cd ..; )

test-gonew:
	$(foreach t,$(templates),gonew $(templates_basepath)/$(t) example.com/$(t) $(test_dir)/$(t); )

update-workspace:
	go work use -r .

clean:
	rm -rf $(test_dir)
