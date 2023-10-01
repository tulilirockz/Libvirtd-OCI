FROM registry.fedoraproject.org/fedora:latest 

MAINTAINER "Tulili" <tulilirockz.pub+contact@gmail.com>
LABEL usage="This image is meant to be used as a server for interacting with libvirtd" \
      summary="Server for libvirtd | Based on Project Atomic" \
      maintainer="tulilirockz.pub+contact@gmail.com>"
ENV container docker

ARG SSH_PORT=2222
EXPOSE ${SSH_PORT}
COPY container-deps /

RUN dnf -y update && dnf clean all

RUN dnf groupinstall "Virtualization" --allowerasing -y && \
	dnf install -y $(</container-deps) && \
	dnf clean all && \
	systemctl enable sshd libvirtd && \
	echo "root:CHANGEME" | chpasswd && \
	printf "ListenAddress 127.0.0.1\nPort ${SSH_PORT}\nPermitRootLogin yes\n" | tee -a /etc/ssh/sshd_config && \
	rm /container-deps

VOLUME [ "/sys/fs/cgroup" ]
CMD [ "/usr/sbin/init" ]
