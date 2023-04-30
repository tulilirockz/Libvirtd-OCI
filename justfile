set dotenv-load

KVM_GID := "1100"
IMAGE_NAME := "tulilirockz/libvirtd-server"

setup-all: clean-server build-server run-server init-libvirt

selinux-perms:
  sudo setsebool -P container_use_devices=true

kvm-group:
  groupmod -g {{KVM_GID}} kvm

clean-server:
	-$CONTAINER_RUNTIME image rm "{{IMAGE_NAME}}":latest

build-server:
	$CONTAINER_BUILDER build -t "{{IMAGE_NAME}}" .

run-server:
	$CONTAINER_RUNTIME run \
	-d \
	--net="host" \
	--device /dev/kvm \
	--device /dev/mem \
	--name="$CONTAINER_NAME" \
	-v /proc/modules:/proc/modules:ro \
	-v ${HOME}/.local/share/libvirt:/var/lib/libvirt:Z \
	-v /sys/fs/cgroup:/sys/fs/cgroup:rw \
	--group-add "{{KVM_GID}}" \
	--pull="never" \
	localhost/"{{IMAGE_NAME}}":latest

init-libvirt:
	$CONTAINER_RUNTIME exec "$CONTAINER_NAME" /usr/bin/systemctl start libvirtd.service

create-client:
	-distrobox create -i almalinux:latest virt-manager
	distrobox-enter virt-manager -- sh -c 'sudo dnf update -y && sudo dnf install --setopt=install_weak_deps=False -y virt-manager && sudo dnf install openssh-clients openssh-askpass -y'

