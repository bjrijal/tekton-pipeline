FROM ubi8/ubi:latest as base_image

FROM ubuntu:focal as prep
ENV DEBIAN_FRONTEND="noninteractive" \
    PACKER_LOG="0"
COPY --from=base_image  /disk/img.qcow2 /
RUN apt-get update && \
    apt-get install --no-install-recommends -y libguestfs-tools && \
    apt-get install --no-install-recommends -y linux-image-generic
ENV LIBGUESTFS_DEBUG=1 LIBGUESTFS_TRACE=1
RUN ssh-keygen -b 2048 -t rsa -f ./id_rsa_builder -q -N ""
RUN virt-sysprep --format qcow2 -a img.qcow2 --ssh-inject root:file:id_rsa_builder.pub --run-command 'chcon -R system_u:object_r:ssh_home_t:s0  /root/.ssh'

FROM ubuntu:latest as pack
ARG GITHUB_TOKEN
ARG TRAVIS_BUILD_ID
ENV DEBIAN_FRONTEND="noninteractive" \
    PACKER_LOG="0"
# Pre-reqs
RUN apt update
RUN apt install -y curl \
    gnupg \
    software-properties-common

# Install packer
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg |  apt-key add -
RUN  apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
RUN  apt-get update &&  apt-get install -y packer

# Begin work
RUN mkdir /work
WORKDIR /work

RUN apt install -y \
    ansible \
    qemu-system-x86 \ 
    qemu-utils \ 
    openssh-sftp-server \
    git \
    git-crypt \
    gnupg
