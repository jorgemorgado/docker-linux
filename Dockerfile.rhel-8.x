# See https://hub.docker.com/

# FROM docker.io/redhat/ubi8
FROM redhat/ubi8

ARG username
ARG password
ARG uid
ARG gid

ADD ./install /opt/install
ADD ./cacerts/* /usr/local/share/ca-certificates/
ADD ./etc /etc

# System upgrade
RUN dnf upgrade -y --refresh --best --nodocs --noplugins

# RHEL8 packages
RUN dnf install -y --nodocs \
    bind-utils \
    curl \
    dos2unix \
    findutils \
    git \
    gnupg \
    jq \
    less \
    net-tools \
    openssh openssh-server \
    procps \
    python3.11 python3.11-pip \
    sudo \
    tar \
    unzip \
    util-linux \
    vim \
    wget \
    yum yum-utils \
    && \
    dnf clean all

# Docker client
RUN yum-config-manager --add-repo /etc/yum.repos.d/docker-ce.repo && \
    dnf install -y --nodocs --enablerepo="docker-ce-stable" docker-ce

# SSH server configuration
RUN /usr/bin/ssh-keygen -A

# Python packages/modules
RUN pip3 install -r /opt/install/requirements-rhel.txt

# User/group
RUN useradd ${username} \
    --shell /usr/bin/bash \
    -d /home/${username} \
    -u ${uid} -g ${gid} \
    -G wheel && \
    echo ${username}:${password} | chpasswd && \
    mkdir /run/sshd

COPY docker-entrypoint.sh /

# systemctl enable sshd
# systemctl start sshd
# systemctl status sshd
EXPOSE 22

ENTRYPOINT ["/docker-entrypoint.sh"]
