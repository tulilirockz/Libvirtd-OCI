FROM docker.io/almalinux/9-init:latest

MAINTAINER "Tulili" <tulilirockz.pub+contact@gmail.com>

LABEL usage="This image is meant to be used as a server for interacting with libvirtd" \
      summary="Server for libvirtd | Based on Project Atomic" \
      maintainer="tulilirockz.pub+contact@gmail.com>"

ENV container docker

EXPOSE 2222

RUN echo "root:CHANGEME" | chpasswd

RUN dnf -y update && dnf clean all

RUN dnf groupinstall "Virtualization Host" --allowerasing -y && dnf install -y libvirt-daemon-driver-* libvirt-daemon libvirt-daemon-kvm qemu-kvm && dnf install openssh-server -y && dnf clean all

RUN systemctl enable sshd ; printf "ListenAddress 127.0.0.1\nPort 2222\n" | tee -a /etc/ssh/sshd_config

RUN systemctl enable libvirtd 

RUN mkdir -p /var/lib/libvirt/images/

VOLUME [ "/sys/fs/cgroup" ]

CMD [ "/usr/sbin/init" ]
