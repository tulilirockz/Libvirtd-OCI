# Libvirtd-OCI

This is a simple server for libvirtd packaged as an OCI image

It runs an SSH server so that it can be remoted into using virt-manager on other container through distrobox or toolbx, this should be runnable on a non-root user and it aims to not clutter up the host system, because that may be an issue on immutable systems like Silverblue, MicroOS, and others.

## Usage

For quickly using this container, an example compose.yml file is provided in this repository root

```yaml
version: '3.8'

services:
  libvirtd-oci: # Make sure to change the container's root password! (CHANGEME)
    image: ghcr.io/tulilirockz/libvirtd-oci:latest
    privileged: true
    network_mode: host
    devices:
      - /dev/kvm
      - /dev/mem
    volumes:
      - /proc/modules:/proc/modules:ro
      - /sys/fs/cgroup:/sys/fs/cgroup:rw
    group_add:
      - 1100 # Use your system's KVM group id 
    ports:
      - 2222:2222 # Default port for SSHing into this container 
```

Or you can use `make run` to run it with a standard docker command

```sh
docker run \
	-d \
	--privileged \
	--net="host" \
	--device /dev/kvm \
	--device /dev/mem \
	--name="libvirtd-server" # container name here \
	-v /proc/modules:/proc/modules:ro \
	-v $(HOME)/.local/share/libvirt:/var/lib/libvirt:Z \
	-v /sys/fs/cgroup:/sys/fs/cgroup:rw \
	--group-add "1100" # kvm gid here \
	"ghcr.io/tulilirockz/libvirtd-oci:latest"
```

### WARNING

If you are actually going to run this container remotely, please change the root password (CHANGEME)!

```sh
podman exec -it libvirtd-server /usr/bin/sudo /usr/bin/passwd
```

## Building

### Image

You can build it by just using your preferred building runtime

```sh
buildah build -t tulilirockz/libvirtd-server .
```

### Container

Libvirt and KVM are quite finicky when running in a container, they require systemd, cgroups, and access to some devices, like `/dev/mem` `/dev/kvm`, the kvm GID should be the same both in the container and the host system and it must have permissions to create the virbr0 interface (and other interfaces) on the host.

This should help you to know what 
```sh
$ grep kvm /etc/groups

# Change KVM GID if you feel like?

$ groupmod -g {{KVM_GID}} kvm # EX: 1100 works in my machine
```

A command like this should work, but also make sure that you have configured your system to have the proper permissions to run all these things (like container_cgroups perm on SELinux). Or run as root for proper networking bridging
