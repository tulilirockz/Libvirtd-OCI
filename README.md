# Libvirtd-OCI

This is a simple server for libvirtd packaged as an OCI image compatible with rootless podman/docker.

It runs an SSH server so that it can be remoted into using virt-manager on other container through distrobox or toolbx, this should be runnable on a non-root user and it aims to not clutter up the host system, because that may be an issue on immutable systems like Silverblue, MicroOS, and others.

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

$ groupmod -g {{KVM_GID}} kvm # EX: 1100 works
```


A command like this should work, but also make sure that you have configured your system to have the proper permissions to run all these things (like container_cgroups perm on SELinux).

```sh
$ podman run \
	-d \
	--net="host" \
	--device /dev/kvm \
	--device /dev/mem \
	--name="libvirtd-server" \
	-v /proc/modules:/proc/modules:ro \
	-v ${HOME}/.local/share/libvirt:/var/lib/libvirt:Z \
	-v /sys/fs/cgroup:/sys/fs/cgroup:rw \
	--group-add "{{KVM_GID}}" \
	--pull="never" \
	localhost/tulilirockz/libvirtd-server:latest
```

## Usage

Firstly make sure to build the image specified on _Building_, create your container using a command like what is specified on the justfile, and remotely access through virt-manager on distrobox (or toolbx).

All this should be setup on the justfile as steps.

1. Build the image
2. Execute Libvirtd inside of the container
3. Remote access through other container using virt-manager

## WARNING

If you are actually going to run this container remotely, please change the root password so that you have better OPSEC!

```sh
podman exec -it libvirtd-server /usr/bin/sudo /usr/bin/passwd
```