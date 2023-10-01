CONTAINER_RUNTIME := podman
CONTAINER_BUILDER := buildah
CONTAINER_NAME := libvirtd
KVM_GID := 1100
IMAGE_NAME := libvirtd-server
DEFAULT_PORT := 2222

selinux-perms:
	setsebool -P container_use_devices=true

.PHONY: clean
clean:
	-$(CONTAINER_RUNTIME) rm -f "$(CONTAINER_NAME)"
	-$(CONTAINER_RUNTIME) image rm -f "$(IMAGE_NAME):latest"

.PHONY: build
build:
	$(CONTAINER_BUILDER) build "--build-arg=SSH_PORT=$(DEFAULT_PORT)" -t "ghcr.io/tulilirockz/$(IMAGE_NAME):latest" .

.PHONY: run
run:
	mkdir -p $(HOME)/.local/share/libvirt
	$(CONTAINER_RUNTIME) run \
		-d \
		--net="host" \
		--device /dev/kvm \
		--device /dev/mem \
		--name="$(CONTAINER_NAME)" \
		-v /proc/modules:/proc/modules:ro \
		-v $(HOME)/.local/share/libvirt:/var/lib/libvirt:Z \
		-v /sys/fs/cgroup:/sys/fs/cgroup:rw \
		--group-add "$(KVM_GID)" \
		-p $(DEFAULT_PORT):$(DEFAULT_PORT) \
		--pull="never" \
		"ghcr.io/tulilirockz/$(IMAGE_NAME):latest"

.PHONY: root-run
root-run:
	sudo mkdir -p $(HOME)/.local/share/libvirt
	sudo $(CONTAINER_RUNTIME) run \
		-d \
		--privileged \
		--net="host" \
		--device /dev/kvm \
		--device /dev/mem \
		--name="$(CONTAINER_NAME)" \
		-v /proc/modules:/proc/modules:ro \
		-v $(HOME)/.local/share/libvirt:/var/lib/libvirt:Z \
		-v /sys/fs/cgroup:/sys/fs/cgroup:rw \
		--group-add "$(KVM_GID)" \
		--pull="never" \
		"ghcr.io/tulilirockz/$(IMAGE_NAME):latest"

.PHONY: start init
init:
	$(CONTAINER_RUNTIME) exec "$(CONTAINER_NAME)" /usr/bin/systemctl start libvirtd.service sshd.service
