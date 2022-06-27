universal_name := nix-template-example

label := $(universal_name)
image_repository := $(universal_name)
image_tag := $(image_repository)
container_name := $(universal_name)
dockerfile := Dockerfile.kali

shared_dir := shared

host_uid := $(shell id -u)
host_gid := $(shell id -g)

.PHONY: none
none:

$(shared_dir):
	mkdir -p $@

.PHONY: build
build:
	docker build \
		--build-arg UID=$(host_uid) \
		--build-arg GID=$(host_gid) \
		--build-arg NIX_ENV=$$(nix-build nix -A commonEnv) \
		--label $(label) -t $(image_tag) -f $(dockerfile) .

.PHONY: run
run: build | $(shared_dir)
	docker run -d -it --name $(container_name) --label $(label) \
		--mount type=bind,src=/nix/store,dst=/nix/store,ro \
		--mount type=bind,src=/nix/var/nix/db,dst=/nix/var/nix/db,ro \
		--mount type=bind,src=/nix/var/nix/daemon-socket,dst=/nix/var/nix/daemon-socket,ro \
		--mount type=bind,src=/tmp/.X11-unix,dst=/hack/X11-unix,ro \
		--mount type=bind,src=$(XAUTHORITY),dst=/hack/host.Xauthority,ro \
		--mount type=bind,src=$(abspath $(shared_dir)),dst=/work \
		--env DISPLAY \
		$(image_tag) \
		$$(nix-build nix -A commonEntryScript)

.PHONY: exec
exec:
	docker exec -it \
		--env DISPLAY \
		$(container_name) \
		bash

.PHONY: rm-container
rm-container:
	for id in $$(docker ps -aq -f "name=^$(container_name)$$"); do \
		docker rm -f $$id; \
	done

.PHONY: show-logs
show-logs:
	for id in $$(docker ps -aq -f "name=^$(container_name)$$"); do \
		docker logs $$id; \
	done
